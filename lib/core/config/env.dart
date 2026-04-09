/// Environment configuration loader.
/// All secrets are loaded at compile-time via --dart-define-from-file=.env
/// Falls back to embedded defaults so the app works when run directly from Xcode.
abstract class Env {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://eaydzmsghcylzryfezab.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVheWR6bXNnaGN5bHpyeWZlemFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUzMTcyMjYsImV4cCI6MjA5MDg5MzIyNn0.3zeesDSnXRE1_bWdBMIJm-vsH2g9rJNuAVctlm6wAxw',
  );
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'production',
  );

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
