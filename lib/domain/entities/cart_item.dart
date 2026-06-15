import 'product.dart';

/// A row of the current user's `cart_items`, joined with its [product]
/// and the owning store's name.
class CartItem {
  const CartItem({
    required this.id,
    required this.product,
    required this.storeId,
    required this.storeName,
    required this.storeNameEn,
    required this.quantity,
    required this.selectedVariant,
  });

  final String id;
  final Product product;
  final String storeId;
  final String storeName;
  final String? storeNameEn;
  final int quantity;
  final Map<String, dynamic>? selectedVariant;

  /// Returns the localized store name for [languageCode] (`ar`/`en`).
  String storeDisplayName(String languageCode) {
    if (languageCode == 'en' && storeNameEn != null && storeNameEn!.isNotEmpty) {
      return storeNameEn!;
    }
    return storeName;
  }

  double get lineTotal => product.finalPrice * quantity;
}
