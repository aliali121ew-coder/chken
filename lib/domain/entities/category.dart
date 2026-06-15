/// Domain entity mirroring a row of the `categories` table.
class Category {
  const Category({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.iconUrl,
    required this.parentId,
    required this.sortOrder,
  });

  final String id;
  final String nameAr;
  final String? nameEn;
  final String? iconUrl;
  final String? parentId;
  final int sortOrder;

  /// Returns the localized name for [languageCode] (`ar`/`en`), falling
  /// back to Arabic when no English translation is set.
  String name(String languageCode) {
    if (languageCode == 'en' && nameEn != null && nameEn!.isNotEmpty) {
      return nameEn!;
    }
    return nameAr;
  }
}
