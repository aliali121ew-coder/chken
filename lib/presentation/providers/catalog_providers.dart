import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepositoryImpl(ref.watch(supabaseClientProvider));
});

final productByIdProvider = FutureProvider.family<Product, String>((ref, id) {
  return ref.watch(catalogRepositoryProvider).getProductById(id);
});

final productsByCategoryProvider = FutureProvider.family<List<Product>, String>((ref, categoryId) {
  return ref.watch(catalogRepositoryProvider).getProductsByCategory(categoryId);
});

final searchProductsProvider = FutureProvider.family<List<Product>, String>((ref, query) {
  return ref.watch(catalogRepositoryProvider).searchProducts(query);
});
