import 'package:equatable/equatable.dart';

import 'user.dart';

abstract class AuthStatus extends Equatable {
  const AuthStatus();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthStatus {
  const AuthInitial();
}

class AuthLoading extends AuthStatus {
  const AuthLoading();
}

class Authenticated extends AuthStatus {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthStatus {
  final String? message;

  const Unauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthStatus {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
