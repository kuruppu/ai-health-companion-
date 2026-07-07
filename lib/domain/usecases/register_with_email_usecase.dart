import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/validation_utils.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class RegisterWithEmailUseCase {
  final AuthRepository _repository;

  RegisterWithEmailUseCase(this._repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Validate email
    if (!ValidationUtils.isValidEmail(email)) {
      return const Left(
        ValidationFailure(message: 'Please enter a valid email address'),
      );
    }

    // Validate password
    final passwordError = ValidationUtils.getPasswordStrengthMessage(password);
    if (passwordError.isNotEmpty) {
      return Left(ValidationFailure(message: passwordError));
    }

    // Validate display name
    if (!ValidationUtils.isValidName(displayName)) {
      return const Left(
        ValidationFailure(
          message:
              'Name must be between 2-50 characters and contain only letters',
        ),
      );
    }

    return await _repository.registerWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
