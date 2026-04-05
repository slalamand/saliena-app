/// Application-wide configuration constants.
/// These are NOT secrets - just configuration values.
abstract class AppConfig {
  static const String appName = 'Saliena';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  // Saliena municipality boundaries (approximate)
  static const double salienaLatitude = 56.9496;
  static const double salienaLongitude = 24.1052;
  static const double defaultZoom = 14.0;

  // API timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // Image constraints
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int imageQuality = 85;
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxPhotos = 3; // Maximum 3 photos per report

  // Video constraints
  static const int maxVideoDurationSeconds = 15; // Maximum 15 seconds
  static const int maxVideoSizeBytes = 10 * 1024 * 1024; // 10MB

  // Session
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration otpExpiry = Duration(minutes: 5);

  // Supported locales
  static const List<String> supportedLocales = ['en', 'lv', 'ru'];
  static const String defaultLocale = 'en';
}
