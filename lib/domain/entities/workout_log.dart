import 'package:equatable/equatable.dart';

/// Represents a completed workout session
class WorkoutLog extends Equatable {
  /// Unique identifier for this log
  final String logId;

  /// User who completed the workout
  final String userId;

  /// Workout that was completed
  final String workoutId;

  /// Workout name (cached for display)
  final String workoutName;

  /// When the workout started
  final DateTime startedAt;

  /// When the workout was completed
  final DateTime completedAt;

  /// Actual duration in minutes
  final int durationMinutes;

  /// Number of exercises completed
  final int exercisesCompleted;

  /// Total exercises in the workout
  final int totalExercises;

  /// User's energy rating after workout (1-5)
  final int? energyRating;

  /// Optional notes from user
  final String? notes;

  /// Whether the workout was fully completed
  bool get isFullyCompleted => exercisesCompleted == totalExercises;

  /// Completion percentage
  double get completionPercentage =>
      totalExercises > 0 ? (exercisesCompleted / totalExercises) * 100 : 0;

  const WorkoutLog({
    required this.logId,
    required this.userId,
    required this.workoutId,
    required this.workoutName,
    required this.startedAt,
    required this.completedAt,
    required this.durationMinutes,
    required this.exercisesCompleted,
    required this.totalExercises,
    this.energyRating,
    this.notes,
  });

  @override
  List<Object?> get props => [
        logId,
        userId,
        workoutId,
        workoutName,
        startedAt,
        completedAt,
        durationMinutes,
        exercisesCompleted,
        totalExercises,
        energyRating,
        notes,
      ];

  WorkoutLog copyWith({
    String? logId,
    String? userId,
    String? workoutId,
    String? workoutName,
    DateTime? startedAt,
    DateTime? completedAt,
    int? durationMinutes,
    int? exercisesCompleted,
    int? totalExercises,
    int? energyRating,
    String? notes,
  }) {
    return WorkoutLog(
      logId: logId ?? this.logId,
      userId: userId ?? this.userId,
      workoutId: workoutId ?? this.workoutId,
      workoutName: workoutName ?? this.workoutName,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      exercisesCompleted: exercisesCompleted ?? this.exercisesCompleted,
      totalExercises: totalExercises ?? this.totalExercises,
      energyRating: energyRating ?? this.energyRating,
      notes: notes ?? this.notes,
    );
  }
}
