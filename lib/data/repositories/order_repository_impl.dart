import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

/// Supabase-backed implementation of [OrderRepository].
class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _orderSelect = '*, store:stores(name, name_en), order_items(*)';

  @override
  Future<List<String>> placeOrder({
    required String addressId,
    required String paymentMethod,
    String? notes,
    String? couponId,
    String? couponStoreId,
    double couponDiscount = 0,
    String deliveryType = 'immediate',
    DateTime? scheduledAt,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final cartRows = await _client
        .from(SupabaseTables.cartItems)
        .select('id, quantity, selected_variant, store_id, product:products(*)')
        .eq('user_id', userId);

    final byStore = <String, List<Map<String, dynamic>>>{};
    for (final row in cartRows) {
      (byStore[row['store_id'] as String] ??= []).add(row);
    }

    // ── Pass 1: compute each store's order (no writes yet) so we know the
    // grand total before debiting the wallet — this avoids creating orphan
    // orders if a wallet payment turns out to be unaffordable.
    final pending = <_PendingOrder>[];
    final placedCartItemIds = <String>[];
    var orderTotal = 0.0;

    for (final entry in byStore.entries) {
      final storeRow = await _client
          .from(SupabaseTables.stores)
          .select('delivery_fee')
          .eq('id', entry.key)
          .single();
      final deliveryFee = (storeRow['delivery_fee'] as num).toDouble();

      var subtotal = 0.0;
      final itemsPayload = <Map<String, dynamic>>[];
      for (final row in entry.value) {
        final product = ProductModel.fromJson(row['product'] as Map<String, dynamic>);
        final quantity = (row['quantity'] as num).toInt();
        subtotal += product.finalPrice * quantity;
        itemsPayload.add({
          'product_id': product.id,
          'product_name': product.nameAr,
          'product_image_url': product.images.isEmpty ? null : product.images.first,
          'quantity': quantity,
          'unit_price': product.finalPrice,
          'selected_variant': row['selected_variant'],
        });
        placedCartItemIds.add(row['id'] as String);
      }

      final discount = entry.key == couponStoreId ? couponDiscount : 0.0;
      orderTotal += subtotal + deliveryFee - discount;
      pending.add(_PendingOrder(
        storeId: entry.key,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        discount: discount,
        itemsPayload: itemsPayload,
      ));
    }

    // Debit the wallet up front (atomic, row-locked). On insufficient funds
    // this throws before any order row is created.
    if (paymentMethod == 'wallet' && orderTotal > 0) {
      try {
        await _client.rpc<dynamic>('debit_wallet', params: {'p_amount': orderTotal});
      } on PostgrestException catch (e) {
        if (e.message.contains('insufficient_balance')) {
          throw const InsufficientWalletBalance();
        }
        rethrow;
      }
    }

    // ── Pass 2: create the orders and their items. ──
    final orderIds = <String>[];
    for (final p in pending) {
      final orderRow = await _client
          .from(SupabaseTables.orders)
          .insert({
            'customer_id': userId,
            'store_id': p.storeId,
            'address_id': addressId,
            'subtotal': p.subtotal,
            'delivery_fee': p.deliveryFee,
            'discount_amount': p.discount,
            'total_amount': p.subtotal + p.deliveryFee - p.discount,
            'payment_method': paymentMethod,
            'payment_status': paymentMethod == 'wallet' ? 'paid' : 'pending',
            'delivery_type': deliveryType,
            if (scheduledAt != null) 'scheduled_at': scheduledAt.toIso8601String(),
            if (p.storeId == couponStoreId && couponId != null) 'coupon_id': couponId,
            if (notes != null && notes.isNotEmpty) 'notes': notes,
          })
          .select('id')
          .single();

      final orderId = orderRow['id'] as String;
      orderIds.add(orderId);

      await _client.from(SupabaseTables.orderItems).insert([
        for (final item in p.itemsPayload) {...item, 'order_id': orderId},
      ]);
    }

    if (placedCartItemIds.isNotEmpty) {
      await _client.from(SupabaseTables.cartItems).delete().inFilter('id', placedCartItemIds);
    }

    return orderIds;
  }

  @override
  Future<List<Order>> getOrders() async {
    final userId = _client.auth.currentUser!.id;
    final rows = await _client
        .from(SupabaseTables.orders)
        .select(_orderSelect)
        .eq('customer_id', userId)
        .order('created_at', ascending: false);
    return rows.map((row) => OrderModel.fromJson(row).toEntity()).toList();
  }

  @override
  Future<Order> getOrderById(String id) async {
    final row = await _client
        .from(SupabaseTables.orders)
        .select(_orderSelect)
        .eq('id', id)
        .single();
    return OrderModel.fromJson(row).toEntity();
  }
}

/// A single store's computed order, held between the costing pass and the
/// insert pass of [OrderRepositoryImpl.placeOrder].
class _PendingOrder {
  _PendingOrder({
    required this.storeId,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.itemsPayload,
  });

  final String storeId;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final List<Map<String, dynamic>> itemsPayload;
}
