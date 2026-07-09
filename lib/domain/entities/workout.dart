import 'package:equatable/equatable.dart';

import 'exercise.dart';

/// Represents a workout plan with exercises
class Workout extends Equatable {

  const Workout({
    required this.workoutId,
    required this.userId,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.durationMinutes,
    required this.targetMuscles,
    required this.exercises,
    required this.createdAt, this.isAiGenerated = false,
    this.aiContext,
  });
  /// Unique identifier for the workout
  final String workoutId;

  /// User who owns this workout
  final String userId;

  /// Workout name/title
  final String name;

  /// Brief description
  final String description;

  /// Difficulty level
  final WorkoutDifficulty difficulty;

  /// Estimated duration in minutes
  final int durationMinutes;

  /// Target muscle groups
  final List<String> targetMuscles;

  /// List of exercises in this workout
  final List<Exercise> exercises;

  /// Whether this was AI-generated
  final bool isAiGenerated;

  /// AI generation context (goals, energy level, etc.)
  final String? aiContext;

  /// When this workout was created
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        workoutId,
        userId,
        name,
        description,
        difficulty,
        durationMinutes,
        targetMuscles,
        exercises,
        isAiGenerated,
        aiContext,
        createdAt,
      ];

  Workout copyWith({
    String? workoutId,
    String? userId,
    String? name,
    String? description,
    WorkoutDifficulty? difficulty,
    int? durationMinutes,
    List<String>? targetMuscles,
    List<Exercise>? exercises,
    bool? isAiGenerated,
    String? aiContext,
    DateTime? createdAt,
  }) => Workout(
      workoutId: workoutId ?? this.workoutId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      exercises: exercises ?? this.exercises,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      aiContext: aiContext ?? this.aiContext,
      createdAt: createdAt ?? this.createdAt,
    );
}

/// Difficulty level of a workout
enum WorkoutDifficulty {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case WorkoutDifficulty.beginner:
        return 'Beginner';
      case WorkoutDifficulty.intermediate:
        return 'Intermediate';
      case WorkoutDifficulty.advanced:
        return 'Advanced';
    }
  }
}
