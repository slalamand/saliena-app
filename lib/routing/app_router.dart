import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:saliena_app/routing/routes.dart';
import 'package:saliena_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:saliena_app/features/auth/presentation/screens/login_screen.dart';
import 'package:saliena_app/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:saliena_app/features/reports/presentation/screens/home_screen.dart';
import 'package:saliena_app/features/reports/presentation/screens/create_report_screen.dart';
import 'package:saliena_app/features/reports/presentation/screens/help_support_screen.dart';
import 'package:saliena_app/features/reports/presentation/screens/about_screen.dart';
import 'package:saliena_app/features/reports/presentation/screens/map_screen.dart';
import 'package:saliena_app/features/reports/presentation/screens/my_reports_screen.dart';
import 'package:saliena_app/features/reports/presentation/screens/report_detail_screen.dart';
import 'package:saliena_app/features/reports/presentation/screens/offline_queue_screen.dart';
import 'package:saliena_app/features/reports/domain/entities/report.dart';
import 'package:saliena_app/features/settings/presentation/screens/settings_screen.dart';

import 'package:saliena_app/injection.dart';
import 'package:saliena_app/features/auth/presentation/bloc/auth_bloc.dart';

/// Application router configuration.
/// Uses go_router for declarative routing with deep linking support.
final GoRouter appRouter = GoRouter(
  initialLocation: Routes.splash,
  debugLogDiagnostics: false,
  refreshListenable: GoRouterRefreshStream(getIt<AuthBloc>().stream),
  redirect: (context, state) {
    final authState = getIt<AuthBloc>().state;
    
    // Navigation driven ONLY by session state:
    // - session exists (AuthAuthenticated) → App
    // - session null → Sign Up
    final isLoggedIn = authState is AuthAuthenticated;
    final isInOtpFlow = authState is AuthAwaitingOtpVerification;
    
    final isAuthRoute = state.matchedLocation.startsWith('/auth') || 
                       state.matchedLocation == Routes.login ||
                       state.matchedLocation == Routes.signup || 
                       state.matchedLocation == Routes.splash;
    
    final isOtpRoute = state.matchedLocation == Routes.verifyOtp;

    // OTP flow: keep user on OTP screen
    if (isInOtpFlow && isOtpRoute) {
      return null;
    }
    if (isInOtpFlow && !isOtpRoute) {
      return Routes.verifyOtp;
    }

    // Session exists → go to app
    if (isLoggedIn && isAuthRoute) {
      return Routes.home;
    }

    // Session null → go to login (accounts created by management)
    if (!isLoggedIn && !isInOtpFlow && !isAuthRoute) {
      return Routes.login;
    }

    return null;
  },
  routes: [
    // Splash / Loading screen
    GoRoute(
      path: Routes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Authentication routes
    GoRoute(
      path: Routes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    // Note: Signup removed - accounts are created by management office
    GoRoute(
      path: Routes.verifyOtp,
      name: 'verify-otp',
      builder: (context, state) => const OtpVerificationScreen(),
    ),

    // Main app routes (authenticated)
    GoRoute(
      path: Routes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: Routes.createReport,
      name: 'create-report',
      builder: (context, state) => const CreateReportScreen(),
    ),
    GoRoute(
      path: Routes.map,
      name: 'map',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: Routes.myReports,
      name: 'my-reports',
      builder: (context, state) => const MyReportsScreen(),
    ),
    GoRoute(
      path: Routes.offlineQueue,
      name: 'offline-queue',
      builder: (context, state) => const OfflineQueueScreen(),
    ),
    
    // Profile sub-routes
    GoRoute(
      path: Routes.editProfile,
      name: 'edit-profile',
      redirect: (context, state) => Routes.settings,
    ),
    // Removed: changePassword route (app uses email OTP only, no passwords)

    // Report detail (can be accessed from anywhere)
    GoRoute(
      path: '${Routes.reportDetail}/:id',
      name: 'report-detail',
      builder: (context, state) {
        final report = state.extra as Report?;
        if (report == null) {
          return const _PlaceholderScreen(title: 'Report Not Found');
        }
        return ReportDetailScreen(report: report);
      },
    ),

    // Profile (main profile screen from bottom nav)
    GoRoute(
      path: Routes.profile,
      name: 'profile',
      builder: (context, state) => const SettingsScreen(),
    ),
    
    // Settings
    GoRoute(
      path: Routes.settings,
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: Routes.about,
      name: 'about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: Routes.help,
      name: 'help',
      builder: (context, state) => const HelpSupportScreen(),
    ),
  ],

  // Error handling
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);

/// Converts a [Stream] into a [Listenable] for GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Placeholder screen for routes not yet implemented.
/// Will be replaced with actual screens.
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title Screen\n(To be implemented)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
