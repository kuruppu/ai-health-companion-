import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/progress_log.dart';
import '../repositories/dashboard_repository.dart';

@injectable
class LogEnergyLevelUseCase {

  LogEnergyLevelUseCase(this._repository);
  final DashboardRepository _repository;

  Future<Either<Failure, ProgressLog>> call({
    required String userId,
    required int energyLevel,
    String? notes,
  }) async {
    if (userId.isEmpty) {
      return const Left(
        ValidationFailure(message: 'User ID is required'),
      );
    }

    if (energyLevel < 1 || energyLevel > 5) {
      return const Left(
        ValidationFailure(message: 'Energy level must be between 1 and 5'),
      );
    }

    return _repository.logEnergyLevel(
      userId: userId,
      energyLevel: energyLevel,
      notes: notes,
    );
  }
}
