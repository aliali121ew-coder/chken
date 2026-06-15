/// Domain entity mirroring a row of the `notifications` table.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String titleAr;
  final String? titleEn;
  final String? bodyAr;
  final String? bodyEn;
  final String? type;
  final bool isRead;
  final DateTime createdAt;

  /// Returns the localized title for [languageCode] (`ar`/`en`), falling
  /// back to Arabic when no English translation is set.
  String title(String languageCode) {
    if (languageCode == 'en' && titleEn != null && titleEn!.isNotEmpty) {
      return titleEn!;
    }
    return titleAr;
  }

  String? body(String languageCode) {
    if (languageCode == 'en' && bodyEn != null && bodyEn!.isNotEmpty) {
      return bodyEn;
    }
    return bodyAr;
  }
}
