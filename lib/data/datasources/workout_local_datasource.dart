import 'package:drift/drift.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../local/database/app_database.dart';
import '../models/workout_model.dart';

/// Local data source for workout persistence (SQLite + Hive)
@injectable
class WorkoutLocalDataSource {

  const WorkoutLocalDataSource(
    this._database,
    @Named('workoutCache') this._workoutCache,
  );
  final AppDatabase _database;
  final Box<Map<dynamic, dynamic>> _workoutCache;

  /// Save workout to SQLite
  /// TODO: Fix schema mismatch - table uses workoutName/intensity, not name/difficulty
  Future<void> saveWorkout(WorkoutModel workout) async {
    await _database.into(_database.workoutsTable).insert(
          WorkoutsTableCompanion(
            workoutId: Value(workout.workoutId),
            userId: Value(workout.userId),
            workoutName: Value(workout.name),
            workoutType: const Value('strength'), // TODO: Map from workout type
            intensity: Value(workout.difficulty.name),
            durationMinutes: Value(workout.durationMinutes),
            description: Value(workout.description),
            // targetMuscles & exercisesJson don't exist in schema
            // Exercises should be stored in WorkoutExercisesTable
            isAiGenerated: Value(workout.isAiGenerated),
            aiContext: Value(workout.aiContext),
            createdAt: Value(workout.createdAt),
          ),
          mode: InsertMode.insertOrReplace,
        );

    // Cache for faster access
    await _cacheWorkout(workout);
  }

