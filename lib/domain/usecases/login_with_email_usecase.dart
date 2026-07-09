import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginWithEmailUseCase {

  LoginWithEmailUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty) {
      return const Left(ValidationFailure(message: 'Email is required'));
    }

    if (password.isEmpty) {
      return const Left(ValidationFailure(message: 'Password is required'));
    }

    if (password.length < 6) {
      return const Left(
        ValidationFailure(message: 'Password must be at least 6 characters'),
      );
    }

    return _repository.loginWithEmail(
      email: email,
      password: password,
    );
  }
}
