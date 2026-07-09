import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/workout.dart';
import '../repositories/workout_repository.dart';

/// Use case for fetching workout history
@injectable
class GetWorkoutHistoryUseCase {

  const GetWorkoutHistoryUseCase(this._repository);
  final WorkoutRepository _repository;

  /// Execute the use case
  ///
  /// [userId] - User whose workouts to fetch
  /// [limit] - Maximum number of workouts
  Future<Either<Failure, List<Workout>>> call({
    required String userId,
    int limit = 20,
  }) async => _repository.getWorkoutHistory(
      userId: userId,
      limit: limit,
    );
}
