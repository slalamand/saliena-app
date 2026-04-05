/// Input validation utilities.
/// All validation logic is centralized here for consistency and security.
abstract class Validators {
  /// Email validation regex (RFC 5322 simplified)
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Phone validation regex (international format)
  static final RegExp _phoneRegex = RegExp(
    r'^\+?[1-9]\d{7,14}$',
  );

  /// Validates an email address.
  static ValidationResult validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return ValidationResult.invalid('Email is required');
    }

    final trimmed = email.trim().toLowerCase();

    if (trimmed.length > 254) {
      return ValidationResult.invalid('Email is too long');
    }

    if (!_emailRegex.hasMatch(trimmed)) {
      return ValidationResult.invalid('Invalid email format');
    }

    return ValidationResult.valid();
  }

  /// Validates a phone number.
  static ValidationResult validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return ValidationResult.invalid('Phone number is required');
    }

    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!_phoneRegex.hasMatch(cleaned)) {
      return ValidationResult.invalid('Invalid phone number format');
    }

    return ValidationResult.valid();
  }

  /// Validates a password.
  static ValidationResult validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return ValidationResult.invalid('Password is required');
    }

    if (password.length < 8) {
      return ValidationResult.invalid('Password must be at least 8 characters');
    }

    if (password.length > 128) {
      return ValidationResult.invalid('Password is too long');
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return ValidationResult.invalid(
        'Password must contain at least one uppercase letter',
      );
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return ValidationResult.invalid(
        'Password must contain at least one lowercase letter',
      );
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return ValidationResult.invalid(
        'Password must contain at least one number',
      );
    }

    return ValidationResult.valid();
  }

  /// Validates an OTP code.
  static ValidationResult validateOtp(String? otp) {
    if (otp == null || otp.trim().isEmpty) {
      return ValidationResult.invalid('OTP code is required');
    }

    final cleaned = otp.replaceAll(RegExp(r'\s'), '');

    if (cleaned.length != 6) {
      return ValidationResult.invalid('OTP must be 6 digits');
    }

    if (!RegExp(r'^\d{6}$').hasMatch(cleaned)) {
      return ValidationResult.invalid('OTP must contain only numbers');
    }

    return ValidationResult.valid();
  }

  /// Validates a report title.
  static ValidationResult validateReportTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return ValidationResult.invalid('Title is required');
    }

    if (title.trim().length < 5) {
      return ValidationResult.invalid('Title must be at least 5 characters');
    }

    if (title.trim().length > 100) {
      return ValidationResult.invalid('Title must be less than 100 characters');
    }

    return ValidationResult.valid();
  }

  /// Validates a report description.
  static ValidationResult validateReportDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return ValidationResult.invalid('Description is required');
    }

    if (description.trim().length < 10) {
      return ValidationResult.invalid(
        'Description must be at least 10 characters',
      );
    }

    if (description.trim().length > 1000) {
      return ValidationResult.invalid(
        'Description must be less than 1000 characters',
      );
    }

    return ValidationResult.valid();
  }

  /// Validates a full name.
  static ValidationResult validateFullName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return ValidationResult.invalid('Name is required');
    }

    if (name.trim().length < 2) {
      return ValidationResult.invalid('Name is too short');
    }

    if (name.trim().length > 100) {
      return ValidationResult.invalid('Name is too long');
    }

    return ValidationResult.valid();
  }
}

/// Result of a validation check.
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult._({
    required this.isValid,
    this.errorMessage,
  });

  factory ValidationResult.valid() => const ValidationResult._(isValid: true);

  factory ValidationResult.invalid(String message) => ValidationResult._(
        isValid: false,
        errorMessage: message,
      );
}
