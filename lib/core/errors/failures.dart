import 'package:equatable/equatable.dart';

/// Base failure class for all app failures
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'Failure: $message (code: $code)';
}

/// Failure when there is no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'No internet connection',
    String? code,
  }) : super(message: message, code: code);
}

/// Failure when server returns an error
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required String message,
    this.statusCode,
    String? code,
  }) : super(message: message, code: code);

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Failure when authentication fails
class AuthFailure extends Failure {
  const AuthFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Failure when database operation fails
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Failure when cache operation fails
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Failure when validation fails
class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure({
    required String message,
    this.errors,
    String? code,
  }) : super(message: message, code: code);

  @override
  List<Object?> get props => [message, code, errors];
}

/// Failure when parsing fails
class ParseFailure extends Failure {
  const ParseFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Failure when permission is denied
class PermissionFailure extends Failure {
  const PermissionFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Failure when storage operation fails
class StorageFailure extends Failure {
  const StorageFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Failure when feature is not yet implemented
class NotImplementedFailure extends Failure {
  const NotImplementedFailure({
    String message = 'Feature not yet implemented',
    String? code,
  }) : super(message: message, code: code);
}

/// Failure when timeout occurs
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'Operation timed out',
    String? code,
  }) : super(message: message, code: code);
}

/// Failure when an unexpected error occurs
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    String message = 'An unexpected error occurred',
    String? code,
  }) : super(message: message, code: code);
}
