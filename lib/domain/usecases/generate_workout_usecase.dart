import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/workout.dart';
import '../repositories/workout_repository.dart';

/// Use case for generating AI-powered personalized workouts
@injectable
class GenerateWorkoutUseCase {

  const GenerateWorkoutUseCase(this._repository);
  final WorkoutRepository _repository;

  /// Execute the use case
  ///
  /// [userId] - User requesting workout
  /// [goalType] - Primary goal
  /// [energyLevel] - Current energy (1-5)
  /// [durationMinutes] - Desired duration
  /// [difficulty] - Difficulty level
  /// [targetMuscles] - Optional muscle group focus
  Future<Either<Failure, Workout>> call({
    required String userId,
    required String goalType,
    required int energyLevel,
    required int durationMinutes,
    required WorkoutDifficulty difficulty,
    List<String>? targetMuscles,
  }) async => _repository.generateWorkout(
      userId: userId,
      goalType: goalType,
      energyLevel: energyLevel,
      durationMinutes: durationMinutes,
      difficulty: difficulty,
      targetMuscles: targetMuscles,
    );
}
