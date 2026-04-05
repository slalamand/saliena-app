import 'package:go_router/go_router.dart';

import 'package:saliena_app/features/auth/domain/entities/user.dart';
import 'package:saliena_app/routing/routes.dart';

/// Utility class for route-level authentication and authorization checks.
class AuthGuard {
  /// Checks if the user can access authenticated routes.
  /// Returns redirect path if access denied, null if allowed.
  static String? checkAuth({
    required User? user,
    required GoRouterState state,
  }) {
    final isAuthRoute = state.matchedLocation.startsWith('/auth');
    final isSplash = state.matchedLocation == Routes.splash;

    // Allow splash screen always
    if (isSplash) return null;

    // Not logged in
    if (user == null) {
      // Already on auth route, allow
      if (isAuthRoute) return null;
      // Redirect to login
      return Routes.login;
    }

    // Logged in but not verified as Saliena resident
    if (!user.isVerified) {
      // Allow access to verification pending screen
      // TODO: Add verification pending route
      return null;
    }

    // Logged in and verified
    if (isAuthRoute) {
      // Redirect away from auth routes
      return Routes.home;
    }

    return null;
  }

  /// Checks if the user has permission to access worker/staff routes.
  static String? checkWorkerAccess({
    required User? user,
    required GoRouterState state,
  }) {
    if (user == null) {
      return Routes.login;
    }

    if (!user.role.canFixReports) {
      // User is not a worker or staff, redirect to home
      return Routes.home;
    }

    return null;
  }

  /// Checks if the user has permission to access admin routes.
  static String? checkAdminAccess({
    required User? user,
    required GoRouterState state,
  }) {
    if (user == null) {
      return Routes.login;
    }

    if (!user.role.canVerifyUsers) {
      // User is not office staff, redirect to home
      return Routes.home;
    }

    return null;
  }
}

/// Extension on GoRouterState for convenience methods.
extension GoRouterStateExtension on GoRouterState {
  /// Returns the full path including query parameters.
  String get fullPath {
    final query = uri.queryParameters;
    if (query.isEmpty) return matchedLocation;
    final queryString = query.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '$matchedLocation?$queryString';
  }
}
