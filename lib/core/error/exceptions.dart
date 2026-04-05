/// Base exception class for data layer errors.
/// Exceptions are caught and converted to Failures in repositories.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => '$runtimeType: $message';
}

/// Server/API exceptions
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });
}

/// Authentication exceptions
class AppAuthException extends AppException {
  const AppAuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Cache/storage exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code = 'NETWORK_ERROR',
    super.originalError,
  });
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    this.fieldErrors,
  });
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException({
    super.message = 'Permission denied',
    super.code = 'PERMISSION_DENIED',
    super.originalError,
  });
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.code = 'NOT_FOUND',
    super.originalError,
  });
}
