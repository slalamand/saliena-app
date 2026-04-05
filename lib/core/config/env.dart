import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loader.
/// All secrets are loaded from .env file - NEVER hardcode values here.
abstract class Env {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';

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
