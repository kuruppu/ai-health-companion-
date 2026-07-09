import 'package:equatable/equatable.dart';

/// Base failure class for all app failures
abstract class Failure extends Equatable {

  const Failure({
    required this.message,
    this.code,
  });
  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'Failure: $message (code: $code)';
}

/// Failure when there is no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.code,
  });
}

/// Failure when server returns an error
class ServerFailure extends Failure {

  const ServerFailure({
    required super.message,
    this.statusCode,
    super.code,
  });
  final int? statusCode;

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Failure when authentication fails
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });
}

/// Failure when database operation fails
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.code,
  });
}

/// Failure when cache operation fails
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}

/// Failure when validation fails
class ValidationFailure extends Failure {

  const ValidationFailure({
    required super.message,
    this.errors,
    super.code,
  });
  final Map<String, String>? errors;

  @override
  List<Object?> get props => [message, code, errors];
}

/// Failure when parsing fails
class ParseFailure extends Failure {
  const ParseFailure({
    required super.message,
    super.code,
  });
}

/// Failure when permission is denied
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
  });
}

/// Failure when storage operation fails
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
  });
}

/// Failure when feature is not yet implemented
class NotImplementedFailure extends Failure {
  const NotImplementedFailure({
    super.message = 'Feature not yet implemented',
    super.code,
  });
}

/// Failure when timeout occurs
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Operation timed out',
    super.code,
  });
}

/// Failure when an unexpected error occurs
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred',
    super.code,
  });
}