  /// Get workouts from SQLite
  Future<List<WorkoutModel>> getWorkouts({
    required String userId,
    int limit = 20,
  }) async {
    // Try cache first
    final cachedWorkouts = await _getCachedWorkouts(userId);
    if (cachedWorkouts.isNotEmpty) {
      return cachedWorkouts.take(limit).toList();
    }

    // Fallback to database
    final query = _database.select(_database.workoutsTable)
      ..where((tbl) => tbl.userId.equals(userId))
      ..orderBy([
        (tbl) =>
            OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    final rows = await query.get();
    return rows.map(_workoutFromDriftRow).toList();
  }

  /// Get workout by ID
  Future<WorkoutModel?> getWorkoutById({required String workoutId}) async {
    final query = _database.select(_database.workoutsTable)
      ..where((tbl) => tbl.workoutId.equals(workoutId));

    final row = await query.getSingleOrNull();
    return row != null ? _workoutFromDriftRow(row) : null;
  }

  /// Delete workout from SQLite
  Future<void> deleteWorkout({required String workoutId}) async {
    await (_database.delete(_database.workoutsTable)
          ..where((tbl) => tbl.workoutId.equals(workoutId)))
        .go();

    await _removeCachedWorkout(workoutId);
  }

  /// Save workout log to SQLite
  /// TODO: Fix schema mismatch - table uses different field names
  Future<void> saveWorkoutLog(WorkoutLogModel log) async {
    await _database.into(_database.workoutLogsTable).insert(
          WorkoutLogsTableCompanion(
            logId: Value(log.logId),
            userId: Value(log.userId),
            workoutId: Value(log.workoutId),
            // workoutName doesn't exist in schema
            // startedAt doesn't exist, only completedAt
            completedAt: Value(log.completedAt),
            actualDurationMinutes: Value(log.durationMinutes),
            completedExercises: Value(log.exercisesCompleted),
            totalExercises: Value(log.totalExercises),
            completionPercentage: Value(log.exercisesCompleted / log.totalExercises * 100),
            intensity: const Value('moderate'), // TODO: Map from log data
            energyAfter: Value(log.energyRating),
            userNotes: Value(log.notes),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Get workout logs from SQLite
  Future<List<WorkoutLogModel>> getWorkoutLogs({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    var query = _database.select(_database.workoutLogsTable)
      ..where((tbl) => tbl.userId.equals(userId))
      ..orderBy([
        (tbl) =>
            OrderingTerm(expression: tbl.completedAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    if (startDate != null) {
      query = query
        ..where((tbl) => tbl.completedAt.isBiggerOrEqualValue(startDate));
    }

    if (endDate != null) {
      query = query
        ..where((tbl) => tbl.completedAt.isSmallerOrEqualValue(endDate));
    }

    final rows = await query.get();
    return rows.map(_workoutLogFromDriftRow).toList();
  }

  /// Cache workout in Hive
  Future<void> _cacheWorkout(WorkoutModel workout) async {
    final cacheKey = '${workout.userId}_workouts';
    final cached =
        _workoutCache.get(cacheKey, defaultValue: <dynamic, dynamic>{})!;

    cached[workout.workoutId] = workout.toJson();

    // Keep only last 20 workouts per user
    if (cached.length > 20) {
      final sortedKeys = cached.keys.toList()
        ..sort((a, b) {
          final workoutA =
              WorkoutModel.fromJson(cached[a] as Map<String, dynamic>);
          final workoutB =
              WorkoutModel.fromJson(cached[b] as Map<String, dynamic>);
          return workoutB.createdAt.compareTo(workoutA.createdAt);
        });

      final keysToRemove = sortedKeys.skip(20);
      for (final key in keysToRemove) {
        cached.remove(key);
      }
    }

    await _workoutCache.put(cacheKey, cached);
  }

  /// Get cached workouts
  Future<List<WorkoutModel>> _getCachedWorkouts(String userId) async {
    final cacheKey = '${userId}_workouts';
    final cached =
        _workoutCache.get(cacheKey, defaultValue: <dynamic, dynamic>{})!;

    final workouts = cached.values
        .map((json) => WorkoutModel.fromJson(json as Map<String, dynamic>))
        .toList();

    workouts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return workouts;
  }

  /// Remove cached workout
  Future<void> _removeCachedWorkout(String workoutId) async {
    for (final key in _workoutCache.keys) {
      final cached =
          _workoutCache.get(key, defaultValue: <dynamic, dynamic>{})!;
      if (cached.containsKey(workoutId)) {
        cached.remove(workoutId);
        await _workoutCache.put(key, cached);
        break;
      }
    }
  }

  /// Convert Drift row to WorkoutModel
  /// TODO: Fix field name mismatches
  WorkoutModel _workoutFromDriftRow(WorkoutsTableData row) => WorkoutModel.fromDrift({
      'workout_id': row.workoutId,
      'user_id': row.userId,
      'name': row.workoutName, // Changed from row.name
      'description': row.description,
      'difficulty': row.intensity, // Changed from row.difficulty
      'duration_minutes': row.durationMinutes,
      'target_muscles': '', // Field doesn't exist in schema
      'exercises': '[]', // Field doesn't exist, exercises in separate table
      'is_ai_generated': row.isAiGenerated,
      'ai_context': row.aiContext,
      'created_at': row.createdAt.millisecondsSinceEpoch,
    });

  /// Convert Drift row to WorkoutLogModel
  /// TODO: Fix field name mismatches
  WorkoutLogModel _workoutLogFromDriftRow(WorkoutLogsTableData row) => WorkoutLogModel.fromDrift({
      'log_id': row.logId,
      'user_id': row.userId,
      'workout_id': row.workoutId,
      'workout_name': '', // Field doesn't exist in schema
      'started_at': row.completedAt.millisecondsSinceEpoch, // startedAt doesn't exist
      'completed_at': row.completedAt.millisecondsSinceEpoch,
      'duration_minutes': row.actualDurationMinutes, // Changed from row.durationMinutes
      'exercises_completed': row.completedExercises, // Changed from row.exercisesCompleted
      'total_exercises': row.totalExercises,
      'energy_rating': row.energyAfter ?? 3, // Changed from row.energyRating
      'notes': row.userNotes, // Changed from row.notes
    });
}
