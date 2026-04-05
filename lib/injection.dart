import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:saliena_app/core/network/network_info.dart';
import 'package:saliena_app/core/location/location_verification_service.dart';
import 'package:saliena_app/core/services/offline_queue_service.dart';

// Auth
import 'package:saliena_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:saliena_app/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:saliena_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:saliena_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:saliena_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:saliena_app/features/auth/domain/usecases/sign_in.dart';
import 'package:saliena_app/features/auth/domain/usecases/sign_out.dart';
import 'package:saliena_app/features/auth/domain/usecases/sign_up.dart';
import 'package:saliena_app/features/auth/presentation/bloc/auth_bloc.dart';

// Reports
import 'package:saliena_app/features/reports/data/datasources/report_remote_datasource.dart';
import 'package:saliena_app/features/reports/data/datasources/supabase_report_datasource.dart';
import 'package:saliena_app/features/reports/data/repositories/report_repository_impl.dart';
import 'package:saliena_app/features/reports/domain/repositories/report_repository.dart';
import 'package:saliena_app/features/reports/domain/usecases/create_report.dart';
import 'package:saliena_app/features/reports/domain/usecases/get_reports.dart';
import 'package:saliena_app/features/reports/domain/usecases/update_report_status.dart';
import 'package:saliena_app/features/reports/presentation/bloc/reports_bloc.dart';

// Settings
import 'package:saliena_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:saliena_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:saliena_app/features/settings/presentation/bloc/settings_bloc.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Initializes all dependencies.
/// Call this once at app startup before runApp().
Future<void> configureDependencies() async {
  // ==================== EXTERNAL ====================
  
  // Supabase client (already initialized in main.dart)
  getIt.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // Network info
  getIt.registerLazySingleton<InternetConnection>(
    () => InternetConnection(),
  );
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt()),
  );

  // Secure Storage
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Location Verification Service
  getIt.registerLazySingleton<LocationVerificationService>(
    () => LocationVerificationService(),
  );

  // Offline Queue Service
  getIt.registerLazySingleton<OfflineQueueService>(
    () => OfflineQueueService(getIt()),
  );
  
  // Initialize offline queue with error handling
  try {
    await getIt<OfflineQueueService>().initialize();
  } catch (e) {
    // Log error but don't crash the app
    debugPrint('Warning: Failed to initialize offline queue service: $e');
  }

  // ==================== DATA SOURCES ====================
  // These are the Supabase implementations.
  // To swap backends, replace these registrations.

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => SupabaseAuthDataSource(getIt()),
  );

  getIt.registerLazySingleton<ReportRemoteDataSource>(
    () => SupabaseReportDataSource(getIt()),
  );

  // ==================== REPOSITORIES ====================
  // Domain layer depends on these abstract interfaces.
  // Implementations are injected here.

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt()),
  );

  // ==================== USE CASES ====================

  // Auth use cases
  getIt.registerLazySingleton(() => SignIn(getIt()));
  getIt.registerLazySingleton(() => SignUp(getIt()));
  getIt.registerLazySingleton(() => SignOut(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUser(getIt()));

  // Report use cases
  getIt.registerLazySingleton(() => CreateReport(getIt()));
  getIt.registerLazySingleton(() => GetReports(getIt()));
  getIt.registerLazySingleton(() => GetReportsInBounds(getIt()));
  getIt.registerLazySingleton(() => UpdateReportStatus(getIt()));
  getIt.registerLazySingleton(() => MarkReportAsFixed(getIt()));

  // ==================== BLOCS ====================

  // Auth BLoC - Singleton for global auth state
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // Reports BLoC - Singleton for shared state across screens (map, feed, etc.)
  getIt.registerLazySingleton(
    () => ReportsBloc(reportRepository: getIt()),
  );

  // Settings BLoC
  getIt.registerFactory(
    () => SettingsBloc(settingsRepository: getIt()),
  );
}

/// Resets all dependencies.
/// Useful for testing or logout.
Future<void> resetDependencies() async {
  await getIt.reset();
}
