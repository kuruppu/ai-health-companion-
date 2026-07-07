import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_log.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_local_datasource.dart';
import '../datasources/workout_remote_datasource.dart';
import '../models/workout_model.dart';

@Injectable(as: WorkoutRepository)
class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDataSource _remoteDataSource;
  final WorkoutLocalDataSource _localDataSource;
  final Uuid _uuid;

  const WorkoutRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._uuid,
  );

  @override
  Future<Either<Failure, Workout>> generateWorkout({
    required String userId,
    required String goalType,
    required int energyLevel,
    required int durationMinutes,
    required WorkoutDifficulty difficulty,
    List<String>? targetMuscles,
  }) async {
    try {
      // Generate workout using Claude AI
      final workout = await _remoteDataSource.generateWorkout(
        userId: userId,
        goalType: goalType,
        energyLevel: energyLevel,
        durationMinutes: durationMinutes,
        difficulty: difficulty,
        targetMuscles: targetMuscles,
      );

      // Save to local database
      await _localDataSource.saveWorkout(workout);

      // Save to Firestore (fire and forget)
      _remoteDataSource.saveWorkoutToFirestore(workout).catchError((error) {
        print('Failed to save workout to Firestore: $error');
      });

      return Right(workout.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Workout>>> getWorkoutHistory({
    required String userId,
    int limit = 20,
  }) async {
    try {
      // Try local first
      final localWorkouts = await _localDataSource.getWorkouts(
        userId: userId,
        limit: limit,
      );

      if (localWorkouts.isNotEmpty) {
        return Right(localWorkouts.map((w) => w.toEntity()).toList());
      }

      // Fallback to remote
      final remoteWorkouts = await _remoteDataSource.fetchWorkoutsFromFirestore(
        userId: userId,
        limit: limit,
      );

      // Cache locally
      for (final workout in remoteWorkouts) {
        await _localDataSource.saveWorkout(workout);
      }

      return Right(remoteWorkouts.map((w) => w.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkoutLog>>> getWorkoutLogs({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      final logs = await _localDataSource.getWorkoutLogs(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      return Right(logs.map((l) => l.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final durationMinutes = completedAt.difference(startedAt).inMinutes;

      final log = WorkoutLogModel(
        logId: _uuid.v4(),
        userId: userId,
        workoutId: workoutId,
        workoutName: workoutName,
        startedAt: startedAt,
        completedAt: completedAt,
        durationMinutes: durationMinutes,
        exercisesCompleted: exercisesCompleted,
        totalExercises: totalExercises,
        energyRating: energyRating,
        notes: notes,
      );

      await _localDataSource.saveWorkoutLog(log);

      return Right(log.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Workout>> getWorkoutById({
    required String workoutId,
  }) async {
    try {
      final workout = await _localDataSource.getWorkoutById(
        workoutId: workoutId,
      );

      if (workout == null) {
        return Left(CacheFailure(message: 'Workout not found'));
      }

      return Right(workout.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Workout>> saveWorkout({
    required Workout workout,
  }) async {
    try {
      final workoutModel = WorkoutModel.fromEntity(workout);
      await _localDataSource.saveWorkout(workoutModel);

      return Right(workout);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteWorkout({
    required String workoutId,
  }) async {
    try {
      await _localDataSource.deleteWorkout(workoutId: workoutId);

      _remoteDataSource
          .deleteWorkoutFromFirestore(workoutId)
          .catchError((error) {
        print('Failed to delete workout from Firestore: $error');
      });

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Workout>>> getRecommendedWorkouts({
    required String userId,
  }) async {
    // For MVP, return last 3 AI-generated workouts
    try {
      final workouts = await _localDataSource.getWorkouts(
        userId: userId,
        limit: 10,
      );

      final aiWorkouts =
          workouts.where((w) => w.isAiGenerated).take(3).toList();

      return Right(aiWorkouts.map((w) => w.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
