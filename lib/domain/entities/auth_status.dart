import 'package:equatable/equatable.dart';

import 'user.dart';

abstract class AuthStatus extends Equatable {
  const AuthStatus();

  @override
  List<Object?> get props => [];

  /// Get current user if authenticated, null otherwise
  User? getCurrentUser() {
    if (this is Authenticated) {
      return (this as Authenticated).user;
    }
    return null;
  }
}

class AuthInitial extends AuthStatus {
  const AuthInitial();
}

class AuthLoading extends AuthStatus {
  const AuthLoading();
}

class Authenticated extends AuthStatus {

  const Authenticated(this.user);
  final User user;

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthStatus {

  const Unauthenticated({this.message});
  final String? message;

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthStatus {

  const AuthError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
