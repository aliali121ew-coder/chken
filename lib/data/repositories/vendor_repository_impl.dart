import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/inventory_log.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';

/// Supabase-backed implementation of [VendorRepository].
class VendorRepositoryImpl implements VendorRepository {
  VendorRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _orderSelect = '*, store:stores(name, name_en), order_items(*)';

  @override
  Future<Store?> getMyStore() async {
    final userId = _client.auth.currentUser!.id;
    final row = await _client
        .from(SupabaseTables.stores)
        .select()
        .eq('owner_id', userId)
        .maybeSingle();
    if (row == null) return null;
    return StoreModel.fromJson(row).toEntity();
  }

  @override
  Future<VendorStats> getDashboardStats(String storeId) async {
    final rows = await _client
        .from(SupabaseTables.orders)
        .select('status, total_amount')
        .eq('store_id', storeId);

    var totalRevenue = 0.0;
    var pendingOrders = 0;
    for (final row in rows) {
      totalRevenue += (row['total_amount'] as num).toDouble();
      if (row['status'] == 'pending') pendingOrders++;
    }

    return VendorStats(
      totalOrders: rows.length,
      totalRevenue: totalRevenue,
      pendingOrders: pendingOrders,
    );
  }

  @override
  Future<List<Order>> getStoreOrders(String storeId) async {
    final rows = await _client
        .from(SupabaseTables.orders)
        .select(_orderSelect)
        .eq('store_id', storeId)
        .order('created_at', ascending: false);
    return rows.map((row) => OrderModel.fromJson(row).toEntity()).toList();
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _client.from(SupabaseTables.orders).update({'status': status}).eq('id', orderId);
  }

  @override
  Future<List<Product>> getMyProducts(String storeId) async {
    final rows = await _client
        .from(SupabaseTables.products)
        .select()
        .eq('store_id', storeId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);
    return rows.map((row) => ProductModel.fromJson(row).toEntity()).toList();
  }

  @override
  Future<List<InventoryLog>> getInventoryLogs(String storeId) async {
    final rows = await _client
        .from(SupabaseTables.inventoryLogs)
        .select('id, change_amount, stock_after, reason, created_at, product:products(name_ar)')
        .eq('store_id', storeId)
        .order('created_at', ascending: false)
        .limit(100);
    return rows.map((row) {
      final product = row['product'] as Map<String, dynamic>?;
      return InventoryLog(
        id: row['id'] as String,
        productName: product?['name_ar'] as String?,
        changeAmount: (row['change_amount'] as num).toInt(),
        stockAfter: (row['stock_after'] as num).toInt(),
        reason: row['reason'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<void> createProduct({
    required String storeId,
    required String nameAr,
    String? nameEn,
    String? descriptionAr,
    required double basePrice,
    required int discountPercentage,
    required int stockQuantity,
    String? categoryId,
    required bool isActive,
  }) async {
    final row = await _client
        .from(SupabaseTables.products)
        .insert({
          'store_id': storeId,
          'name_ar': nameAr,
          'name_en': nameEn,
          'description_ar': descriptionAr,
          'base_price': basePrice,
          'discount_percentage': discountPercentage,
          'stock_quantity': stockQuantity,
          'category_id': categoryId,
          'is_active': isActive,
        })
        .select('id')
        .single();

    if (stockQuantity > 0) {
      await _logInventory(
        productId: row['id'] as String,
        storeId: storeId,
        changeAmount: stockQuantity,
        stockAfter: stockQuantity,
        reason: 'restock',
      );
    }
  }

  /// Records a stock-change entry in `inventory_logs`.
  Future<void> _logInventory({
    required String productId,
    required String storeId,
    required int changeAmount,
    required int stockAfter,
    required String reason,
  }) async {
    await _client.from(SupabaseTables.inventoryLogs).insert({
      'product_id': productId,
      'store_id': storeId,
      'change_amount': changeAmount,
      'stock_after': stockAfter,
      'reason': reason,
      'created_by': _client.auth.currentUser!.id,
    });
  }

  @override
  Future<void> updateProduct({
    required String productId,
    required String nameAr,
    String? nameEn,
    String? descriptionAr,
    required double basePrice,
    required int discountPercentage,
    required int stockQuantity,
    String? categoryId,
    required bool isActive,
  }) async {
    final existing = await _client
        .from(SupabaseTables.products)
        .select('stock_quantity, store_id')
        .eq('id', productId)
        .single();
    final oldStock = (existing['stock_quantity'] as num?)?.toInt() ?? 0;

    await _client.from(SupabaseTables.products).update({
      'name_ar': nameAr,
      'name_en': nameEn,
      'description_ar': descriptionAr,
      'base_price': basePrice,
      'discount_percentage': discountPercentage,
      'stock_quantity': stockQuantity,
      'category_id': categoryId,
      'is_active': isActive,
    }).eq('id', productId);

    if (stockQuantity != oldStock) {
      await _logInventory(
        productId: productId,
        storeId: existing['store_id'] as String,
        changeAmount: stockQuantity - oldStock,
        stockAfter: stockQuantity,
        reason: 'adjustment',
      );
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _client
        .from(SupabaseTables.products)
        .update({'deleted_at': DateTime.now().toIso8601String()}).eq('id', productId);
  }

  @override
  Future<void> updateStoreSettings({
    required String storeId,
    required String name,
    String? nameEn,
    String? description,
    required double deliveryFee,
    required double minOrderAmount,
    required bool isActive,
  }) async {
    await _client.from(SupabaseTables.stores).update({
      'name': name,
      'name_en': nameEn,
      'description': description,
      'delivery_fee': deliveryFee,
      'min_order_amount': minOrderAmount,
      'is_active': isActive,
    }).eq('id', storeId);
  }
}
