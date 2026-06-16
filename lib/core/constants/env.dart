/// Build-time environment configuration.
///
/// Values are injected via `--dart-define`, e.g.:
/// ```
/// flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///              --dart-define=SUPABASE_ANON_KEY=xxxx \
///              --dart-define=FLAVOR=dev
/// ```
abstract final class Env {
  // Defaults point at the dev Supabase project. The anon/publishable key is
  // designed to be safe in client code (RLS enforces access), so shipping it
  // as a default lets any launch method (IDE Run button, `flutter run`) work
  // without manual --dart-define. Override per-build via --dart-define.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://wvbixvfscnfepcnmxxxf.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_mdCfVzIl5IkIlfB2PLLt9A_mQCZ0u9o',
  );

  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );

  static bool get isProd => flavor == 'prod';
  static bool get isStaging => flavor == 'staging';
  static bool get isDev => flavor == 'dev';

  /// Throws during startup if mandatory config is missing — fail fast
  /// instead of silently connecting to an empty Supabase URL.
  static void assertConfigured() {
    assert(
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty,
      'SUPABASE_URL and SUPABASE_ANON_KEY must be provided via --dart-define',
    );
  }
}
