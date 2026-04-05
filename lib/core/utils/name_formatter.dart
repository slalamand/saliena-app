/// Utility functions for formatting names.
class NameFormatter {
  /// Formats a full name to show first name and last initial.
  /// Example: "Louis Walker" -> "Louis W."
  /// Example: "John" -> "John"
  /// Example: "Mary Jane Smith" -> "Mary S."
  static String formatNameWithInitial(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return 'Anonymous';
    }

    final parts = fullName.trim().split(' ');
    
    if (parts.isEmpty) {
      return 'Anonymous';
    }
    
    if (parts.length == 1) {
      // Only first name
      return parts[0];
    }
    
    // First name + last initial
    final firstName = parts[0];
    final lastInitial = parts.last[0].toUpperCase();
    
    return '$firstName $lastInitial.';
  }
}