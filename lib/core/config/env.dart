/// Environment configuration loader.
/// All secrets are loaded at compile-time via --dart-define-from-file=.env
abstract class Env {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static const String appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'development');

  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';

  /// Validates that all required environment variables are set.
  /// Call this at app startup.
  static void validate() {
    final missing = <String>[];

    if (supabaseUrl.isEmpty || supabaseUrl.contains('your-project')) {
      missing.add('SUPABASE_URL');
    }
    if (supabaseAnonKey.isEmpty || supabaseAnonKey.contains('your-anon-key')) {
      missing.add('SUPABASE_ANON_KEY');
    }
    // Note: No Google Maps API key needed - using OpenStreetMap

    if (missing.isNotEmpty) {
      throw EnvironmentException(
        'Missing required environment variables: ${missing.join(', ')}.\n\n'
        'Please update your .env file with valid Supabase credentials:\n'
        '1. Go to https://supabase.com/dashboard\n'
        '2. Create a new project or select existing one\n'
        '3. Go to Settings > API\n'
        '4. Copy your Project URL and anon/public key\n'
        '5. Update .env file with these values',
      );
    }
  }
}

/// Exception thrown when environment configuration is invalid.
class EnvironmentException implements Exception {
  final String message;
  const EnvironmentException(this.message);

  @override
  String toString() => 'EnvironmentException: $message';
}
