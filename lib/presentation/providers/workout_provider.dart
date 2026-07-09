import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/injection_container.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_log.dart';
import '../../domain/usecases/generate_workout_usecase.dart';
import '../../domain/usecases/get_workout_history_usecase.dart';
import '../../domain/usecases/get_workout_logs_usecase.dart';
import '../../domain/usecases/log_workout_usecase.dart';
import 'auth_provider.dart';

part 'workout_provider.g.dart';

@riverpod
class WorkoutHistory extends _$WorkoutHistory {
  late final GetWorkoutHistoryUseCase _getWorkoutHistory;

  @override
  Future<List<Workout>> build() async {
    _getWorkoutHistory = getIt<GetWorkoutHistoryUseCase>();

    final authState = ref.watch(authProvider);
    final user = authState.value?.getCurrentUser();

    if (user == null) {
      return [];
    }

    final result = await _getWorkoutHistory(userId: user.userId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (workouts) => workouts,
    );
  }

  /// Refresh workout history
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class WorkoutGenerator extends _$WorkoutGenerator {
  late final GenerateWorkoutUseCase _generateWorkout;

  @override
  FutureOr<void> build() {
    _generateWorkout = getIt<GenerateWorkoutUseCase>();
  }

  /// Generate a personalized workout
  Future<Workout> generateWorkout({
    required String goalType,
    required int energyLevel,
    required int durationMinutes,
    required WorkoutDifficulty difficulty,
    List<String>? targetMuscles,
  }) async {
    state = const AsyncValue.loading();

    try {
      final authState = ref.read(authProvider);
      final user = authState.value?.getCurrentUser();

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final result = await _generateWorkout(
        userId: user.userId,
        goalType: goalType,
        energyLevel: energyLevel,
        durationMinutes: durationMinutes,
        difficulty: difficulty,
        targetMuscles: targetMuscles,
      );

      final workout = result.fold(
        (failure) => throw Exception(failure.message),
        (workout) => workout,
      );

      // Refresh workout history
      ref.invalidate(workoutHistoryProvider);

      state = const AsyncValue.data(null);

      return workout;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

@riverpod
class WorkoutLogger extends _$WorkoutLogger {
  late final LogWorkoutUseCase _logWorkout;

  @override
  FutureOr<void> build() {
    _logWorkout = getIt<LogWorkoutUseCase>();
  }

  /// Log a completed workout
  Future<WorkoutLog> logWorkout({
    required String workoutId,
    required String workoutName,
    required DateTime startedAt,
    required DateTime completedAt,
    required int exercisesCompleted,
    required int totalExercises,
    int? energyRating,
    String? notes,
  }) async {
    state = const AsyncValue.loading();

    try {
      final authState = ref.read(authProvider);
      final user = authState.value?.getCurrentUser();

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final result = await _logWorkout(
        userId: user.userId,
        workoutId: workoutId,
        workoutName: workoutName,
        startedAt: startedAt,
        completedAt: completedAt,
        exercisesCompleted: exercisesCompleted,
        totalExercises: totalExercises,
        energyRating: energyRating,
        notes: notes,
      );

      final log = result.fold(
        (failure) => throw Exception(failure.message),
        (log) => log,
      );

      state = const AsyncValue.data(null);

      return log;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

@riverpod
class RecommendedWorkouts extends _$RecommendedWorkouts {
  @override
  Future<List<Workout>> build() async {
    final authState = ref.watch(authProvider);
    final user = authState.value?.getCurrentUser();

    if (user == null) {
      return [];
    }

    final getWorkoutHistory = getIt<GetWorkoutHistoryUseCase>();
    final result = await getWorkoutHistory(userId: user.userId, limit: 10);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (workouts) => workouts.where((w) => w.isAiGenerated).take(3).toList(),
    );
  }

  /// Refresh recommended workouts
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class WorkoutLogs extends _$WorkoutLogs {
  late final GetWorkoutLogsUseCase _getWorkoutLogs;

  @override
  Future<List<WorkoutLog>> build() async {
    _getWorkoutLogs = getIt<GetWorkoutLogsUseCase>();

    final authState = ref.watch(authProvider);
    final user = authState.value?.getCurrentUser();

    if (user == null) {
      return [];
    }

    final result = await _getWorkoutLogs(userId: user.userId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (logs) => logs,
    );
  }

  /// Refresh workout logs
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Get logs for a specific date range
  Future<List<WorkoutLog>> getLogsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final authState = ref.read(authProvider);
    final user = authState.value?.getCurrentUser();

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final result = await _getWorkoutLogs(
      userId: user.userId,
      startDate: startDate,
      endDate: endDate,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (logs) => logs,
    );
  }
}

@riverpod
class TodaysWorkoutLogs extends _$TodaysWorkoutLogs {
  @override
  Future<List<WorkoutLog>> build() async {
    final authState = ref.watch(authProvider);
    final user = authState.value?.getCurrentUser();

    if (user == null) {
      return [];
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final getWorkoutLogs = getIt<GetWorkoutLogsUseCase>();
    final result = await getWorkoutLogs(
      userId: user.userId,
      startDate: startOfDay,
      endDate: endOfDay,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (logs) => logs,
    );
  }

  /// Refresh today's workout logs
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
