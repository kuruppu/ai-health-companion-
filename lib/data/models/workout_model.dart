import 'package:drift/drift.dart' as drift;

import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_log.dart';

/// Data model for Workout entity
class WorkoutModel extends Workout {
  const WorkoutModel({
    required super.workoutId,
    required super.userId,
    required super.name,
    required super.description,
    required super.difficulty,
    required super.durationMinutes,
    required super.targetMuscles,
    required super.exercises,
    super.isAiGenerated,
    super.aiContext,
    required super.createdAt,
  });

  /// Create from entity
  factory WorkoutModel.fromEntity(Workout workout) {
    return WorkoutModel(
      workoutId: workout.workoutId,
      userId: workout.userId,
      name: workout.name,
      description: workout.description,
      difficulty: workout.difficulty,
      durationMinutes: workout.durationMinutes,
      targetMuscles: workout.targetMuscles,
      exercises: workout.exercises,
      isAiGenerated: workout.isAiGenerated,
      aiContext: workout.aiContext,
      createdAt: workout.createdAt,
    );
  }

  /// Convert to entity
  Workout toEntity() {
    return Workout(
      workoutId: workoutId,
      userId: userId,
      name: name,
      description: description,
      difficulty: difficulty,
      durationMinutes: durationMinutes,
      targetMuscles: targetMuscles,
      exercises: exercises,
      isAiGenerated: isAiGenerated,
      aiContext: aiContext,
      createdAt: createdAt,
    );
  }

