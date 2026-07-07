/// Base exception class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception thrown when there is no internet connection
class NetworkException extends AppException {
  const NetworkException({
    String message = 'No internet connection',
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Exception thrown when server returns an error
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required String message,
    this.statusCode,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  const AuthException({
    required String message,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Exception thrown when database operation fails
class DatabaseException extends AppException {
  const DatabaseException({
    required String message,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Exception thrown when cache operation fails
class CacheException extends AppException {
  const CacheException({
    required String message,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  final Map<String, String>? errors;

  const ValidationException({
    required String message,
    this.errors,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Exception thrown when parsing fails
class ParseException extends AppException {
  const ParseException({
    required String message,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Exception thrown when permission is denied
class PermissionException extends AppException {
  const PermissionException({
    required String message,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Exception thrown when storage operation fails
class StorageException extends AppException {
  const StorageException({
    required String message,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Exception thrown when feature is not yet implemented
class NotImplementedException extends AppException {
  const NotImplementedException({
    String message = 'Feature not yet implemented',
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Exception thrown when timeout occurs
class TimeoutException extends AppException {
  const TimeoutException({
    String message = 'Operation timed out',
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}
