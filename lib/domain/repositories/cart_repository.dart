import '../entities/cart_item.dart';

/// Read/write operations on the current user's `cart_items`.
abstract class CartRepository {
  /// Adds [quantity] of [productId] (from [storeId]) to the cart.
  ///
  /// If the same product (with the same [selectedVariant]) is already in
  /// the cart, its quantity is incremented instead of creating a duplicate
  /// row (matches the `UNIQUE(user_id, product_id, selected_variant)`
  /// constraint on `cart_items`).
  Future<void> addItem({
    required String productId,
    required String storeId,
    required int quantity,
    Map<String, dynamic>? selectedVariant,
  });

  /// The current user's cart, joined with product and store details.
  Future<List<CartItem>> getItems();

  /// Sets the quantity of [cartItemId] to [quantity].
  Future<void> updateQuantity(String cartItemId, int quantity);

  /// Removes [cartItemId] from the cart.
  Future<void> removeItem(String cartItemId);
}
