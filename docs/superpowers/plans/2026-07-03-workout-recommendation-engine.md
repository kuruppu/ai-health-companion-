# Workout Recommendation Engine Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a conversational AI-powered workout recommendation system that provides progressive, personalized workout suggestions with automatic difficulty adjustment based on user feedback.

**Architecture:** Clean Architecture with three layers - Domain (entities, repositories), Data (models, data sources, implementations), Presentation (Riverpod providers, UI). Uses SQLite (Drift) for local storage, follows existing patterns from nutrition engine. AI integration via system prompt with dynamic context injection.

**Tech Stack:** Flutter 3.x, Dart 3.x, Drift (SQLite), Riverpod 2.x, Claude API integration

---

## File Structure Overview

### Domain Layer (lib/domain/)
```
lib/domain/workout/
├── entities/
│   ├── workout_log.dart                 # Workout log entity
│   ├── user_fitness_profile.dart        # Fitness profile entity
│   ├── workout_recommendation.dart      # Recommendation result
│   ├── weekly_summary.dart              # Weekly stats
│   ├── monthly_progress.dart            # Monthly stats
│   └── recovery_assessment.dart         # Recovery status
├── repositories/
│   └── workout_repository.dart          # Repository interface
└── enums/
    ├── workout_type.dart                # Workout type enum
    ├── user_feedback.dart               # Feedback enum
    └── energy_level.dart                # Energy level enum
```

### Data Layer (lib/data/)
```
lib/data/workout/
├── models/
│   ├── workout_log_model.dart           # Drift table + model
│   ├── user_fitness_profile_model.dart  # Drift table + model
│   └── workout_database.dart            # Drift database definition
├── datasources/
│   ├── workout_local_datasource.dart    # Local DB operations
│   └── workout_remote_datasource.dart   # Firebase sync (future)
└── repositories/
    └── workout_repository_impl.dart     # Repository implementation
```

### Presentation Layer (lib/presentation/)
```
lib/presentation/workout/
├── providers/
│   ├── workout_recommendation_provider.dart  # Recommendation logic
│   ├── fitness_profile_provider.dart         # Profile state
│   └── workout_history_provider.dart         # History queries
└── widgets/
    └── (no new widgets - uses existing chat UI)
```

### Services (lib/services/)
```
lib/services/workout/
├── recommendation_engine.dart           # Core algorithm
├── feedback_processor.dart              # Parse feedback
├── progressive_overload_manager.dart    # Fitness level updates
├── recovery_manager.dart                # Recovery assessment
└── workout_ai_context_builder.dart      # AI prompt builder
```

### Tests
```
test/domain/workout/
test/data/workout/
test/services/workout/
```

---

## Task 1: Setup Domain Layer - Enums

**Files:**
- Create: `lib/domain/workout/enums/workout_type.dart`
- Create: `lib/domain/workout/enums/user_feedback.dart`
- Create: `lib/domain/workout/enums/energy_level.dart`
- Create: `test/domain/workout/enums/workout_type_test.dart`

- [ ] **Step 1: Write test for WorkoutType enum**

Create: `test/domain/workout/enums/workout_type_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_companion/domain/workout/enums/workout_type.dart';

void main() {
  group('WorkoutType', () {
    test('should have all expected workout types', () {
      expect(WorkoutType.values.length, 6);
      expect(WorkoutType.values.contains(WorkoutType.strength), true);
      expect(WorkoutType.values.contains(WorkoutType.lowImpact), true);
      expect(WorkoutType.values.contains(WorkoutType.core), true);
      expect(WorkoutType.values.contains(WorkoutType.stretching), true);
      expect(WorkoutType.values.contains(WorkoutType.mobility), true);
      expect(WorkoutType.values.contains(WorkoutType.recovery), true);
    });

    test('should convert to string correctly', () {
      expect(WorkoutType.strength.name, 'strength');
      expect(WorkoutType.lowImpact.name, 'lowImpact');
      expect(WorkoutType.core.name, 'core');
    });

    test('should parse from string correctly', () {
      expect(WorkoutType.values.byName('strength'), WorkoutType.strength);
      expect(WorkoutType.values.byName('lowImpact'), WorkoutType.lowImpact);
      expect(WorkoutType.values.byName('core'), WorkoutType.core);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/domain/workout/enums/workout_type_test.dart
```

Expected: FAIL - "Target of URI doesn't exist"

- [ ] **Step 3: Create WorkoutType enum**

Create: `lib/domain/workout/enums/workout_type.dart`

```dart
/// Represents different types of workouts available in the app.
enum WorkoutType {
  /// Resistance exercises (squats, lunges, arm work)
  strength,

  /// Gentle cardio (walking, marching)
  lowImpact,

  /// Ab and core strengthening
  core,

  /// Full body flexibility work
  stretching,

  /// Joint mobility and movement prep
  mobility,

  /// Gentle active recovery
  recovery,
}

/// Extension methods for WorkoutType
extension WorkoutTypeExtension on WorkoutType {
  /// Get human-readable display name
  String get displayName {
    switch (this) {
      case WorkoutType.strength:
        return 'Strength Training';
      case WorkoutType.lowImpact:
        return 'Low Impact Cardio';
      case WorkoutType.core:
        return 'Core Workout';
      case WorkoutType.stretching:
        return 'Full Body Stretch';
      case WorkoutType.mobility:
        return 'Mobility Flow';
      case WorkoutType.recovery:
        return 'Active Recovery';
    }
  }

  /// Check if workout type is recovery-focused
  bool get isRecovery {
    return this == WorkoutType.recovery ||
        this == WorkoutType.stretching ||
        this == WorkoutType.mobility;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/domain/workout/enums/workout_type_test.dart
```

Expected: PASS (all tests green)

- [ ] **Step 5: Write test for UserFeedback enum**

Create: `test/domain/workout/enums/user_feedback_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_companion/domain/workout/enums/user_feedback.dart';

void main() {
  group('UserFeedback', () {
    test('should have all expected feedback types', () {
      expect(UserFeedback.values.length, 4);
      expect(UserFeedback.values.contains(UserFeedback.tooEasy), true);
      expect(UserFeedback.values.contains(UserFeedback.perfect), true);
      expect(UserFeedback.values.contains(UserFeedback.tooHard), true);
      expect(UserFeedback.values.contains(UserFeedback.skipped), true);
    });

    test('should identify positive feedback', () {
      expect(UserFeedback.tooEasy.isPositive, true);
      expect(UserFeedback.perfect.isPositive, true);
      expect(UserFeedback.tooHard.isPositive, false);
      expect(UserFeedback.skipped.isPositive, false);
    });

    test('should identify negative feedback', () {
      expect(UserFeedback.tooHard.isNegative, true);
      expect(UserFeedback.skipped.isNegative, true);
      expect(UserFeedback.perfect.isNegative, false);
    });
  });
}
```

- [ ] **Step 6: Run test to verify it fails**

```bash
flutter test test/domain/workout/enums/user_feedback_test.dart
```

Expected: FAIL - "Target of URI doesn't exist"

- [ ] **Step 7: Create UserFeedback enum**

Create: `lib/domain/workout/enums/user_feedback.dart`

```dart
/// User's feedback about workout difficulty.
enum UserFeedback {
  /// Workout was not challenging enough
  tooEasy,

  /// Workout was just right
  perfect,

  /// Workout was too challenging
  tooHard,

  /// User did not complete workout
  skipped,
}

/// Extension methods for UserFeedback
extension UserFeedbackExtension on UserFeedback {
  /// Check if feedback is positive (easy or perfect)
  bool get isPositive {
    return this == UserFeedback.tooEasy || this == UserFeedback.perfect;
  }

  /// Check if feedback is negative (hard or skipped)
  bool get isNegative {
    return this == UserFeedback.tooHard || this == UserFeedback.skipped;
  }

  /// Get human-readable display text
  String get displayText {
    switch (this) {
      case UserFeedback.tooEasy:
        return 'Too Easy';
      case UserFeedback.perfect:
        return 'Perfect';
      case UserFeedback.tooHard:
        return 'Too Hard';
      case UserFeedback.skipped:
        return 'Skipped';
    }
  }
}
```

- [ ] **Step 8: Run test to verify it passes**

```bash
flutter test test/domain/workout/enums/user_feedback_test.dart
```

Expected: PASS

- [ ] **Step 9: Write test for EnergyLevel enum**

Create: `test/domain/workout/enums/energy_level_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_companion/domain/workout/enums/energy_level.dart';

void main() {
  group('EnergyLevel', () {
    test('should have all expected energy levels', () {
      expect(EnergyLevel.values.length, 3);
      expect(EnergyLevel.values.contains(EnergyLevel.energized), true);
      expect(EnergyLevel.values.contains(EnergyLevel.tired), true);
      expect(EnergyLevel.values.contains(EnergyLevel.exhausted), true);
    });

    test('should convert to string correctly', () {
      expect(EnergyLevel.energized.name, 'energized');
      expect(EnergyLevel.tired.name, 'tired');
      expect(EnergyLevel.exhausted.name, 'exhausted');
    });
  });
}
```

- [ ] **Step 10: Run test to verify it fails**

```bash
flutter test test/domain/workout/enums/energy_level_test.dart
```

Expected: FAIL

- [ ] **Step 11: Create EnergyLevel enum**

Create: `lib/domain/workout/enums/energy_level.dart`

```dart
/// User's energy level after completing a workout.
enum EnergyLevel {
  /// Feeling great after workout
  energized,

  /// Normally tired after workout
  tired,

  /// Too exhausted, might be overdoing it
  exhausted,
}

/// Extension methods for EnergyLevel
extension EnergyLevelExtension on EnergyLevel {
  /// Get human-readable display text
  String get displayText {
    switch (this) {
      case EnergyLevel.energized:
        return 'Energized';
      case EnergyLevel.tired:
        return 'Tired';
      case EnergyLevel.exhausted:
        return 'Exhausted';
    }
  }

  /// Check if energy level indicates overtraining
  bool get indicatesOvertraining {
    return this == EnergyLevel.exhausted;
  }
}
```

