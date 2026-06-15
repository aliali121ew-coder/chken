import '../entities/product.dart';

/// Manages the current user's saved/favorited products.
abstract class WishlistRepository {
  /// Ids of all products the current user has saved.
  Future<Set<String>> getWishlistProductIds();

  /// Full product details for the current user's wishlist.
  Future<List<Product>> getWishlistProducts();

  /// Adds [productId] to the wishlist if absent, otherwise removes it.
  Future<void> toggle(String productId);
}
