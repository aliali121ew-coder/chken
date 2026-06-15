/// Domain entity mirroring a row of the `stores` table.
class Store {
  const Store({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.descriptionEn,
    required this.logoUrl,
    required this.bannerUrl,
    required this.gradientStart,
    required this.gradientEnd,
    required this.primaryColor,
    required this.secondaryColor,
    required this.category,
    required this.rating,
    required this.totalReviews,
    required this.deliveryFee,
    required this.minOrderAmount,
    required this.isActive,
    required this.isApproved,
  });

  final String id;
  final String name;
  final String? nameEn;
  final String? description;
  final String? descriptionEn;
  final String? logoUrl;
  final String? bannerUrl;

  /// Hex color strings (e.g. `#4CAF50`) used to build a [StoreTheme].
  final String gradientStart;
  final String gradientEnd;
  final String primaryColor;
  final String secondaryColor;

  final String? category;
  final double rating;
  final int totalReviews;
  final double deliveryFee;
  final double minOrderAmount;
  final bool isActive;
  final bool isApproved;

  /// Returns the localized name for [languageCode] (`ar`/`en`), falling
  /// back to Arabic when no English translation is set.
  String displayName(String languageCode) {
    if (languageCode == 'en' && nameEn != null && nameEn!.isNotEmpty) {
      return nameEn!;
    }
    return name;
  }
}
