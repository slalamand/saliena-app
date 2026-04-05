/// Centralized route path definitions.
/// All route paths are defined here to avoid magic strings.
abstract class Routes {
  // Splash
  static const String splash = '/';

  // Authentication
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String verifyOtp = '/auth/verify-otp';
  // Removed: forgotPassword, setup2fa, verify2fa (app uses email OTP only)

  // Main app
  static const String home = '/home';
  static const String map = '/map';
  static const String createReport = '/create-report';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  // Removed: changePassword (app uses email OTP only, no passwords)

  // Reports
  static const String reportDetail = '/report';
  static const String myReports = '/my-reports';
  static const String offlineQueue = '/offline-queue';

  // Settings
  static const String settings = '/settings';
  static const String language = '/settings/language';
  static const String notifications = '/settings/notifications';
  static const String security = '/settings/security';
  static const String about = '/settings/about';
  static const String help = '/settings/help';
}
