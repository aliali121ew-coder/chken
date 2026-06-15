import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(ref.watch(supabaseClientProvider));
});

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(homeRepositoryProvider).getCategories();
});

final featuredProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(homeRepositoryProvider).getFeaturedProducts();
});

final bestSellersProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(homeRepositoryProvider).getBestSellers();
});

final nearbyStoresProvider = FutureProvider<List<Store>>((ref) {
  return ref.watch(homeRepositoryProvider).getNearbyStores();
});
