import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/workout_log.dart';
import '../repositories/workout_repository.dart';

/// Use case for getting workout logs
@injectable
class GetWorkoutLogsUseCase {

  GetWorkoutLogsUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<Either<Failure, List<WorkoutLog>>> call({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) => _repository.getWorkoutLogs(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
}
