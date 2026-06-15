/// Domain entity mirroring a row of the `products` table.
class Product {
  const Product({
    required this.id,
    required this.storeId,
    required this.categoryId,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.basePrice,
    required this.discountPercentage,
    required this.finalPrice,
    required this.stockQuantity,
    required this.images,
    required this.tags,
    required this.isFeatured,
    required this.isActive,
    required this.totalSold,
  });

  final String id;
  final String storeId;
  final String? categoryId;
  final String nameAr;
  final String? nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final double basePrice;
  final int discountPercentage;
  final double finalPrice;
  final int stockQuantity;
  final List<String> images;
  final List<String> tags;
  final bool isFeatured;
  final bool isActive;
  final int totalSold;

  /// Returns the localized name for [languageCode] (`ar`/`en`), falling
  /// back to Arabic when no English translation is set.
  String name(String languageCode) {
    if (languageCode == 'en' && nameEn != null && nameEn!.isNotEmpty) {
      return nameEn!;
    }
    return nameAr;
  }

  /// Returns the localized description for [languageCode].
  String? description(String languageCode) {
    if (languageCode == 'en' && descriptionEn != null && descriptionEn!.isNotEmpty) {
      return descriptionEn;
    }
    return descriptionAr;
  }

  String? get primaryImageUrl => images.isEmpty ? null : images.first;

  bool get hasDiscount => discountPercentage > 0;

  bool get inStock => stockQuantity > 0;
}
