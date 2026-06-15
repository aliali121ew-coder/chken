import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/store_repository.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';

/// Supabase-backed implementation of [StoreRepository].
class StoreRepositoryImpl implements StoreRepository {
  StoreRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Store> getStoreById(String id) async {
    final row = await _client
        .from(SupabaseTables.stores)
        .select()
        .eq('id', id)
        .eq('is_active', true)
        .eq('is_approved', true)
        .single();

    return StoreModel.fromJson(row).toEntity();
  }

  @override
  Future<List<Product>> getStoreProducts(String storeId, {int limit = 50}) async {
    final rows = await _client
        .from(SupabaseTables.products)
        .select()
        .eq('is_active', true)
        .eq('store_id', storeId)
        .order('created_at', ascending: false)
        .limit(limit);

    return rows.map((row) => ProductModel.fromJson(row).toEntity()).toList();
  }
}
