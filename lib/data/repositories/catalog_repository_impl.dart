import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../models/product_model.dart';

/// Supabase-backed implementation of [CatalogRepository].
class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Product> getProductById(String id) async {
    final row = await _client
        .from(SupabaseTables.products)
        .select()
        .eq('id', id)
        .eq('is_active', true)
        .single();

    return ProductModel.fromJson(row).toEntity();
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId, {int limit = 30}) async {
    final rows = await _client
        .from(SupabaseTables.products)
        .select()
        .eq('is_active', true)
        .eq('category_id', categoryId)
        .order('created_at', ascending: false)
        .limit(limit);

    return rows.map((row) => ProductModel.fromJson(row).toEntity()).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query, {int limit = 30}) async {
    final sanitized = query.replaceAll(RegExp('[%,]'), '').trim();
    if (sanitized.isEmpty) return const [];

    final rows = await _client
        .from(SupabaseTables.products)
        .select()
        .eq('is_active', true)
        .or('name_ar.ilike.%$sanitized%,name_en.ilike.%$sanitized%')
        .order('total_sold', ascending: false)
        .limit(limit);

    return rows.map((row) => ProductModel.fromJson(row).toEntity()).toList();
  }
}
