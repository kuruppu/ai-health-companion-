/// Base exception class for all app exceptions
abstract class AppException implements Exception {

  const AppException({
    required this.message,
    this.code,
    this.originalException,
    this.stackTrace,
  });
  final String message;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception thrown when there is no internet connection
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code,
    super.originalException,
    super.stackTrace,
  });
}

/// Exception thrown when server returns an error
class ServerException extends AppException {

  const ServerException({
    required super.message,
    this.statusCode,
    super.code,
    super.originalException,
    super.stackTrace,
  });
  final int? statusCode;
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });
}

/// Exception thrown when database operation fails
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });
}

/// Exception thrown when cache operation fails
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });
}

/// Exception thrown when validation fails
class ValidationException extends AppException {

  const ValidationException({
    required super.message,
    this.errors,
    super.code,
    super.originalException,
    super.stackTrace,
  });
  final Map<String, String>? errors;
}

/// Exception thrown when parsing fails
class ParseException extends AppException {
  const ParseException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });
}

/// Exception thrown when permission is denied
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });
}

/// Exception thrown when storage operation fails
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });
}

/// Exception thrown when feature is not yet implemented
class NotImplementedException extends AppException {
  const NotImplementedException({
    super.message = 'Feature not yet implemented',
    super.code,
    super.originalException,
    super.stackTrace,
  });
}

/// Exception thrown when timeout occurs
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Operation timed out',
    super.code,
    super.originalException,
    super.stackTrace,
  });
}
