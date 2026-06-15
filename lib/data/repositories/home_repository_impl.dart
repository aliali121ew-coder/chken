import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';

/// Supabase-backed implementation of [HomeRepository].
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Category>> getCategories() async {
    final rows = await _client
        .from(SupabaseTables.categories)
        .select()
        .eq('is_active', true)
        .order('sort_order');

    return rows.map((row) => CategoryModel.fromJson(row).toEntity()).toList();
  }

  @override
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    final rows = await _client
        .from(SupabaseTables.products)
        .select()
        .eq('is_active', true)
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return rows.map((row) => ProductModel.fromJson(row).toEntity()).toList();
  }

  @override
  Future<List<Product>> getBestSellers({int limit = 10}) async {
    final rows = await _client
        .from(SupabaseTables.products)
        .select()
        .eq('is_active', true)
        .order('total_sold', ascending: false)
        .limit(limit);

    return rows.map((row) => ProductModel.fromJson(row).toEntity()).toList();
  }

  @override
  Future<List<Store>> getNearbyStores({int limit = 10}) async {
    final rows = await _client
        .from(SupabaseTables.stores)
        .select()
        .eq('is_active', true)
        .eq('is_approved', true)
        .order('rating', ascending: false)
        .limit(limit);

    return rows.map((row) => StoreModel.fromJson(row).toEntity()).toList();
  }
}
