import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/wishlist_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/wishlist_repository.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// Ids of products in the current user's wishlist, used to render the
/// filled/outline heart icon on product cards.
final wishlistProductIdsProvider = FutureProvider<Set<String>>((ref) {
  return ref.watch(wishlistRepositoryProvider).getWishlistProductIds();
});

/// Full product details for the wishlist screen.
final wishlistProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(wishlistRepositoryProvider).getWishlistProducts();
});

/// Toggles a product's wishlist membership and refreshes dependent providers.
class WishlistController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> toggle(String productId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(wishlistRepositoryProvider).toggle(productId);
    });
    ref.invalidate(wishlistProductIdsProvider);
    ref.invalidate(wishlistProductsProvider);
  }
}

final wishlistControllerProvider = AsyncNotifierProvider<WishlistController, void>(WishlistController.new);
