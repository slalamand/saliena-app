import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:saliena_app/app.dart';
import 'package:saliena_app/core/config/env.dart';
import 'package:saliena_app/injection.dart';

/// Application entry point.
/// Initializes all services before running the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for consistent UX
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    // Environment variables are loaded at compile-time securely
    Env.validate();

    // Initialize Supabase
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );

    // Configure dependency injection
    await configureDependencies();

    // Run the app
    runApp(const SalienaApp());
  } catch (e, stackTrace) {
    // Show error screen if initialization fails
    debugPrint('Initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    
    // Check if it's a Supabase configuration error
    final isSupabaseError = e.toString().contains('SUPABASE_URL') || 
                           e.toString().contains('SUPABASE_ANON_KEY') ||
                           e.toString().contains('EnvironmentException');
    
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSupabaseError ? Icons.settings : Icons.error_outline, 
                  size: 64, 
                  color: isSupabaseError ? Colors.orange : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  isSupabaseError ? 'Setup Required' : 'Failed to initialize app',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  isSupabaseError 
                    ? 'Please configure your Supabase credentials in the .env file'
                    : e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                if (isSupabaseError) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Steps to fix:\n'
                    '1. Go to https://supabase.com/dashboard\n'
                    '2. Create or select your project\n'
                    '3. Go to Settings > API\n'
                    '4. Copy Project URL and anon key\n'
                    '5. Update .env file with these values',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
