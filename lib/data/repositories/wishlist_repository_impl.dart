import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../models/product_model.dart';

/// Supabase-backed implementation of [WishlistRepository].
class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Set<String>> getWishlistProductIds() async {
    final userId = _client.auth.currentUser!.id;
    final rows = await _client.from(SupabaseTables.wishlists).select('product_id').eq('user_id', userId);
    return rows.map((row) => row['product_id'] as String).toSet();
  }

  @override
  Future<List<Product>> getWishlistProducts() async {
    final userId = _client.auth.currentUser!.id;
    final rows = await _client
        .from(SupabaseTables.wishlists)
        .select('product:products(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return rows
        .map((row) => ProductModel.fromJson(row['product'] as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<void> toggle(String productId) async {
    final userId = _client.auth.currentUser!.id;
    final existing = await _client
        .from(SupabaseTables.wishlists)
        .select('id')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing == null) {
      await _client.from(SupabaseTables.wishlists).insert({'user_id': userId, 'product_id': productId});
    } else {
      await _client.from(SupabaseTables.wishlists).delete().eq('id', existing['id'] as String);
    }
  }
}
