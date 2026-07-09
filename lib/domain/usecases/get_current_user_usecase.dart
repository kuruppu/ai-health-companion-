import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class GetCurrentUserUseCase {

  GetCurrentUserUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, User?>> call() async => _repository.getCurrentUser();
}