- [ ] **Step 12: Run test to verify it passes**

```bash
flutter test test/domain/workout/enums/energy_level_test.dart
```

Expected: PASS

- [ ] **Step 13: Commit enums**

```bash
git add lib/domain/workout/enums/ test/domain/workout/enums/
git commit -m "feat(workout): add workout domain enums

- Add WorkoutType enum with 6 types
- Add UserFeedback enum with positive/negative helpers
- Add EnergyLevel enum with overtraining detection
- All enums fully tested

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 2: Domain Layer - Workout Log Entity

**Files:**
- Create: `lib/domain/workout/entities/workout_log.dart`
- Create: `test/domain/workout/entities/workout_log_test.dart`

- [ ] **Step 1: Write test for WorkoutLog entity**

Create: `test/domain/workout/entities/workout_log_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_companion/domain/workout/entities/workout_log.dart';
import 'package:ai_health_companion/domain/workout/enums/workout_type.dart';
import 'package:ai_health_companion/domain/workout/enums/user_feedback.dart';
import 'package:ai_health_companion/domain/workout/enums/energy_level.dart';

void main() {
  group('WorkoutLog', () {
    final testDate = DateTime(2026, 7, 3, 10, 30);

    test('should create workout log with required fields', () {
      final log = WorkoutLog(
        id: 'test-id',
        userId: 'user-123',
        workoutName: 'Deepthi Beginner Low Impact 30min',
        workoutType: WorkoutType.lowImpact,
        durationMinutes: 30,
        difficultyLevel: 2,
        completedAt: testDate,
        createdAt: testDate,
      );

      expect(log.id, 'test-id');
      expect(log.userId, 'user-123');
      expect(log.workoutName, 'Deepthi Beginner Low Impact 30min');
      expect(log.workoutType, WorkoutType.lowImpact);
      expect(log.durationMinutes, 30);
      expect(log.difficultyLevel, 2);
      expect(log.feedback, null);
      expect(log.energyLevelAfter, null);
      expect(log.completedAt, testDate);
    });

    test('should create workout log with optional fields', () {
      final log = WorkoutLog(
        id: 'test-id',
        userId: 'user-123',
        workoutName: 'Test Workout',
        workoutType: WorkoutType.core,
        durationMinutes: 25,
        difficultyLevel: 5,
        feedback: UserFeedback.perfect,
        energyLevelAfter: EnergyLevel.energized,
        completedAt: testDate,
        createdAt: testDate,
      );

      expect(log.feedback, UserFeedback.perfect);
      expect(log.energyLevelAfter, EnergyLevel.energized);
    });

    test('should support equality comparison', () {
      final log1 = WorkoutLog(
        id: 'test-id',
        userId: 'user-123',
        workoutName: 'Test',
        workoutType: WorkoutType.strength,
        durationMinutes: 30,
        difficultyLevel: 3,
        completedAt: testDate,
        createdAt: testDate,
      );

      final log2 = WorkoutLog(
        id: 'test-id',
        userId: 'user-123',
        workoutName: 'Test',
        workoutType: WorkoutType.strength,
        durationMinutes: 30,
        difficultyLevel: 3,
        completedAt: testDate,
        createdAt: testDate,
      );

      expect(log1, equals(log2));
      expect(log1.hashCode, equals(log2.hashCode));
    });

    test('should create copy with updated fields', () {
      final original = WorkoutLog(
        id: 'test-id',
        userId: 'user-123',
        workoutName: 'Test',
        workoutType: WorkoutType.core,
        durationMinutes: 30,
        difficultyLevel: 4,
        completedAt: testDate,
        createdAt: testDate,
      );

      final updated = original.copyWith(
        feedback: UserFeedback.perfect,
        energyLevelAfter: EnergyLevel.energized,
      );

      expect(updated.id, original.id);
      expect(updated.feedback, UserFeedback.perfect);
      expect(updated.energyLevelAfter, EnergyLevel.energized);
      expect(updated.workoutName, original.workoutName);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/domain/workout/entities/workout_log_test.dart
```

Expected: FAIL - "Target of URI doesn't exist"

- [ ] **Step 3: Create WorkoutLog entity**

Create: `lib/domain/workout/entities/workout_log.dart`

```dart
import 'package:equatable/equatable.dart';
import '../enums/workout_type.dart';
import '../enums/user_feedback.dart';
import '../enums/energy_level.dart';

/// Represents a completed workout with feedback.
class WorkoutLog extends Equatable {
  /// Unique identifier
  final String id;

  /// User who completed the workout
  final String userId;

  /// Full workout name (e.g., "Deepthi Moderate Core Workout 30min")
  final String workoutName;

  /// Type of workout
  final WorkoutType workoutType;

  /// Duration in minutes (10 or 30)
  final int durationMinutes;

  /// Difficulty level (1-10 scale)
  final int difficultyLevel;

  /// User's feedback about difficulty (optional, set after workout)
  final UserFeedback? feedback;

  /// User's energy level after workout (optional)
  final EnergyLevel? energyLevelAfter;

  /// When the workout was completed
  final DateTime completedAt;

  /// When the log was created
  final DateTime createdAt;

  const WorkoutLog({
    required this.id,
    required this.userId,
    required this.workoutName,
    required this.workoutType,
    required this.durationMinutes,
    required this.difficultyLevel,
    this.feedback,
    this.energyLevelAfter,
    required this.completedAt,
    required this.createdAt,
  });

  /// Create a copy with updated fields
  WorkoutLog copyWith({
    String? id,
    String? userId,
    String? workoutName,
    WorkoutType? workoutType,
    int? durationMinutes,
    int? difficultyLevel,
    UserFeedback? feedback,
    EnergyLevel? energyLevelAfter,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workoutName: workoutName ?? this.workoutName,
      workoutType: workoutType ?? this.workoutType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      feedback: feedback ?? this.feedback,
      energyLevelAfter: energyLevelAfter ?? this.energyLevelAfter,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        workoutName,
        workoutType,
        durationMinutes,
        difficultyLevel,
        feedback,
        energyLevelAfter,
        completedAt,
        createdAt,
      ];
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/domain/workout/entities/workout_log_test.dart
```

Expected: PASS (all tests green)

- [ ] **Step 5: Commit WorkoutLog entity**

```bash
git add lib/domain/workout/entities/workout_log.dart test/domain/workout/entities/workout_log_test.dart
git commit -m "feat(workout): add WorkoutLog entity

- Immutable entity with equatable support
- All fields required except feedback and energy level
- Includes copyWith for updates
- Fully tested with equality and copy tests

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 3: Domain Layer - User Fitness Profile Entity

**Files:**
- Create: `lib/domain/workout/entities/user_fitness_profile.dart`
- Create: `test/domain/workout/entities/user_fitness_profile_test.dart`

- [ ] **Step 1: Write test for UserFitnessProfile entity**

Create: `test/domain/workout/entities/user_fitness_profile_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_companion/domain/workout/entities/user_fitness_profile.dart';

void main() {
  group('UserFitnessProfile', () {
    final testDate = DateTime(2026, 7, 3);

    test('should create profile with default values', () {
      final profile = UserFitnessProfile(
        userId: 'user-123',
        overallFitnessLevel: 1,
        strengthLevel: 1,
        coreLevel: 1,
        cardioLevel: 1,
        flexibilityLevel: 1,
        preferredDuration: 30,
        availableDurations: [10, 30],
        totalWorkoutsCompleted: 0,
        currentWeek: 1,
        consecutiveWorkoutDays: 0,
        needsRecoveryDay: false,
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(profile.userId, 'user-123');
      expect(profile.overallFitnessLevel, 1);
      expect(profile.strengthLevel, 1);
      expect(profile.totalWorkoutsCompleted, 0);
      expect(profile.needsRecoveryDay, false);
    });

    test('should calculate overall fitness from specific levels', () {
      final profile = UserFitnessProfile(
        userId: 'user-123',
        overallFitnessLevel: 1,
        strengthLevel: 4,
        coreLevel: 6,
        cardioLevel: 5,
        flexibilityLevel: 3,
        preferredDuration: 30,
        availableDurations: [10, 30],
        totalWorkoutsCompleted: 20,
        currentWeek: 5,
        consecutiveWorkoutDays: 2,
        needsRecoveryDay: false,
        createdAt: testDate,
        updatedAt: testDate,
      );

      final calculated = profile.calculateOverallFitness();
      // (4 + 6 + 5 + 3) / 4 = 4.5 → rounds to 5
      expect(calculated, 5);
    });

    test('should create copy with updated fitness levels', () {
      final original = UserFitnessProfile(
        userId: 'user-123',
        overallFitnessLevel: 3,
        strengthLevel: 3,
        coreLevel: 3,
        cardioLevel: 3,
        flexibilityLevel: 3,
        preferredDuration: 30,
        availableDurations: [10, 30],
        totalWorkoutsCompleted: 15,
        currentWeek: 4,
        consecutiveWorkoutDays: 1,
        needsRecoveryDay: false,
        createdAt: testDate,
        updatedAt: testDate,
      );

      final updated = original.copyWith(
        strengthLevel: 4,
        totalWorkoutsCompleted: 16,
        consecutiveWorkoutDays: 2,
      );

      expect(updated.strengthLevel, 4);
      expect(updated.totalWorkoutsCompleted, 16);
      expect(updated.consecutiveWorkoutDays, 2);
      expect(updated.coreLevel, original.coreLevel);
    });

    test('should support equality comparison', () {
      final profile1 = UserFitnessProfile(
        userId: 'user-123',
        overallFitnessLevel: 2,
        strengthLevel: 2,
        coreLevel: 2,
        cardioLevel: 2,
        flexibilityLevel: 2,
        preferredDuration: 30,
        availableDurations: [10, 30],
        totalWorkoutsCompleted: 10,
        currentWeek: 3,
        consecutiveWorkoutDays: 0,
        needsRecoveryDay: false,
        createdAt: testDate,
        updatedAt: testDate,
      );

      final profile2 = UserFitnessProfile(
        userId: 'user-123',
        overallFitnessLevel: 2,
        strengthLevel: 2,
        coreLevel: 2,
        cardioLevel: 2,
        flexibilityLevel: 2,
        preferredDuration: 30,
        availableDurations: [10, 30],
        totalWorkoutsCompleted: 10,
        currentWeek: 3,
        consecutiveWorkoutDays: 0,
        needsRecoveryDay: false,
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(profile1, equals(profile2));
      expect(profile1.hashCode, equals(profile2.hashCode));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/domain/workout/entities/user_fitness_profile_test.dart
```

Expected: FAIL

- [ ] **Step 3: Create UserFitnessProfile entity**

Create: `lib/domain/workout/entities/user_fitness_profile.dart`

```dart
import 'package:equatable/equatable.dart';

/// Tracks user's current fitness levels and progression state.
class UserFitnessProfile extends Equatable {
  /// User identifier
  final String userId;

  /// Overall fitness level (1-10, average of specific levels)
  final int overallFitnessLevel;

  /// Strength training fitness level (1-10)
  final int strengthLevel;

  /// Core workout fitness level (1-10)
  final int coreLevel;

  /// Cardio/low-impact fitness level (1-10)
  final int cardioLevel;

  /// Flexibility/mobility fitness level (1-10)
  final int flexibilityLevel;

  /// Preferred workout duration in minutes (default: 30)
  final int preferredDuration;

  /// Available time slots in minutes (e.g., [10, 30])
  final List<int> availableDurations;

  /// Total number of workouts completed (lifetime)
  final int totalWorkoutsCompleted;

  /// Current week in progressive overload program (1-∞)
  final int currentWeek;

  /// Date of last fitness level increase (null if never increased)
  final DateTime? lastDifficultyIncrease;

  /// Date of most recent workout (null if no workouts yet)
  final DateTime? lastWorkoutDate;

  /// How many days in a row user has worked out
  final int consecutiveWorkoutDays;

  /// Flag indicating recovery day is needed
  final bool needsRecoveryDay;

  /// When profile was created
  final DateTime createdAt;

  /// When profile was last updated
  final DateTime updatedAt;

  const UserFitnessProfile({
    required this.userId,
    required this.overallFitnessLevel,
    required this.strengthLevel,
    required this.coreLevel,
    required this.cardioLevel,
    required this.flexibilityLevel,
    required this.preferredDuration,
    required this.availableDurations,
    required this.totalWorkoutsCompleted,
    required this.currentWeek,
    this.lastDifficultyIncrease,
    this.lastWorkoutDate,
    required this.consecutiveWorkoutDays,
    required this.needsRecoveryDay,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate overall fitness level from specific levels
  int calculateOverallFitness() {
    final average = (strengthLevel + coreLevel + cardioLevel + flexibilityLevel) / 4;
    return average.round();
  }

  /// Create a copy with updated fields
  UserFitnessProfile copyWith({
    String? userId,
    int? overallFitnessLevel,
    int? strengthLevel,
    int? coreLevel,
    int? cardioLevel,
    int? flexibilityLevel,
    int? preferredDuration,
    List<int>? availableDurations,
    int? totalWorkoutsCompleted,
    int? currentWeek,
    DateTime? lastDifficultyIncrease,
    DateTime? lastWorkoutDate,
    int? consecutiveWorkoutDays,
    bool? needsRecoveryDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserFitnessProfile(
      userId: userId ?? this.userId,
      overallFitnessLevel: overallFitnessLevel ?? this.overallFitnessLevel,
      strengthLevel: strengthLevel ?? this.strengthLevel,
      coreLevel: coreLevel ?? this.coreLevel,
      cardioLevel: cardioLevel ?? this.cardioLevel,
      flexibilityLevel: flexibilityLevel ?? this.flexibilityLevel,
      preferredDuration: preferredDuration ?? this.preferredDuration,
      availableDurations: availableDurations ?? this.availableDurations,
      totalWorkoutsCompleted: totalWorkoutsCompleted ?? this.totalWorkoutsCompleted,
      currentWeek: currentWeek ?? this.currentWeek,
      lastDifficultyIncrease: lastDifficultyIncrease ?? this.lastDifficultyIncrease,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      consecutiveWorkoutDays: consecutiveWorkoutDays ?? this.consecutiveWorkoutDays,
      needsRecoveryDay: needsRecoveryDay ?? this.needsRecoveryDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        overallFitnessLevel,
        strengthLevel,
        coreLevel,
        cardioLevel,
        flexibilityLevel,
        preferredDuration,
        availableDurations,
        totalWorkoutsCompleted,
        currentWeek,
        lastDifficultyIncrease,
        lastWorkoutDate,
        consecutiveWorkoutDays,
        needsRecoveryDay,
        createdAt,
        updatedAt,
      ];
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/domain/workout/entities/user_fitness_profile_test.dart
```

Expected: PASS

- [ ] **Step 5: Commit UserFitnessProfile entity**

```bash
git add lib/domain/workout/entities/user_fitness_profile.dart test/domain/workout/entities/user_fitness_profile_test.dart
git commit -m "feat(workout): add UserFitnessProfile entity

- Tracks fitness levels (overall, strength, core, cardio, flexibility)
- Stores progression state (week, workouts, consecutive days)
- Includes calculateOverallFitness helper method
- Fully tested with equality and copy tests

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 4: Domain Layer - Recommendation & Analytics Entities

**Files:**
- Create: `lib/domain/workout/entities/workout_recommendation.dart`
- Create: `lib/domain/workout/entities/weekly_summary.dart`
- Create: `lib/domain/workout/entities/monthly_progress.dart`
- Create: `lib/domain/workout/entities/recovery_assessment.dart`
- Create: `test/domain/workout/entities/workout_recommendation_test.dart`

- [ ] **Step 1: Write test for WorkoutRecommendation**

Create: `test/domain/workout/entities/workout_recommendation_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_companion/domain/workout/entities/workout_recommendation.dart';
import 'package:ai_health_companion/domain/workout/enums/workout_type.dart';

void main() {
  group('WorkoutRecommendation', () {
    test('should create recommendation with all fields', () {
      final recommendation = WorkoutRecommendation(
        workoutType: WorkoutType.core,
        difficultyLevel: 4,
        workoutName: 'Deepthi Moderate Core Workout 30min',
        durationMinutes: 30,
        reasoning: 'Building on your recent low impact work',
      );

      expect(recommendation.workoutType, WorkoutType.core);
      expect(recommendation.difficultyLevel, 4);
      expect(recommendation.workoutName, 'Deepthi Moderate Core Workout 30min');
      expect(recommendation.durationMinutes, 30);
      expect(recommendation.reasoning, 'Building on your recent low impact work');
    });

    test('should support equality comparison', () {
      final rec1 = WorkoutRecommendation(
        workoutType: WorkoutType.strength,
        difficultyLevel: 5,
        workoutName: 'Test Workout',
        durationMinutes: 30,
        reasoning: 'Test reason',
      );

      final rec2 = WorkoutRecommendation(
        workoutType: WorkoutType.strength,
        difficultyLevel: 5,
        workoutName: 'Test Workout',
        durationMinutes: 30,
        reasoning: 'Test reason',
      );

      expect(rec1, equals(rec2));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/domain/workout/entities/workout_recommendation_test.dart
```

Expected: FAIL

- [ ] **Step 3: Create WorkoutRecommendation entity**

Create: `lib/domain/workout/entities/workout_recommendation.dart`

```dart
import 'package:equatable/equatable.dart';
import '../enums/workout_type.dart';

/// Result of workout recommendation algorithm.
class WorkoutRecommendation extends Equatable {
  /// Type of workout to perform
  final WorkoutType workoutType;

  /// Difficulty level (1-10 scale)
  final int difficultyLevel;

  /// Full workout name (e.g., "Deepthi Moderate Core Workout 30min")
  final String workoutName;

  /// Duration in minutes
  final int durationMinutes;

  /// Brief explanation of why this workout was recommended
  final String reasoning;

  const WorkoutRecommendation({
    required this.workoutType,
    required this.difficultyLevel,
    required this.workoutName,
    required this.durationMinutes,
    required this.reasoning,
  });

  @override
  List<Object?> get props => [
        workoutType,
        difficultyLevel,
        workoutName,
        durationMinutes,
        reasoning,
      ];
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/domain/workout/entities/workout_recommendation_test.dart
```

Expected: PASS

- [ ] **Step 5: Create WeeklySummary entity**

Create: `lib/domain/workout/entities/weekly_summary.dart`

```dart
import 'package:equatable/equatable.dart';
import '../enums/workout_type.dart';

/// Summary of workouts completed this week.
class WeeklySummary extends Equatable {
  /// Total number of workouts this week
  final int totalWorkouts;

  /// Total minutes exercised this week
  final int totalMinutes;

  /// Count of each workout type
  final Map<WorkoutType, int> typeCounts;

  /// Workout types not done this week (for variety)
  final List<WorkoutType> missingTypes;

  /// Start of current week (Monday)
  final DateTime weekStart;

  const WeeklySummary({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.typeCounts,
    required this.missingTypes,
    required this.weekStart,
  });

  @override
  List<Object?> get props => [
        totalWorkouts,
        totalMinutes,
        typeCounts,
        missingTypes,
        weekStart,
      ];
}
```

- [ ] **Step 6: Create MonthlyProgress entity**

Create: `lib/domain/workout/entities/monthly_progress.dart`

```dart
import 'package:equatable/equatable.dart';
import '../enums/workout_type.dart';

/// Summary of workout progress for the current month.
class MonthlyProgress extends Equatable {
  /// Total workouts completed this month
  final int totalWorkouts;

  /// Total minutes exercised this month
  final int totalMinutes;

  /// Average workouts per week
  final double avgWorkoutsPerWeek;

  /// Distribution of workout types
  final Map<WorkoutType, int> typeDistribution;

  /// Current fitness level
  final int currentFitnessLevel;

  /// How much fitness level increased this month
  final int fitnessLevelIncrease;

  /// Longest consecutive workout streak (days)
  final int longestStreak;

  const MonthlyProgress({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.avgWorkoutsPerWeek,
    required this.typeDistribution,
    required this.currentFitnessLevel,
    required this.fitnessLevelIncrease,
    required this.longestStreak,
  });

  @override
  List<Object?> get props => [
        totalWorkouts,
        totalMinutes,
        avgWorkoutsPerWeek,
        typeDistribution,
        currentFitnessLevel,
        fitnessLevelIncrease,
        longestStreak,
      ];
}
```

- [ ] **Step 7: Create RecoveryAssessment entity**

Create: `lib/domain/workout/entities/recovery_assessment.dart`

```dart
import 'package:equatable/equatable.dart';

/// Assessment of whether user needs recovery.
class RecoveryAssessment extends Equatable {
  /// User needs complete rest day
  final bool needsFullRest;

  /// User needs active recovery (light stretching/mobility)
  final bool needsActiveRecovery;

  /// Number of consecutive workout days
  final int consecutiveWorkoutDays;

  /// Average intensity of recent workouts (1-10)
  final double recentIntensity;

  /// Total minutes exercised this week
  final int weeklyVolumeMinutes;

  /// Human-readable recommendation
  final String recommendation;

  const RecoveryAssessment({
    required this.needsFullRest,
    required this.needsActiveRecovery,
    required this.consecutiveWorkoutDays,
    required this.recentIntensity,
    required this.weeklyVolumeMinutes,
    required this.recommendation,
  });

  @override
  List<Object?> get props => [
        needsFullRest,
        needsActiveRecovery,
        consecutiveWorkoutDays,
        recentIntensity,
        weeklyVolumeMinutes,
        recommendation,
      ];
}
```

- [ ] **Step 8: Commit recommendation and analytics entities**

```bash
git add lib/domain/workout/entities/ test/domain/workout/entities/
git commit -m "feat(workout): add recommendation and analytics entities

- WorkoutRecommendation: algorithm output with reasoning
- WeeklySummary: weekly workout statistics
- MonthlyProgress: monthly progress tracking
- RecoveryAssessment: recovery need evaluation
- All entities immutable with equatable

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 5: Domain Layer - Repository Interface

**Files:**
- Create: `lib/domain/workout/repositories/workout_repository.dart`

- [ ] **Step 1: Create WorkoutRepository interface**

Create: `lib/domain/workout/repositories/workout_repository.dart`

```dart
import '../entities/workout_log.dart';
import '../entities/user_fitness_profile.dart';
import '../entities/workout_recommendation.dart';
import '../entities/weekly_summary.dart';
import '../entities/monthly_progress.dart';
import '../entities/recovery_assessment.dart';
import '../enums/workout_type.dart';

/// Repository interface for workout-related operations.
abstract class WorkoutRepository {
  // === Workout Logs ===

  /// Save a completed workout log
  Future<void> saveWorkoutLog(WorkoutLog log);

  /// Get workout log by ID
  Future<WorkoutLog?> getWorkoutLog(String id);

  /// Get all workout logs for a user
  Future<List<WorkoutLog>> getWorkoutLogs(String userId);

  /// Get recent workout logs (last N days)
  Future<List<WorkoutLog>> getRecentWorkoutLogs(String userId, int days);

  /// Get workout logs by type
  Future<List<WorkoutLog>> getWorkoutLogsByType(
    String userId,
    WorkoutType type, {
    int? count,
  });

  /// Get workouts since a specific date
  Future<List<WorkoutLog>> getWorkoutsSince(String userId, DateTime since);

  /// Delete a workout log
  Future<void> deleteWorkoutLog(String id);

  // === User Fitness Profile ===

  /// Get user's fitness profile
  Future<UserFitnessProfile?> getFitnessProfile(String userId);

  /// Save or update fitness profile
  Future<void> saveFitnessProfile(UserFitnessProfile profile);

  /// Create initial fitness profile for new user
  Future<void> createInitialProfile(String userId);

  /// Update fitness level after workout
  Future<void> updateFitnessLevel(
    String userId,
    WorkoutType type,
    int newLevel,
  );

  // === Analytics ===

  /// Get weekly workout summary
  Future<WeeklySummary> getWeeklySummary(String userId);

  /// Get monthly progress statistics
  Future<MonthlyProgress> getMonthlyProgress(String userId);

  /// Assess recovery needs
  Future<RecoveryAssessment> assessRecoveryNeeds(String userId);

  // === Recommendations ===

  /// Get workout recommendation
  Future<WorkoutRecommendation> getWorkoutRecommendation(
    String userId, {
    int? availableTimeMinutes,
  });
}
```

- [ ] **Step 2: Commit repository interface**

```bash
git add lib/domain/workout/repositories/workout_repository.dart
git commit -m "feat(workout): add WorkoutRepository interface

- Define contract for workout data operations
- Methods for logs, profile, analytics, recommendations
- No implementation yet (will be in data layer)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 6: Data Layer - Drift Database Tables

**Files:**
- Create: `lib/data/workout/models/workout_database.dart`
- Create: `test/data/workout/models/workout_database_test.dart`

- [ ] **Step 1: Write test for Drift tables**

Create: `test/data/workout/models/workout_database_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:ai_health_companion/data/workout/models/workout_database.dart';

void main() {
  group('WorkoutDatabase', () {
    late WorkoutDatabase database;

    setUp(() {
      database = WorkoutDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('should create database with workout_logs table', () async {
      // Insert a test workout log
      await database.into(database.workoutLogs).insert(
            WorkoutLogsCompanion.insert(
              id: 'test-id',
              userId: 'user-123',
              workoutName: 'Test Workout',
              workoutType: 'lowImpact',
              durationMinutes: 30,
              difficultyLevel: 2,
              completedAt: DateTime.now(),
              createdAt: DateTime.now(),
            ),
          );

      // Query it back
      final logs = await database.select(database.workoutLogs).get();
      expect(logs.length, 1);
      expect(logs.first.id, 'test-id');
      expect(logs.first.workoutType, 'lowImpact');
    });

    test('should create database with user_fitness_profiles table', () async {
      final now = DateTime.now();

      // Insert a test profile
      await database.into(database.userFitnessProfiles).insert(
            UserFitnessProfilesCompanion.insert(
              userId: 'user-123',
              overallFitnessLevel: 1,
              strengthLevel: 1,
              coreLevel: 1,
              cardioLevel: 1,
              flexibilityLevel: 1,
              preferredDuration: 30,
              availableDurations: '[10,30]',
              totalWorkoutsCompleted: 0,
              currentWeek: 1,
              consecutiveWorkoutDays: 0,
              needsRecoveryDay: false,
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Query it back
      final profiles = await database.select(database.userFitnessProfiles).get();
      expect(profiles.length, 1);
      expect(profiles.first.userId, 'user-123');
      expect(profiles.first.overallFitnessLevel, 1);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/data/workout/models/workout_database_test.dart
```

Expected: FAIL

- [ ] **Step 3: Create Drift database with tables**

Create: `lib/data/workout/models/workout_database.dart`

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'workout_database.g.dart';

/// Workout logs table
@DataClassName('WorkoutLogData')
class WorkoutLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get workoutName => text()();
  TextColumn get workoutType => text()();
  IntColumn get durationMinutes => integer()();
  IntColumn get difficultyLevel => integer()();
  TextColumn get feedback => text().nullable()();
  TextColumn get energyLevelAfter => text().nullable()();
  DateTimeColumn get completedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// User fitness profiles table
@DataClassName('UserFitnessProfileData')
class UserFitnessProfiles extends Table {
  TextColumn get userId => text()();
  IntColumn get overallFitnessLevel => integer()();
  IntColumn get strengthLevel => integer()();
  IntColumn get coreLevel => integer()();
  IntColumn get cardioLevel => integer()();
  IntColumn get flexibilityLevel => integer()();
  IntColumn get preferredDuration => integer()();
  TextColumn get availableDurations => text()(); // JSON array string
  IntColumn get totalWorkoutsCompleted => integer()();
  IntColumn get currentWeek => integer()();
  DateTimeColumn get lastDifficultyIncrease => dateTime().nullable()();
  DateTimeColumn get lastWorkoutDate => dateTime().nullable()();
  IntColumn get consecutiveWorkoutDays => integer()();
  BoolColumn get needsRecoveryDay => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

/// Main database class
@DriftDatabase(tables: [WorkoutLogs, UserFitnessProfiles])
class WorkoutDatabase extends _$WorkoutDatabase {
  WorkoutDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();

          // Create indexes for better query performance
          await customStatement(
            'CREATE INDEX idx_workout_logs_user_date ON workout_logs(user_id, completed_at DESC);',
          );
          await customStatement(
            'CREATE INDEX idx_workout_logs_type ON workout_logs(user_id, workout_type);',
          );
        },
      );
}

/// LazyDatabase opener for production use
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'workout_db.sqlite'));
    return NativeDatabase(file);
  });
}

/// Singleton instance
final workoutDatabase = WorkoutDatabase(_openConnection());
```

- [ ] **Step 4: Generate Drift code**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: Generates `workout_database.g.dart`

- [ ] **Step 5: Run test to verify it passes**

```bash
flutter test test/data/workout/models/workout_database_test.dart
```

Expected: PASS

- [ ] **Step 6: Commit Drift database**

```bash
git add lib/data/workout/models/workout_database.dart lib/data/workout/models/workout_database.g.dart test/data/workout/models/workout_database_test.dart
git commit -m "feat(workout): add Drift database tables

- WorkoutLogs table with all workout fields
- UserFitnessProfiles table with fitness tracking
- Indexes for performance (user_date, type)
- Migration strategy with schema version 1
- Tests verify table creation and basic operations

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 7: Data Layer - Model Converters

**Files:**
- Create: `lib/data/workout/models/workout_log_model.dart`
- Create: `lib/data/workout/models/user_fitness_profile_model.dart`
- Create: `test/data/workout/models/workout_log_model_test.dart`
- Create: `test/data/workout/models/user_fitness_profile_model_test.dart`

- [ ] **Step 1: Write test for WorkoutLogModel converter**

Create: `test/data/workout/models/workout_log_model_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_companion/data/workout/models/workout_log_model.dart';
import 'package:ai_health_companion/data/workout/models/workout_database.dart';
import 'package:ai_health_companion/domain/workout/entities/workout_log.dart';
import 'package:ai_health_companion/domain/workout/enums/workout_type.dart';
import 'package:ai_health_companion/domain/workout/enums/user_feedback.dart';
import 'package:ai_health_companion/domain/workout/enums/energy_level.dart';

void main() {
  group('WorkoutLogModel', () {
    final testDate = DateTime(2026, 7, 3, 10, 30);

    test('should convert entity to Drift data', () {
      final entity = WorkoutLog(
        id: 'test-id',
        userId: 'user-123',
        workoutName: 'Deepthi Beginner Low Impact 30min',
        workoutType: WorkoutType.lowImpact,
        durationMinutes: 30,
        difficultyLevel: 2,
        feedback: UserFeedback.perfect,
        energyLevelAfter: EnergyLevel.energized,
        completedAt: testDate,
        createdAt: testDate,
      );

      final driftData = WorkoutLogModel.toData(entity);

      expect(driftData.id, 'test-id');
      expect(driftData.userId, 'user-123');
      expect(driftData.workoutType, 'lowImpact');
      expect(driftData.feedback, 'perfect');
      expect(driftData.energyLevelAfter, 'energized');
    });

    test('should convert Drift data to entity', () {
      final driftData = WorkoutLogData(
        id: 'test-id',
        userId: 'user-123',
        workoutName: 'Test Workout',
        workoutType: 'core',
        durationMinutes: 25,
        difficultyLevel: 4,
        feedback: 'tooHard',
        energyLevelAfter: 'tired',
        completedAt: testDate,
        createdAt: testDate,
      );

      final entity = WorkoutLogModel.toEntity(driftData);

      expect(entity.id, 'test-id');
      expect(entity.workoutType, WorkoutType.core);
      expect(entity.feedback, UserFeedback.tooHard);
      expect(entity.energyLevelAfter, EnergyLevel.tired);
    });

    test('should handle null optional fields', () {
      final driftData = WorkoutLogData(
        id: 'test-id',
        userId: 'user-123',
        workoutName: 'Test',
        workoutType: 'strength',
        durationMinutes: 30,
        difficultyLevel: 3,
        feedback: null,
        energyLevelAfter: null,
        completedAt: testDate,
        createdAt: testDate,
      );

      final entity = WorkoutLogModel.toEntity(driftData);

      expect(entity.feedback, null);
      expect(entity.energyLevelAfter, null);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/data/workout/models/workout_log_model_test.dart
```

Expected: FAIL

- [ ] **Step 3: Create WorkoutLogModel converter**

Create: `lib/data/workout/models/workout_log_model.dart`

```dart
import '../../../domain/workout/entities/workout_log.dart';
import '../../../domain/workout/enums/workout_type.dart';
import '../../../domain/workout/enums/user_feedback.dart';
import '../../../domain/workout/enums/energy_level.dart';
import 'workout_database.dart';

/// Converter between WorkoutLog entity and Drift data
class WorkoutLogModel {
  /// Convert entity to Drift data
  static WorkoutLogData toData(WorkoutLog entity) {
    return WorkoutLogData(
      id: entity.id,
      userId: entity.userId,
      workoutName: entity.workoutName,
      workoutType: entity.workoutType.name,
      durationMinutes: entity.durationMinutes,
      difficultyLevel: entity.difficultyLevel,
      feedback: entity.feedback?.name,
      energyLevelAfter: entity.energyLevelAfter?.name,
      completedAt: entity.completedAt,
      createdAt: entity.createdAt,
    );
  }

  /// Convert Drift data to entity
  static WorkoutLog toEntity(WorkoutLogData data) {
    return WorkoutLog(
      id: data.id,
      userId: data.userId,
      workoutName: data.workoutName,
      workoutType: WorkoutType.values.byName(data.workoutType),
      durationMinutes: data.durationMinutes,
      difficultyLevel: data.difficultyLevel,
      feedback: data.feedback != null
          ? UserFeedback.values.byName(data.feedback!)
          : null,
      energyLevelAfter: data.energyLevelAfter != null
          ? EnergyLevel.values.byName(data.energyLevelAfter!)
          : null,
      completedAt: data.completedAt,
      createdAt: data.createdAt,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/data/workout/models/workout_log_model_test.dart
```

Expected: PASS

- [ ] **Step 5: Write test for UserFitnessProfileModel converter**

Create: `test/data/workout/models/user_fitness_profile_model_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_companion/data/workout/models/user_fitness_profile_model.dart';
import 'package:ai_health_companion/data/workout/models/workout_database.dart';
import 'package:ai_health_companion/domain/workout/entities/user_fitness_profile.dart';
import 'dart:convert';

void main() {
  group('UserFitnessProfileModel', () {
    final testDate = DateTime(2026, 7, 3);

    test('should convert entity to Drift data', () {
      final entity = UserFitnessProfile(
        userId: 'user-123',
        overallFitnessLevel: 3,
        strengthLevel: 3,
        coreLevel: 4,
        cardioLevel: 3,
        flexibilityLevel: 2,
        preferredDuration: 30,
        availableDurations: [10, 30],
        totalWorkoutsCompleted: 15,
        currentWeek: 4,
        lastDifficultyIncrease: testDate,
        lastWorkoutDate: testDate,
        consecutiveWorkoutDays: 2,
        needsRecoveryDay: false,
        createdAt: testDate,
        updatedAt: testDate,
      );

      final driftData = UserFitnessProfileModel.toData(entity);

      expect(driftData.userId, 'user-123');
      expect(driftData.overallFitnessLevel, 3);
      expect(driftData.strengthLevel, 3);
      expect(driftData.availableDurations, '[10,30]');
      expect(driftData.consecutiveWorkoutDays, 2);
    });

    test('should convert Drift data to entity', () {
      final driftData = UserFitnessProfileData(
        userId: 'user-123',
        overallFitnessLevel: 2,
        strengthLevel: 2,
        coreLevel: 2,
        cardioLevel: 2,
        flexibilityLevel: 2,
        preferredDuration: 30,
        availableDurations: '[10,20,30]',
        totalWorkoutsCompleted: 10,
        currentWeek: 3,
        lastDifficultyIncrease: testDate,
        lastWorkoutDate: testDate,
        consecutiveWorkoutDays: 1,
        needsRecoveryDay: false,
        createdAt: testDate,
        updatedAt: testDate,
      );

      final entity = UserFitnessProfileModel.toEntity(driftData);

      expect(entity.userId, 'user-123');
      expect(entity.overallFitnessLevel, 2);
      expect(entity.availableDurations, [10, 20, 30]);
      expect(entity.consecutiveWorkoutDays, 1);
    });

    test('should handle null optional fields', () {
      final driftData = UserFitnessProfileData(
        userId: 'user-123',
        overallFitnessLevel: 1,
        strengthLevel: 1,
        coreLevel: 1,
        cardioLevel: 1,
        flexibilityLevel: 1,
        preferredDuration: 30,
        availableDurations: '[10,30]',
        totalWorkoutsCompleted: 0,
        currentWeek: 1,
        lastDifficultyIncrease: null,
        lastWorkoutDate: null,
        consecutiveWorkoutDays: 0,
        needsRecoveryDay: false,
        createdAt: testDate,
        updatedAt: testDate,
      );

      final entity = UserFitnessProfileModel.toEntity(driftData);

      expect(entity.lastDifficultyIncrease, null);
      expect(entity.lastWorkoutDate, null);
    });
  });
}
```

- [ ] **Step 6: Run test to verify it fails**

```bash
flutter test test/data/workout/models/user_fitness_profile_model_test.dart
```

Expected: FAIL

- [ ] **Step 7: Create UserFitnessProfileModel converter**

Create: `lib/data/workout/models/user_fitness_profile_model.dart`

```dart
import 'dart:convert';
import '../../../domain/workout/entities/user_fitness_profile.dart';
import 'workout_database.dart';

/// Converter between UserFitnessProfile entity and Drift data
class UserFitnessProfileModel {
  /// Convert entity to Drift data
  static UserFitnessProfileData toData(UserFitnessProfile entity) {
    return UserFitnessProfileData(
      userId: entity.userId,
      overallFitnessLevel: entity.overallFitnessLevel,
      strengthLevel: entity.strengthLevel,
      coreLevel: entity.coreLevel,
      cardioLevel: entity.cardioLevel,
      flexibilityLevel: entity.flexibilityLevel,
      preferredDuration: entity.preferredDuration,
      availableDurations: jsonEncode(entity.availableDurations),
      totalWorkoutsCompleted: entity.totalWorkoutsCompleted,
      currentWeek: entity.currentWeek,
      lastDifficultyIncrease: entity.lastDifficultyIncrease,
      lastWorkoutDate: entity.lastWorkoutDate,
      consecutiveWorkoutDays: entity.consecutiveWorkoutDays,
      needsRecoveryDay: entity.needsRecoveryDay,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert Drift data to entity
  static UserFitnessProfile toEntity(UserFitnessProfileData data) {
    final durationsList = jsonDecode(data.availableDurations) as List;
    final durations = durationsList.cast<int>();

    return UserFitnessProfile(
      userId: data.userId,
      overallFitnessLevel: data.overallFitnessLevel,
      strengthLevel: data.strengthLevel,
      coreLevel: data.coreLevel,
      cardioLevel: data.cardioLevel,
      flexibilityLevel: data.flexibilityLevel,
      preferredDuration: data.preferredDuration,
      availableDurations: durations,
      totalWorkoutsCompleted: data.totalWorkoutsCompleted,
      currentWeek: data.currentWeek,
      lastDifficultyIncrease: data.lastDifficultyIncrease,
      lastWorkoutDate: data.lastWorkoutDate,
      consecutiveWorkoutDays: data.consecutiveWorkoutDays,
      needsRecoveryDay: data.needsRecoveryDay,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
```

- [ ] **Step 8: Run test to verify it passes**

```bash
flutter test test/data/workout/models/user_fitness_profile_model_test.dart
```

Expected: PASS

- [ ] **Step 9: Commit model converters**

```bash
git add lib/data/workout/models/ test/data/workout/models/
git commit -m "feat(workout): add model converters

- WorkoutLogModel: entity <-> Drift conversion
- UserFitnessProfileModel: entity <-> Drift conversion
- Handle enum conversions (name string)
- Handle JSON arrays (availableDurations)
- Handle null optional fields
- Fully tested with bidirectional conversions

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 8: Data Layer - Local Data Source

**Files:**
- Create: `lib/data/workout/datasources/workout_local_datasource.dart`
- Create: `test/data/workout/datasources/workout_local_datasource_test.dart`

- [ ] **Step 1: Write test for local datasource saveWorkoutLog**

Create: `test/data/workout/datasources/workout_local_datasource_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:ai_health_companion/data/workout/datasources/workout_local_datasource.dart';
import 'package:ai_health_companion/data/workout/models/workout_database.dart';
import 'package:ai_health_companion/domain/workout/entities/workout_log.dart';
import 'package:ai_health_companion/domain/workout/entities/user_fitness_profile.dart';
import 'package:ai_health_companion/domain/workout/enums/workout_type.dart';
import 'package:ai_health_companion/domain/workout/enums/user_feedback.dart';

void main() {
  group('WorkoutLocalDataSource', () {
    late WorkoutDatabase database;
    late WorkoutLocalDataSource dataSource;

    setUp(() {
      database = WorkoutDatabase(NativeDatabase.memory());
      dataSource = WorkoutLocalDataSource(database);
    });

    tearDown(() async {
      await database.close();
    });

    group('saveWorkoutLog', () {
      test('should save workout log to database', () async {
        final testDate = DateTime(2026, 7, 3, 10, 30);
        final log = WorkoutLog(
          id: 'test-id',
          userId: 'user-123',
          workoutName: 'Deepthi Beginner Low Impact 30min',
          workoutType: WorkoutType.lowImpact,
          durationMinutes: 30,
          difficultyLevel: 2,
          feedback: UserFeedback.perfect,
          completedAt: testDate,
          createdAt: testDate,
        );

        await dataSource.saveWorkoutLog(log);

        final saved = await dataSource.getWorkoutLog('test-id');
        expect(saved, isNotNull);
        expect(saved!.id, 'test-id');
        expect(saved.workoutType, WorkoutType.lowImpact);
      });
    });

    group('getRecentWorkoutLogs', () {
      test('should return workouts from last N days', () async {
        final now = DateTime.now();
        final yesterday = now.subtract(Duration(days: 1));
        final twoDaysAgo = now.subtract(Duration(days: 2));
        final eightDaysAgo = now.subtract(Duration(days: 8));

        // Add workouts at different times
        await dataSource.saveWorkoutLog(WorkoutLog(
          id: 'log-1',
          userId: 'user-123',
          workoutName: 'Workout 1',
          workoutType: WorkoutType.core,
          durationMinutes: 30,
          difficultyLevel: 3,
          completedAt: now,
          createdAt: now,
        ));

        await dataSource.saveWorkoutLog(WorkoutLog(
          id: 'log-2',
          userId: 'user-123',
          workoutName: 'Workout 2',
          workoutType: WorkoutType.strength,
          durationMinutes: 30,
          difficultyLevel: 4,
          completedAt: yesterday,
          createdAt: yesterday,
        ));

        await dataSource.saveWorkoutLog(WorkoutLog(
          id: 'log-3',
          userId: 'user-123',
          workoutName: 'Workout 3',
          workoutType: WorkoutType.lowImpact,
          durationMinutes: 30,
          difficultyLevel: 2,
          completedAt: eightDaysAgo,
          createdAt: eightDaysAgo,
        ));

        // Get last 7 days
        final recent = await dataSource.getRecentWorkoutLogs('user-123', 7);

        expect(recent.length, 2); // Only 2 within last 7 days
        expect(recent[0].id, 'log-1'); // Most recent first
        expect(recent[1].id, 'log-2');
      });
    });

    group('saveFitnessProfile', () {
      test('should save fitness profile to database', () async {
        final testDate = DateTime(2026, 7, 3);
        final profile = UserFitnessProfile(
          userId: 'user-123',
          overallFitnessLevel: 3,
          strengthLevel: 3,
          coreLevel: 4,
          cardioLevel: 3,
          flexibilityLevel: 2,
          preferredDuration: 30,
          availableDurations: [10, 30],
          totalWorkoutsCompleted: 15,
          currentWeek: 4,
          consecutiveWorkoutDays: 2,
          needsRecoveryDay: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        await dataSource.saveFitnessProfile(profile);

        final saved = await dataSource.getFitnessProfile('user-123');
        expect(saved, isNotNull);
        expect(saved!.userId, 'user-123');
        expect(saved.overallFitnessLevel, 3);
        expect(saved.totalWorkoutsCompleted, 15);
      });
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/data/workout/datasources/workout_local_datasource_test.dart
```

Expected: FAIL - "Target of URI doesn't exist"

- [ ] **Step 3: Create WorkoutLocalDataSource**

Create: `lib/data/workout/datasources/workout_local_datasource.dart`

```dart
import 'package:drift/drift.dart';
import '../../../domain/workout/entities/workout_log.dart';
import '../../../domain/workout/entities/user_fitness_profile.dart';
import '../../../domain/workout/enums/workout_type.dart';
import '../models/workout_database.dart';
import '../models/workout_log_model.dart';
import '../models/user_fitness_profile_model.dart';

/// Local data source for workout data using Drift.
class WorkoutLocalDataSource {
  final WorkoutDatabase _database;

  WorkoutLocalDataSource(this._database);

  // === Workout Logs ===

  /// Save a workout log
  Future<void> saveWorkoutLog(WorkoutLog log) async {
    final data = WorkoutLogModel.toData(log);
    await _database.into(_database.workoutLogs).insertOnConflictUpdate(data);
  }

  /// Get workout log by ID
  Future<WorkoutLog?> getWorkoutLog(String id) async {
    final query = _database.select(_database.workoutLogs)
      ..where((tbl) => tbl.id.equals(id));

    final result = await query.getSingleOrNull();
    return result != null ? WorkoutLogModel.toEntity(result) : null;
  }

  /// Get all workout logs for a user
  Future<List<WorkoutLog>> getWorkoutLogs(String userId) async {
    final query = _database.select(_database.workoutLogs)
      ..where((tbl) => tbl.userId.equals(userId))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.completedAt, mode: OrderingMode.desc)
      ]);

    final results = await query.get();
    return results.map(WorkoutLogModel.toEntity).toList();
  }

  /// Get recent workout logs (last N days)
  Future<List<WorkoutLog>> getRecentWorkoutLogs(String userId, int days) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    final query = _database.select(_database.workoutLogs)
      ..where((tbl) =>
          tbl.userId.equals(userId) & tbl.completedAt.isBiggerOrEqualValue(cutoffDate))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.completedAt, mode: OrderingMode.desc)
      ]);

    final results = await query.get();
    return results.map(WorkoutLogModel.toEntity).toList();
  }

  /// Get workout logs by type
  Future<List<WorkoutLog>> getWorkoutLogsByType(
    String userId,
    WorkoutType type, {
    int? count,
  }) async {
    final query = _database.select(_database.workoutLogs)
      ..where((tbl) =>
          tbl.userId.equals(userId) & tbl.workoutType.equals(type.name))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.completedAt, mode: OrderingMode.desc)
      ]);

    if (count != null) {
      query.limit(count);
    }

    final results = await query.get();
    return results.map(WorkoutLogModel.toEntity).toList();
  }

  /// Get workouts since a specific date
  Future<List<WorkoutLog>> getWorkoutsSince(String userId, DateTime since) async {
    final query = _database.select(_database.workoutLogs)
      ..where((tbl) =>
          tbl.userId.equals(userId) & tbl.completedAt.isBiggerOrEqualValue(since))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.completedAt, mode: OrderingMode.desc)
      ]);

    final results = await query.get();
    return results.map(WorkoutLogModel.toEntity).toList();
  }

  /// Delete a workout log
  Future<void> deleteWorkoutLog(String id) async {
    await (_database.delete(_database.workoutLogs)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  // === User Fitness Profile ===

  /// Get user's fitness profile
  Future<UserFitnessProfile?> getFitnessProfile(String userId) async {
    final query = _database.select(_database.userFitnessProfiles)
      ..where((tbl) => tbl.userId.equals(userId));

    final result = await query.getSingleOrNull();
    return result != null ? UserFitnessProfileModel.toEntity(result) : null;
  }

  /// Save or update fitness profile
  Future<void> saveFitnessProfile(UserFitnessProfile profile) async {
    final data = UserFitnessProfileModel.toData(profile);
    await _database.into(_database.userFitnessProfiles).insertOnConflictUpdate(data);
  }

  /// Create initial fitness profile for new user
  Future<void> createInitialProfile(String userId) async {
    final now = DateTime.now();
    final profile = UserFitnessProfile(
      userId: userId,
      overallFitnessLevel: 1,
      strengthLevel: 1,
      coreLevel: 1,
      cardioLevel: 1,
      flexibilityLevel: 1,
      preferredDuration: 30,
      availableDurations: [10, 30],
      totalWorkoutsCompleted: 0,
      currentWeek: 1,
      consecutiveWorkoutDays: 0,
      needsRecoveryDay: false,
      createdAt: now,
      updatedAt: now,
    );

    await saveFitnessProfile(profile);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/data/workout/datasources/workout_local_datasource_test.dart
```

Expected: PASS

- [ ] **Step 5: Commit local datasource**

```bash
git add lib/data/workout/datasources/ test/data/workout/datasources/
git commit -m "feat(workout): add local data source

- CRUD operations for workout logs
- CRUD operations for fitness profiles
- Query methods: recent, by type, since date
- Uses Drift for database operations
- Fully tested with in-memory database

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Self-Review Checkpoint

Before proceeding with service layer implementation, verify:
- ✅ All domain enums created and tested (WorkoutType, UserFeedback, EnergyLevel)
- ✅ All domain entities created and tested (WorkoutLog, UserFitnessProfile, WorkoutRecommendation, analytics entities)
- ✅ Repository interface defined
- ✅ Drift database tables defined with indexes
- ✅ Model converters implemented and tested
- ✅ Local datasource implemented and tested

**Remaining work:** Service layer (recommendation algorithm, feedback processing, progressive overload), repository implementation, Riverpod providers, AI integration.

---

## Task 9: Service Layer - Recommendation Engine Core

**Files:**
- Create: `lib/services/workout/recommendation_engine.dart`
- Create: `test/services/workout/recommendation_engine_test.dart`

- [ ] **Step 1: Write test for workout name generation**

Create: `test/services/workout/recommendation_engine_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_companion/services/workout/recommendation_engine.dart';
import 'package:ai_health_companion/domain/workout/enums/workout_type.dart';

void main() {
  group('RecommendationEngine', () {
    late RecommendationEngine engine;

    setUp(() {
      engine = RecommendationEngine();
    });

    group('generateWorkoutName', () {
      test('should generate beginner low impact name', () {
        final name = engine.generateWorkoutName(
          WorkoutType.lowImpact,
          difficulty: 2,
          duration: 30,
        );

        expect(name, 'Deepthi Beginner Low Impact Cardio 30min');
      });

      test('should generate moderate core name', () {
        final name = engine.generateWorkoutName(
          WorkoutType.core,
          difficulty: 5,
          duration: 25,
        );

        expect(name, 'Deepthi Moderate Core Workout 25min');
      });

      test('should generate advanced strength name', () {
        final name = engine.generateWorkoutName(
          WorkoutType.strength,
          difficulty: 8,
          duration: 30,
        );

        expect(name, 'Deepthi Advanced Strength Training 30min');
      });

      test('should generate stretching name', () {
        final name = engine.generateWorkoutName(
          WorkoutType.stretching,
          difficulty: 2,
          duration: 10,
        );

        expect(name, 'Deepthi Full Body Stretch 10min');
      });
    });

    group('getIntensityDescriptor', () {
      test('should return Beginner for difficulty 1-3', () {
        expect(engine.getIntensityDescriptor(1), 'Beginner');
        expect(engine.getIntensityDescriptor(2), 'Beginner');
        expect(engine.getIntensityDescriptor(3), 'Beginner');
      });

      test('should return Moderate for difficulty 4-6', () {
        expect(engine.getIntensityDescriptor(4), 'Moderate');
        expect(engine.getIntensityDescriptor(5), 'Moderate');
        expect(engine.getIntensityDescriptor(6), 'Moderate');
      });

      test('should return Advanced for difficulty 7-10', () {
        expect(engine.getIntensityDescriptor(7), 'Advanced');
        expect(engine.getIntensityDescriptor(8), 'Advanced');
        expect(engine.getIntensityDescriptor(10), 'Advanced');
      });
    });

    group('calculateCurrentWeek', () {
      test('should calculate week 1 for day 0', () {
        final created = DateTime.now();
        final week = engine.calculateCurrentWeek(created);
        expect(week, 1);
      });

      test('should calculate week 2 for day 7', () {
        final created = DateTime.now().subtract(Duration(days: 7));
        final week = engine.calculateCurrentWeek(created);
        expect(week, 2);
      });

      test('should calculate week 5 for day 28', () {
        final created = DateTime.now().subtract(Duration(days: 28));
        final week = engine.calculateCurrentWeek(created);
        expect(week, 5);
      });
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/services/workout/recommendation_engine_test.dart
```

Expected: FAIL

- [ ] **Step 3: Create RecommendationEngine with helper methods**

Create: `lib/services/workout/recommendation_engine.dart`

```dart
import '../../domain/workout/entities/workout_log.dart';
import '../../domain/workout/entities/user_fitness_profile.dart';
import '../../domain/workout/entities/workout_recommendation.dart';
import '../../domain/workout/enums/workout_type.dart';
import '../../domain/workout/enums/user_feedback.dart';

/// Core recommendation engine for workout suggestions.
class RecommendationEngine {
  /// Generate workout name based on type, difficulty, duration
  String generateWorkoutName(
    WorkoutType workoutType, {
    required int difficulty,
    required int duration,
  }) {
    final intensity = getIntensityDescriptor(difficulty);
    final typeName = _getTypeDisplayName(workoutType);

    return 'Deepthi $intensity $typeName ${duration}min';
  }

  /// Get intensity descriptor from difficulty level
  String getIntensityDescriptor(int difficulty) {
    if (difficulty <= 3) {
      return 'Beginner';
    } else if (difficulty <= 6) {
      return 'Moderate';
    } else {
      return 'Advanced';
    }
  }

  /// Get display name for workout type
  String _getTypeDisplayName(WorkoutType type) {
    switch (type) {
      case WorkoutType.strength:
        return 'Strength Training';
      case WorkoutType.lowImpact:
        return 'Low Impact Cardio';
      case WorkoutType.core:
        return 'Core Workout';
      case WorkoutType.stretching:
        return 'Full Body Stretch';
      case WorkoutType.mobility:
        return 'Mobility Flow';
      case WorkoutType.recovery:
        return 'Active Recovery';
    }
  }

  /// Calculate current week number from profile creation date
  int calculateCurrentWeek(DateTime profileCreatedAt) {
    final daysSinceStart = DateTime.now().difference(profileCreatedAt).inDays;
    final week = (daysSinceStart / 7).floor() + 1;
    return week;
  }

  /// Calculate difficulty level based on fitness level and workout type
  int calculateDifficultyLevel(
    UserFitnessProfile profile,
    WorkoutType workoutType,
  ) {
    int baseLevel;

    switch (workoutType) {
      case WorkoutType.strength:
        baseLevel = profile.strengthLevel;
        break;
      case WorkoutType.core:
        baseLevel = profile.coreLevel;
        break;
      case WorkoutType.lowImpact:
        baseLevel = profile.cardioLevel;
        break;
      case WorkoutType.stretching:
      case WorkoutType.mobility:
      case WorkoutType.recovery:
        baseLevel = profile.flexibilityLevel;
        break;
    }

    // Cap at 10
    return baseLevel.clamp(1, 10);
  }

  /// Count how many times each workout type was done
  Map<WorkoutType, int> countWorkoutTypes(List<WorkoutLog> workouts) {
    final counts = <WorkoutType, int>{};

    for (final workout in workouts) {
      counts[workout.workoutType] = (counts[workout.workoutType] ?? 0) + 1;
    }

    return counts;
  }

  /// Select workout type based on progressive phase and balance
  WorkoutType selectWorkoutType(
    UserFitnessProfile profile,
    List<WorkoutLog> recentWorkouts,
  ) {
    final week = profile.currentWeek;
    final recentTypes = recentWorkouts.map((w) => w.workoutType).toList();

    // Phase 1: Foundation (Weeks 1-2)
    if (week <= 2) {
      return WorkoutType.lowImpact;
    }

    // Phase 2: Core Building (Weeks 3-4)
    if (week <= 4) {
      // Mix low impact + core
      if (recentTypes.isNotEmpty && recentTypes.first == WorkoutType.core) {
        return WorkoutType.lowImpact;
      } else {
        // Alternate between core and low impact
        return recentTypes.isEmpty || recentTypes.first == WorkoutType.lowImpact
            ? WorkoutType.core
            : WorkoutType.lowImpact;
      }
    }

    // Phase 3: Strength Introduction (Weeks 5-8)
    if (week <= 8) {
      final availableTypes = [
        WorkoutType.lowImpact,
        WorkoutType.core,
        WorkoutType.strength,
      ];

      // Filter out yesterday's type
      if (recentTypes.isNotEmpty) {
        availableTypes.remove(recentTypes.first);
      }

      // Count types in recent workouts
      final typeCounts = countWorkoutTypes(recentWorkouts);

      // Return least-done type
      availableTypes.sort((a, b) {
        final countA = typeCounts[a] ?? 0;
        final countB = typeCounts[b] ?? 0;
        return countA.compareTo(countB);
      });

      return availableTypes.first;
    }

    // Phase 4: Full Rotation (Week 9+)
    final allTypes = [
      WorkoutType.lowImpact,
      WorkoutType.core,
      WorkoutType.strength,
      WorkoutType.mobility,
      WorkoutType.stretching,
    ];

    // Filter out yesterday's type
    if (recentTypes.isNotEmpty) {
      allTypes.remove(recentTypes.first);
    }

    // Count types in recent workouts
    final typeCounts = countWorkoutTypes(recentWorkouts);

    // Return least-done type
    allTypes.sort((a, b) {
      final countA = typeCounts[a] ?? 0;
      final countB = typeCounts[b] ?? 0;
      return countA.compareTo(countB);
    });

    return allTypes.first;
  }

  /// Generate reasoning text for recommendation
  String generateReasoning(
    WorkoutType workoutType,
    int difficulty,
    UserFitnessProfile profile,
    List<WorkoutLog> recentWorkouts,
  ) {
    if (profile.currentWeek <= 2) {
      return "Building your foundation with low-impact cardio. Perfect for starting out!";
    }

    if (profile.currentWeek <= 4 && workoutType == WorkoutType.core) {
      return "Building on your recent low impact work. Time to strengthen that core!";
    }

    if (recentWorkouts.isEmpty) {
      return "Let's get started with a great workout!";
    }

    final lastType = recentWorkouts.first.workoutType;

    if (lastType == workoutType) {
      return "Continuing with ${workoutType.displayName.toLowerCase()} - you're building great consistency!";
    } else {
      return "Mixing things up with ${workoutType.displayName.toLowerCase()}. Variety keeps it effective!";
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/services/workout/recommendation_engine_test.dart
```

Expected: PASS

- [ ] **Step 5: Commit recommendation engine core**

```bash
git add lib/services/workout/recommendation_engine.dart test/services/workout/recommendation_engine_test.dart
git commit -m "feat(workout): add recommendation engine core

- Generate workout names with difficulty/duration
- Calculate difficulty from fitness levels
- Select workout type based on progressive phases
- Balance workout variety across the week
- Generate reasoning for recommendations
- Fully tested

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 10: Service Layer - Feedback Processor

**Files:**
- Create: `lib/services/workout/feedback_processor.dart`
- Create: `test/services/workout/feedback_processor_test.dart`

- [ ] **Step 1: Write test for feedback parsing**

Create: `test/services/workout/feedback_processor_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_companion/services/workout/feedback_processor.dart';
import 'package:ai_health_companion/domain/workout/enums/user_feedback.dart';
import 'package:ai_health_companion/domain/workout/enums/energy_level.dart';

void main() {
  group('FeedbackProcessor', () {
    late FeedbackProcessor processor;

    setUp(() {
      processor = FeedbackProcessor();
    });

    group('parseFeedback', () {
      test('should detect completion', () {
        expect(processor.isCompleted('Done!'), true);
        expect(processor.isCompleted('Finished the workout'), true);
        expect(processor.isCompleted('Completed it'), true);
        expect(processor.isCompleted('I did it'), false);
      });

      test('should detect skip', () {
        expect(processor.isSkipped('Skipped today'), true);
        expect(processor.isSkipped("Didn't do it"), true);
        expect(processor.isSkipped("Couldn't workout"), true);
        expect(processor.isSkipped('Done!'), false);
      });

      test('should parse "too easy" feedback', () {
        final feedback = processor.parseDifficultyFeedback('Done! It was too easy.');
        expect(feedback, UserFeedback.tooEasy);
      });

      test('should parse "perfect" feedback', () {
        final feedback1 = processor.parseDifficultyFeedback('Done! It was perfect.');
        expect(feedback1, UserFeedback.perfect);

        final feedback2 = processor.parseDifficultyFeedback('Finished. It was great!');
        expect(feedback2, UserFeedback.perfect);
      });

      test('should parse "too hard" feedback', () {
        final feedback = processor.parseDifficultyFeedback('Done but it was too hard.');
        expect(feedback, UserFeedback.tooHard);
      });

      test('should default to perfect if completed without specific feedback', () {
        final feedback = processor.parseDifficultyFeedback('Done!');
        expect(feedback, UserFeedback.perfect);
      });

      test('should parse energized energy level', () {
        final energy = processor.parseEnergyLevel('Done! I feel energized!');
        expect(energy, EnergyLevel.energized);
      });

      test('should parse tired energy level', () {
        final energy = processor.parseEnergyLevel('Done! I am tired now.');
        expect(energy, EnergyLevel.tired);
      });

      test('should parse exhausted energy level', () {
        final energy = processor.parseEnergyLevel('Done! I am exhausted.');
        expect(energy, EnergyLevel.exhausted);
      });

      test('should return null if no energy keywords found', () {
        final energy = processor.parseEnergyLevel('Done!');
        expect(energy, null);
      });
    });

    group('complete message parsing', () {
      test('should parse complete positive feedback', () {
        final result = processor.parseCompleteFeedback('Done! It was perfect. I feel great!');

        expect(result['completed'], true);
        expect(result['skipped'], false);
        expect(result['feedback'], UserFeedback.perfect);
        expect(result['energyLevel'], EnergyLevel.energized);
      });

      test('should parse complete negative feedback', () {
        final result = processor.parseCompleteFeedback('Finished but it was too hard. I am exhausted.');

        expect(result['completed'], true);
        expect(result['feedback'], UserFeedback.tooHard);
        expect(result['energyLevel'], EnergyLevel.exhausted);
      });

      test('should parse skip message', () {
        final result = processor.parseCompleteFeedback('Skipped today, too tired.');

        expect(result['completed'], false);
        expect(result['skipped'], true);
        expect(result['feedback'], UserFeedback.skipped);
      });
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/services/workout/feedback_processor_test.dart
```

Expected: FAIL

- [ ] **Step 3: Create FeedbackProcessor**

Create: `lib/services/workout/feedback_processor.dart`

```dart
import '../../domain/workout/enums/user_feedback.dart';
import '../../domain/workout/enums/energy_level.dart';

/// Processes natural language feedback from users about workouts.
class FeedbackProcessor {
  // Keywords for detecting completion
  static const _completionKeywords = [
    'done',
    'finished',
    'completed',
    'did it',
  ];

  // Keywords for detecting skip
  static const _skipKeywords = [
    'skipped',
    "didn't do",
    "couldn't",
    'missed',
  ];

  // Keywords for difficulty feedback
  static const _tooEasyKeywords = ['easy', 'light', 'simple', 'not challenging'];
  static const _perfectKeywords = ['perfect', 'good', 'right', 'great', 'just right'];
  static const _tooHardKeywords = ['hard', 'difficult', 'tough', 'challenging', 'struggled'];

  // Keywords for energy level
  static const _energizedKeywords = ['energized', 'pumped', 'great', 'amazing', 'refreshed'];
  static const _tiredKeywords = ['tired', 'worn out', 'fatigued'];
  static const _exhaustedKeywords = ['exhausted', 'drained', 'wiped', 'dead'];

  /// Check if message indicates completion
  bool isCompleted(String message) {
    final lower = message.toLowerCase();
    return _completionKeywords.any((keyword) => lower.contains(keyword));
  }

  /// Check if message indicates skip
  bool isSkipped(String message) {
    final lower = message.toLowerCase();
    return _skipKeywords.any((keyword) => lower.contains(keyword));
  }

  /// Parse difficulty feedback from message
  UserFeedback parseDifficultyFeedback(String message) {
    final lower = message.toLowerCase();

    // Check for skipped first
    if (isSkipped(message)) {
      return UserFeedback.skipped;
    }

    // Check for too easy
    if (_tooEasyKeywords.any((keyword) => lower.contains(keyword))) {
      return UserFeedback.tooEasy;
    }

    // Check for too hard
    if (_tooHardKeywords.any((keyword) => lower.contains(keyword))) {
      return UserFeedback.tooHard;
    }

    // Check for perfect
    if (_perfectKeywords.any((keyword) => lower.contains(keyword))) {
      return UserFeedback.perfect;
    }

    // Default to perfect if completed
    return UserFeedback.perfect;
  }

  /// Parse energy level from message
  EnergyLevel? parseEnergyLevel(String message) {
    final lower = message.toLowerCase();

    // Check for energized
    if (_energizedKeywords.any((keyword) => lower.contains(keyword))) {
      return EnergyLevel.energized;
    }

    // Check for exhausted (before tired, as exhausted is more specific)
    if (_exhaustedKeywords.any((keyword) => lower.contains(keyword))) {
      return EnergyLevel.exhausted;
    }

    // Check for tired
    if (_tiredKeywords.any((keyword) => lower.contains(keyword))) {
      return EnergyLevel.tired;
    }

    return null;
  }

  /// Parse complete feedback from message
  Map<String, dynamic> parseCompleteFeedback(String message) {
    final completed = isCompleted(message);
    final skipped = isSkipped(message);
    final feedback = parseDifficultyFeedback(message);
    final energyLevel = parseEnergyLevel(message);

    return {
      'completed': completed,
      'skipped': skipped,
      'feedback': feedback,
      'energyLevel': energyLevel,
    };
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/services/workout/feedback_processor_test.dart
```

Expected: PASS

- [ ] **Step 5: Commit feedback processor**

```bash
git add lib/services/workout/feedback_processor.dart test/services/workout/feedback_processor_test.dart
git commit -m "feat(workout): add feedback processor

- Parse completion/skip from natural language
- Extract difficulty feedback (too easy, perfect, too hard)
- Extract energy level (energized, tired, exhausted)
- Keyword-based pattern matching
- Fully tested with various message formats

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Plan Completion Note

This implementation plan provides the foundation for the Workout Recommendation Engine with:
- ✅ Complete domain layer (7 tasks)
- ✅ Complete data layer with Drift (3 tasks)
- ✅ Core service components (2 tasks)

**Remaining tasks to complete the full system:**
- Task 11: Progressive Overload Manager (fitness level updates)
- Task 12: Recovery Manager (recovery assessment)
- Task 13: AI Context Builder (system prompt generation)
- Task 14: Repository Implementation (ties data + services together)
- Task 15-17: Riverpod Providers (state management)
- Task 18: Integration with existing chat system
- Task 19: End-to-end integration tests

**Total estimated implementation time:** 12-16 hours

**Next steps after this plan:**
1. Execute Tasks 1-10 using subagent-driven-development or executing-plans
2. Complete remaining service layer tasks (11-13)
3. Wire everything together with repository + providers (14-17)
4. Integrate with chat UI (18)
5. Test end-to-end (19)

---

## Execution Instructions

Plan saved to: `D:/Projects/ai-health-companion/docs/superpowers/plans/2026-07-03-workout-recommendation-engine.md`

**Two execution options:**

1. **Subagent-Driven (Recommended)** - Fresh subagent per task with two-stage review
2. **Inline Execution** - Execute tasks in this session with checkpoints

Choose your approach to begin implementation.
