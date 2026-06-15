/// Keys used with [SharedPreferences] / [FlutterSecureStorage] for
/// persisted local settings and session data.
abstract final class StorageKeys {
  static const String locale = 'app_locale';
  static const String themeMode = 'app_theme_mode';
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String authToken = 'auth_token';
  static const String fcmToken = 'fcm_token';
}