  /// Create from JSON (Firestore/Claude API)
  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      workoutId: json['workout_id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      difficulty: WorkoutDifficulty.values.byName(json['difficulty'] as String),
      durationMinutes: json['duration_minutes'] as int,
      targetMuscles: (json['target_muscles'] as List).map((e) => e as String).toList(),
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isAiGenerated: json['is_ai_generated'] as bool? ?? false,
      aiContext: json['ai_context'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'workout_id': workoutId,
      'user_id': userId,
      'name': name,
      'description': description,
      'difficulty': difficulty.name,
      'duration_minutes': durationMinutes,
      'target_muscles': targetMuscles,
      'exercises': exercises.map((e) => ExerciseModel.fromEntity(e).toJson()).toList(),
      'is_ai_generated': isAiGenerated,
      'ai_context': aiContext,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from Drift table row
  factory WorkoutModel.fromDrift(Map<String, dynamic> row) {
    return WorkoutModel(
      workoutId: row['workout_id'] as String,
      userId: row['user_id'] as String,
      name: row['name'] as String,
      description: row['description'] as String,
      difficulty: WorkoutDifficulty.values.byName(row['difficulty'] as String),
      durationMinutes: row['duration_minutes'] as int,
      targetMuscles: (row['target_muscles'] as String).split(','),
      exercises: (row['exercises'] as List)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isAiGenerated: row['is_ai_generated'] as bool? ?? false,
      aiContext: row['ai_context'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
    );
  }

  /// Convert to Drift companion
  Map<String, dynamic> toDrift() {
    return {
      'workout_id': workoutId,
      'user_id': userId,
      'name': name,
      'description': description,
      'difficulty': difficulty.name,
      'duration_minutes': durationMinutes,
      'target_muscles': targetMuscles.join(','),
      'exercises_json': exercises.map((e) => ExerciseModel.fromEntity(e).toJson()).toList(),
      'is_ai_generated': isAiGenerated,
      'ai_context': aiContext,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}

/// Data model for Exercise entity
class ExerciseModel extends Exercise {
  const ExerciseModel({
    required super.exerciseId,
    required super.name,
    required super.description,
    required super.type,
    required super.targetMuscles,
    super.sets,
    super.repsPerSet,
    super.durationSeconds,
    super.restSeconds = 60,
    required super.orderIndex,
    super.demonstrationUrl,
    super.formTips = const [],
  });

  /// Create from entity
  factory ExerciseModel.fromEntity(Exercise exercise) {
    return ExerciseModel(
      exerciseId: exercise.exerciseId,
      name: exercise.name,
      description: exercise.description,
      type: exercise.type,
      targetMuscles: exercise.targetMuscles,
      sets: exercise.sets,
      repsPerSet: exercise.repsPerSet,
      durationSeconds: exercise.durationSeconds,
      restSeconds: exercise.restSeconds,
      orderIndex: exercise.orderIndex,
      demonstrationUrl: exercise.demonstrationUrl,
      formTips: exercise.formTips,
    );
  }

  /// Create from JSON
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      exerciseId: json['exercise_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: ExerciseType.values.byName(json['type'] as String),
      targetMuscles: (json['target_muscles'] as List).map((e) => e as String).toList(),
      sets: json['sets'] as int?,
      repsPerSet: json['reps_per_set'] as int?,
      durationSeconds: json['duration_seconds'] as int?,
      restSeconds: json['rest_seconds'] as int? ?? 60,
      orderIndex: json['order_index'] as int,
      demonstrationUrl: json['demonstration_url'] as String?,
      formTips: json['form_tips'] != null
          ? (json['form_tips'] as List).map((e) => e as String).toList()
          : const [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'exercise_id': exerciseId,
      'name': name,
      'description': description,
      'type': type.name,
      'target_muscles': targetMuscles,
      'sets': sets,
      'reps_per_set': repsPerSet,
      'duration_seconds': durationSeconds,
      'rest_seconds': restSeconds,
      'order_index': orderIndex,
      'demonstration_url': demonstrationUrl,
      'form_tips': formTips,
    };
  }
}

/// Data model for WorkoutLog entity
class WorkoutLogModel extends WorkoutLog {
  const WorkoutLogModel({
    required super.logId,
    required super.userId,
    required super.workoutId,
    required super.workoutName,
    required super.startedAt,
    required super.completedAt,
    required super.durationMinutes,
    required super.exercisesCompleted,
    required super.totalExercises,
    super.energyRating,
    super.notes,
  });

  /// Create from entity
  factory WorkoutLogModel.fromEntity(WorkoutLog log) {
    return WorkoutLogModel(
      logId: log.logId,
      userId: log.userId,
      workoutId: log.workoutId,
      workoutName: log.workoutName,
      startedAt: log.startedAt,
      completedAt: log.completedAt,
      durationMinutes: log.durationMinutes,
      exercisesCompleted: log.exercisesCompleted,
      totalExercises: log.totalExercises,
      energyRating: log.energyRating,
      notes: log.notes,
    );
  }

  /// Convert to entity
  WorkoutLog toEntity() {
    return WorkoutLog(
      logId: logId,
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
  }

  /// Create from JSON (Firestore)
  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    return WorkoutLogModel(
      logId: json['log_id'] as String,
      userId: json['user_id'] as String,
      workoutId: json['workout_id'] as String,
      workoutName: json['workout_name'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: DateTime.parse(json['completed_at'] as String),
      durationMinutes: json['duration_minutes'] as int,
      exercisesCompleted: json['exercises_completed'] as int,
      totalExercises: json['total_exercises'] as int,
      energyRating: json['energy_rating'] as int?,
      notes: json['notes'] as String?,
    );
  }

  /// Convert to JSON (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'log_id': logId,
      'user_id': userId,
      'workout_id': workoutId,
      'workout_name': workoutName,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'exercises_completed': exercisesCompleted,
      'total_exercises': totalExercises,
      'energy_rating': energyRating,
      'notes': notes,
    };
  }

  /// Create from Drift table row
  factory WorkoutLogModel.fromDrift(Map<String, dynamic> row) {
    return WorkoutLogModel(
      logId: row['log_id'] as String,
      userId: row['user_id'] as String,
      workoutId: row['workout_id'] as String,
      workoutName: row['workout_name'] as String,
      startedAt: DateTime.fromMillisecondsSinceEpoch(row['started_at'] as int),
      completedAt: DateTime.fromMillisecondsSinceEpoch(row['completed_at'] as int),
      durationMinutes: row['duration_minutes'] as int,
      exercisesCompleted: row['exercises_completed'] as int,
      totalExercises: row['total_exercises'] as int,
      energyRating: row['energy_rating'] as int?,
      notes: row['notes'] as String?,
    );
  }

  /// Convert to Drift companion
  Map<String, dynamic> toDrift() {
    return {
      'log_id': logId,
      'user_id': userId,
      'workout_id': workoutId,
      'workout_name': workoutName,
      'started_at': startedAt.millisecondsSinceEpoch,
      'completed_at': completedAt.millisecondsSinceEpoch,
      'duration_minutes': durationMinutes,
      'exercises_completed': exercisesCompleted,
      'total_exercises': totalExercises,
      'energy_rating': energyRating,
      'notes': notes,
    };
  }
}
