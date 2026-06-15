import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/store_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/store_repository.dart';

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepositoryImpl(ref.watch(supabaseClientProvider));
});

final storeByIdProvider = FutureProvider.family<Store, String>((ref, id) {
  return ref.watch(storeRepositoryProvider).getStoreById(id);
});

final storeProductsProvider = FutureProvider.family<List<Product>, String>((ref, storeId) {
  return ref.watch(storeRepositoryProvider).getStoreProducts(storeId);
});
