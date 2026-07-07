import 'package:equatable/equatable.dart';

/// Represents an individual exercise within a workout
class Exercise extends Equatable {
  /// Unique identifier for the exercise
  final String exerciseId;

  /// Exercise name
  final String name;

  /// Brief description of how to perform
  final String description;

  /// Type of exercise
  final ExerciseType type;

  /// Target muscle groups
  final List<String> targetMuscles;

  /// Sets (for strength exercises)
  final int? sets;

  /// Reps per set (for strength exercises)
  final int? repsPerSet;

  /// Duration in seconds (for cardio/hold exercises)
  final int? durationSeconds;

  /// Rest period between sets in seconds
  final int restSeconds;

  /// Order in the workout (0-indexed)
  final int orderIndex;

  /// Optional video URL or GIF
  final String? demonstrationUrl;

  /// Tips for proper form
  final List<String> formTips;

  const Exercise({
    required this.exerciseId,
    required this.name,
    required this.description,
    required this.type,
    required this.targetMuscles,
    this.sets,
    this.repsPerSet,
    this.durationSeconds,
    this.restSeconds = 60,
    required this.orderIndex,
    this.demonstrationUrl,
    this.formTips = const [],
  });

  @override
  List<Object?> get props => [
        exerciseId,
        name,
        description,
        type,
        targetMuscles,
        sets,
        repsPerSet,
        durationSeconds,
        restSeconds,
        orderIndex,
        demonstrationUrl,
        formTips,
      ];

  Exercise copyWith({
    String? exerciseId,
    String? name,
    String? description,
    ExerciseType? type,
    List<String>? targetMuscles,
    int? sets,
    int? repsPerSet,
    int? durationSeconds,
    int? restSeconds,
    int? orderIndex,
    String? demonstrationUrl,
    List<String>? formTips,
  }) {
    return Exercise(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      sets: sets ?? this.sets,
      repsPerSet: repsPerSet ?? this.repsPerSet,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      orderIndex: orderIndex ?? this.orderIndex,
      demonstrationUrl: demonstrationUrl ?? this.demonstrationUrl,
      formTips: formTips ?? this.formTips,
    );
  }

  /// Get formatted workout string (e.g., "3 sets x 12 reps")
  String get workString {
    if (sets != null && repsPerSet != null) {
      return '$sets sets × $repsPerSet reps';
    } else if (durationSeconds != null) {
      final minutes = durationSeconds! ~/ 60;
      final seconds = durationSeconds! % 60;
      if (minutes > 0 && seconds > 0) {
        return '${minutes}m ${seconds}s';
      } else if (minutes > 0) {
        return '${minutes}m';
      } else {
        return '${seconds}s';
      }
    }
    return '';
  }
}

/// Type of exercise
enum ExerciseType {
  strength,
  cardio,
  flexibility,
  balance;

  String get displayName {
    switch (this) {
      case ExerciseType.strength:
        return 'Strength';
      case ExerciseType.cardio:
        return 'Cardio';
      case ExerciseType.flexibility:
        return 'Flexibility';
      case ExerciseType.balance:
        return 'Balance';
    }
  }
}
