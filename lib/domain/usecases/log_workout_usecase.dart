import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/workout_log.dart';
import '../repositories/workout_repository.dart';

/// Use case for logging completed workouts
@injectable
class LogWorkoutUseCase {
  final WorkoutRepository _repository;

  const LogWorkoutUseCase(this._repository);

  /// Execute the use case
  ///
  /// [userId] - User who completed workout
  /// [workoutId] - Workout that was completed
  /// [workoutName] - Workout name
  /// [startedAt] - Start time
  /// [completedAt] - End time
  /// [exercisesCompleted] - Number completed
  /// [totalExercises] - Total exercises
  /// [energyRating] - Energy rating after workout
  /// [notes] - Optional notes
  Future<Either<Failure, WorkoutLog>> call({
    required String userId,
    required String workoutId,
    required String workoutName,
    required DateTime startedAt,
    required DateTime completedAt,
    required int exercisesCompleted,
    required int totalExercises,
    int? energyRating,
    String? notes,
  }) async {
    return await _repository.logWorkout(
      userId: userId,
      workoutId: workoutId,
      workoutName: workoutName,
      startedAt: startedAt,
      completedAt: completedAt,
      exercisesCompleted: exercisesCompleted,
      totalExercises: totalExercises,
      energyRating: energyRating,
      notes: notes,
    );
  }
}
