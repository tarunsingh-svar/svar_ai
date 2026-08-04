/// Build-time configuration, supplied via `--dart-define-from-file`.
///
/// The defaults below are the development values, so `flutter run` works with
/// no extra flags. Release builds pass `--dart-define-from-file=dart_defines/prod.json`
/// to point at production infrastructure. See `dart_defines/example.json`.
///
/// On the Supabase anon key: it is designed to ship inside clients, and row
/// level security — not secrecy — is the access boundary. It is read from the
/// environment here so dev and prod projects can be swapped and the key can be
/// rotated without editing committed source, not because the value is secret.
class Environment {
  Environment._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://tjhuexhsadigbqbxnxkd.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqaHVleGhzYWRpZ2JxYnhueGtkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyMzQ2NDksImV4cCI6MjA5NTgxMDY0OX0.-e5yjKEZkZAfdCbRoLgXw-OnAIhSEK19bYAYDt1x8sI',
  );

  /// RevenueCat public SDK keys. These are per-platform in the dashboard even
  /// though both defaults point at the same sandbox key today.
  static const revenueCatAndroidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_KEY',
    defaultValue: 'test_thDBTlAmcIvKIeDUXNlMNprdPXh',
  );

  static const revenueCatIosApiKey = String.fromEnvironment(
    'REVENUECAT_IOS_KEY',
    defaultValue: 'test_thDBTlAmcIvKIeDUXNlMNprdPXh',
  );

  /// Crash and error reporting. Empty disables Sentry entirely, which is the
  /// default for local development.
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static const sentryEnvironment = String.fromEnvironment(
    'SENTRY_ENVIRONMENT',
    defaultValue: 'development',
  );

  /// True while the build is still on RevenueCat's sandbox keys, which means
  /// real store purchases cannot complete.
  static bool get isRevenueCatSandbox =>
      revenueCatAndroidApiKey.startsWith('test_') ||
      revenueCatIosApiKey.startsWith('test_');
}
