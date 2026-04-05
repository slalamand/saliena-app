import 'package:flutter/material.dart';

/// Saliena minimal color system.
/// Single accent color, off-white backgrounds, subtle palette.
abstract class SalienaColors {
  // Saliena Estate Brand Colors
  static const Color navy = Color(0xFF003A70); // Deep Blue for Splash/Buttons
  static const Color navyDark = Color(0xFF1A5A9C); // Lighter navy for dark mode text
  static const Color backgroundLightBlue = Color(0xFFDAEBF5); // Light Blue for Login
  static const Color backgroundDarkBlue = Color(0xFF1C2A3A); // Dark Blue for Login in dark mode
  static const Color logoGreen = Color(0xFF008542); // Green Line
  static const Color logoYellow = Color(0xFFFFC72C); // Sun Yellow
  static const Color logoBlue = Color(0xFF003A70); // Logo Text Blue (Same as navy)

  // Icon Colors
  static const Color iconYellow = Color(0xFFFFC72C);
  static const Color iconGreen = Color(0xFF008542); // Pantone 348 C
  static const Color iconBlue = Color(0xFF007AFF); // iOS Blue for Profile icon
  
  // Helper methods for theme-aware colors
  static Color getBackgroundBlue(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDarkBlue
        : backgroundLightBlue;
  }
  
  static Color getNavy(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? navyDark
        : navy;
  }
  
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : navy;
  }
  
  static Color getTextFieldBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C3E50)
        : Colors.white;
  }
  
  static Color getTextFieldHint(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.5)
        : navy.withValues(alpha: 0.5);
  }

  static Color getHintColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.5)
        : navy.withValues(alpha: 0.5);
  }

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? accentBlueDark
        : accentBlue;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2E)
        : Colors.white;
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF48484A)
        : navy.withValues(alpha: 0.1);
  }

  static Color getIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.9)
        : navy;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.7)
        : navy.withValues(alpha: 0.7);
  }

  static Color getTertiaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.5)
        : navy.withValues(alpha: 0.5);
  }

  // Single accent color (soft blue) - use sparingly
  static const Color accentBlue = Color(0xFF007AFF);
  static const Color accentBlueDark = Color(0xFF0A84FF);

  // Light theme colors - minimal palette
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    // Primary = accent blue (use sparingly for CTAs only)
    primary: accentBlue,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE8F4FF),
    onPrimaryContainer: Color(0xFF001D36),
    // Secondary matches primary for minimal approach
    secondary: accentBlue,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE8F4FF),
    onSecondaryContainer: Color(0xFF001D36),
    // Tertiary for success state
    tertiary: Color(0xFF34C759),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFE5F8E8),
    onTertiaryContainer: Color(0xFF0A3818),
    // Error state (iOS red)
    error: Color(0xFFFF3B30),
    onError: Colors.white,
    errorContainer: Color(0xFFFFE5E5),
    onErrorContainer: Color(0xFF5F0000),
    // Surfaces - white on off-white
    surface: Colors.white,
    onSurface: Color(0xFF1C1C1E),
    surfaceContainerHighest: Color(0xFFF5F5F5),
    onSurfaceVariant: Color(0xFF8E8E93),
    // Borders - subtle
    outline: Color(0xFFD1D1D6),
    outlineVariant: Color(0xFFE5E5EA),
    shadow: Color(0x0A000000),
    scrim: Color(0x66000000),
    inverseSurface: Color(0xFF1C1C1E),
    onInverseSurface: Colors.white,
    inversePrimary: accentBlueDark,
  );

  // Dark theme colors - dark grey, not black
  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: accentBlueDark,
    onPrimary: Color(0xFF003363),
    primaryContainer: Color(0xFF1C3A52),
    onPrimaryContainer: Color(0xFFB8DAFF),
    secondary: accentBlueDark,
    onSecondary: Color(0xFF003363),
    secondaryContainer: Color(0xFF1C3A52),
    onSecondaryContainer: Color(0xFFB8DAFF),
    tertiary: Color(0xFF32D74B),
    onTertiary: Color(0xFF00320F),
    tertiaryContainer: Color(0xFF004D1A),
    onTertiaryContainer: Color(0xFFB8F0C2),
    error: Color(0xFFFF453A),
    onError: Color(0xFF5F0000),
    errorContainer: Color(0xFF8C0000),
    onErrorContainer: Color(0xFFFFB4AB),
    surface: Color(0xFF2C2C2E),
    onSurface: Color(0xFFF2F2F7),
    surfaceContainerHighest: Color(0xFF3A3A3C),
    onSurfaceVariant: Color(0xFF8E8E93),
    outline: Color(0xFF48484A),
    outlineVariant: Color(0xFF38383A),
    shadow: Color(0x1A000000),
    scrim: Color(0x99000000),
    inverseSurface: Color(0xFFF2F2F7),
    onInverseSurface: Color(0xFF1C1C1E),
    inversePrimary: accentBlue,
  );

  // Background colors with subtle gradients
  static const Color backgroundLight = Color(0xFFF9F9F9);
  static const Color backgroundGradientTopLight = Color(0xFFFAFAFA);
  static const Color backgroundGradientBottomLight = Color(0xFFF2F2F2);
  
  static const Color backgroundDark = Color(0xFF1C1C1E);
  static const Color backgroundGradientTopDark = Color(0xFF1E1E20);
  static const Color backgroundGradientBottomDark = Color(0xFF1A1A1C);

  // Semantic colors (iOS style)
  static const Color success = Color(0xFF34C759);
  static const Color successDark = Color(0xFF32D74B);
  static const Color warning = Color(0xFFFF9500);
  static const Color warningDark = Color(0xFFFF9F0A);

  // Status colors for reports - soft, muted
  static const Color statusPending = Color(0xFFFF9500);
  static const Color statusInProgress = accentBlue;
  static const Color statusFixed = Color(0xFF34C759);
}

