import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../models/cart_item_model.dart';

/// Supabase-backed implementation of [CartRepository].
class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<void> addItem({
    required String productId,
    required String storeId,
    required int quantity,
    Map<String, dynamic>? selectedVariant,
  }) async {
    final userId = _client.auth.currentUser!.id;

    final filter = _client
        .from(SupabaseTables.cartItems)
        .select('id, quantity')
        .eq('user_id', userId)
        .eq('product_id', productId);

    final existing = await (selectedVariant == null
            ? filter.isFilter('selected_variant', null)
            : filter.eq('selected_variant', selectedVariant))
        .maybeSingle();

    if (existing != null) {
      final newQuantity = (existing['quantity'] as num).toInt() + quantity;
      await _client
          .from(SupabaseTables.cartItems)
          .update({'quantity': newQuantity})
          .eq('id', existing['id'] as String);
    } else {
      await _client.from(SupabaseTables.cartItems).insert({
        'user_id': userId,
        'product_id': productId,
        'store_id': storeId,
        'quantity': quantity,
        'selected_variant': selectedVariant,
      });
    }
  }

  @override
  Future<List<CartItem>> getItems() async {
    final userId = _client.auth.currentUser!.id;

    final rows = await _client
        .from(SupabaseTables.cartItems)
        .select('id, quantity, selected_variant, store_id, product:products(*), store:stores(name, name_en)')
        .eq('user_id', userId)
        .order('added_at');

    return rows.map((row) => CartItemModel.fromJson(row).toEntity()).toList();
  }

  @override
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    await _client.from(SupabaseTables.cartItems).update({'quantity': quantity}).eq('id', cartItemId);
  }

  @override
  Future<void> removeItem(String cartItemId) async {
    await _client.from(SupabaseTables.cartItems).delete().eq('id', cartItemId);
  }
}
