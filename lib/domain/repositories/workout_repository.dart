import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/workout.dart';
import '../entities/workout_log.dart';

/// Repository interface for workout operations
abstract class WorkoutRepository {
  /// Generate a personalized workout using AI
  ///
  /// [userId] - User requesting the workout
  /// [goalType] - Primary goal (weight loss, muscle gain, general fitness)
  /// [energyLevel] - Current energy level (1-5)
  /// [durationMinutes] - Desired workout duration
  /// [difficulty] - Preferred difficulty level
  /// [targetMuscles] - Optional specific muscle groups to target
  ///
  /// Returns AI-generated workout
  Future<Either<Failure, Workout>> generateWorkout({
    required String userId,
    required String goalType,
    required int energyLevel,
    required int durationMinutes,
    required WorkoutDifficulty difficulty,
    List<String>? targetMuscles,
  });

  /// Get workout history for a user
  ///
  /// [userId] - User whose workouts to fetch
  /// [limit] - Maximum number of workouts to return
  ///
  /// Returns list of saved workouts
  Future<Either<Failure, List<Workout>>> getWorkoutHistory({
    required String userId,
    int limit = 20,
  });

  /// Get workout logs (completed sessions)
  ///
  /// [userId] - User whose logs to fetch
  /// [startDate] - Start of date range (optional)
  /// [endDate] - End of date range (optional)
  /// [limit] - Maximum number of logs to return
  ///
  /// Returns list of workout logs
  Future<Either<Failure, List<WorkoutLog>>> getWorkoutLogs({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  /// Log a completed workout
  ///
  /// [userId] - User who completed the workout
  /// [workoutId] - Workout that was completed
  /// [workoutName] - Workout name (cached)
  /// [startedAt] - When workout started
  /// [completedAt] - When workout finished
  /// [exercisesCompleted] - Number of exercises completed
  /// [totalExercises] - Total exercises in workout
  /// [energyRating] - User's energy rating after workout
  /// [notes] - Optional user notes
  ///
  /// Returns the created workout log
  Future<Either<Failure, WorkoutLog>> logWorkout({
    required String userId,
    required String workoutId,
    required String workoutName,
    required DateTime startedAt,
    required DateTime completedAt,
    required int exercisesCompleted,
    required int totalExercises,
    int? energyRating,
    String? notes,
  });

  /// Get a specific workout by ID
  ///
  /// [workoutId] - ID of the workout to fetch
  ///
  /// Returns the workout if found
  Future<Either<Failure, Workout>> getWorkoutById({
    required String workoutId,
  });

  /// Save a workout for later use
  ///
  /// [workout] - Workout to save
  ///
  /// Returns saved workout
  Future<Either<Failure, Workout>> saveWorkout({
    required Workout workout,
  });

  /// Delete a workout
  ///
  /// [workoutId] - ID of the workout to delete
  ///
  /// Returns unit on success
  Future<Either<Failure, Unit>> deleteWorkout({
    required String workoutId,
  });

  /// Get recommended workouts based on user profile
  ///
  /// [userId] - User requesting recommendations
  ///
  /// Returns list of recommended workouts
  Future<Either<Failure, List<Workout>>> getRecommendedWorkouts({
    required String userId,
  });
}
