# AI Health Companion - Workout Recommendation Engine

**Design Philosophy:** Progressive, Adaptive, Home-Friendly, Sustainable
**Date:** 2026-07-03
**Version:** 1.0
**Architect:** Fitness Algorithm Specialist

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Core Architecture](#2-core-architecture)
3. [Database Schema](#3-database-schema)
4. [Data Models](#4-data-models)
5. [Recommendation Algorithm](#5-recommendation-algorithm)
6. [Fitness Level Calculation](#6-fitness-level-calculation)
7. [Recovery Day Detection](#7-recovery-day-detection)
8. [Workout Type Selection](#8-workout-type-selection)
9. [Difficulty Level Calculation](#9-difficulty-level-calculation)
10. [Feedback Processing](#10-feedback-processing)
11. [Progressive Overload System](#11-progressive-overload-system)
12. [Weekly Planning](#12-weekly-planning)
13. [Monthly Progress Tracking](#13-monthly-progress-tracking)
14. [Recovery Management](#14-recovery-management)
15. [AI Integration](#15-ai-integration)
16. [Complete Flow Examples](#16-complete-flow-examples)

---

## 1. Executive Summary

The Workout Recommendation Engine provides personalized, progressive fitness recommendations for busy mothers who:
- Cannot regularly go outside (baby at home)
- Prefer home-based workouts (Deepthi videos)
- Need flexibility (10-minute or 30-minute sessions)
- Want variety (strength, low impact, core, stretching, mobility)
- Need sustainable progression (not too fast, not too slow)

### Key Design Goals

**Conversational First:**
- User asks: "What workout should I do?"
- AI recommends based on fitness level, history, recovery needs
- User completes and reports: "Done! It was perfect."
- System learns and adapts

**Progressive Overload:**
- Week 1-2: Foundation (Low Impact only)
- Week 3-4: Core Building (Low Impact + Core)
- Week 5-8: Strength Introduction
- Week 9+: Full rotation with all workout types
- Difficulty increases based on user feedback (3 consecutive "perfect" → level up)

**Recovery Management:**
- Automatic rest day after 3 consecutive workout days
- Recovery workouts when user reports "too hard" or "exhausted"
- Balance intensity across the week

**Flexibility:**
- 10-minute quick workouts when time is limited
- 30-minute full sessions when available
- AI adapts recommendations based on available time

---

## 2. Core Architecture

### 2.1 System Overview

```
User asks: "What workout should I do today?"
  ↓
┌─────────────────────────────────────────────────────────────┐
│ Workout Recommendation Engine                               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ Step 1: Get User Fitness Profile                            │
│   • Current fitness levels (strength, core, cardio, flex)   │
│   • Total workouts completed                                │
│   • Current week in program                                 │
│   • Last workout date                                       │
│                                                              │
│ Step 2: Query Recent Workout History                        │
│   • Last 7 days of workouts                                 │
│   • Feedback from each workout                              │
│   • Energy levels reported                                  │
│   • Consecutive workout days                                │
│                                                              │
│ Step 3: Assess Recovery Needs                               │
│   • 3+ consecutive days? → Recovery needed                  │
│   • Recent "exhausted" feedback? → Recovery                 │
│   • 2+ "too hard" feedbacks? → Step back                    │
│                                                              │
│ Step 4: Determine Workout Type                              │
│   • Progressive phase (week-based)                          │
│   • Balance (rotate types)                                  │
│   • Avoid same type 2 days in row                           │
│                                                              │
│ Step 5: Calculate Difficulty Level                          │
│   • Match difficulty to fitness level                       │
│   • Type-specific levels (strength vs cardio)               │
│                                                              │
│ Step 6: Ask About Available Time                            │
│   • 10 minutes or 30 minutes?                               │
│                                                              │
│ Step 7: Generate Workout Name                               │
│   • Format: "Deepthi {Intensity} {Type} {Duration}"         │
│   • Example: "Deepthi Moderate Core Workout 30min"          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
  ↓
AI presents recommendation conversationally
  ↓
User completes workout
  ↓
User: "Done! It was perfect."
  ↓
┌─────────────────────────────────────────────────────────────┐
│ Feedback Processor                                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ Step 1: Parse Feedback                                      │
│   • Completion: "done", "finished", "skipped"               │
│   • Difficulty: "easy", "perfect", "hard"                   │
│   • Energy: "energized", "tired", "exhausted"               │
│                                                              │
│ Step 2: Log Workout                                         │
│   • Save to workout_logs table                              │
│   • Store feedback and energy level                         │
│                                                              │
│ Step 3: Update Fitness Profile                              │
│   • Increment total_workouts_completed                      │
│   • Update consecutive_workout_days                         │
│   • Update last_workout_date                                │
│                                                              │
│ Step 4: Check Progressive Overload                          │
│   • 3 consecutive "perfect/easy"? → Increase fitness level  │
│   • 2 consecutive "too hard"? → Decrease fitness level      │
│   • At least 2 weeks since last increase                    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Component Descriptions

**Recommendation Engine:**
- Central component that decides what workout to recommend
- Considers: fitness level, history, recovery, balance, time
- Returns structured recommendation for AI to present

**Feedback Processor:**
- Parses natural language feedback from user
- Extracts: completion status, difficulty rating, energy level
- Updates fitness profile based on patterns

**Progressive Overload Manager:**
- Tracks fitness level progression
- Increases difficulty when user is ready (3 consecutive positive feedbacks)
- Decreases if user struggles (2 consecutive "too hard")
- Minimum 2 weeks between increases

**Recovery Manager:**
- Monitors workout frequency and intensity
- Triggers recovery days when needed
- Balances hard workouts with recovery

**AI Context Builder:**
- Builds dynamic context for AI system prompt
- Includes: current week, fitness levels, recent workouts, recovery status
- Enables AI to present recommendations conversationally

---

## 3. Database Schema

### 3.1 Workout Logs Table

**Purpose:** Stores all completed workouts with feedback.

```sql
CREATE TABLE workout_logs (
    id TEXT PRIMARY KEY NOT NULL,
    user_id TEXT NOT NULL,

    -- Workout Details
    workout_name TEXT NOT NULL,
    -- Example: "Deepthi Moderate Core Workout 30min"

    workout_type TEXT NOT NULL,
    -- 'strength', 'low_impact', 'core', 'stretching', 'mobility', 'recovery'

    duration_minutes INTEGER NOT NULL,
    -- 10 or 30 minutes

    -- Difficulty & Feedback
    difficulty_level INTEGER NOT NULL,
    -- 1-10 scale: 1-3 Beginner, 4-6 Moderate, 7-10 Advanced

    user_feedback TEXT,
    -- 'too_easy', 'perfect', 'too_hard', 'skipped'

    energy_level_after TEXT,
    -- 'energized', 'tired', 'exhausted'

    -- Timestamps
    completed_at TEXT NOT NULL,  -- ISO 8601 timestamp
    created_at TEXT NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_workout_logs_user_date
    ON workout_logs(user_id, completed_at);

CREATE INDEX idx_workout_logs_type
    ON workout_logs(user_id, workout_type);

CREATE INDEX idx_workout_logs_recent
    ON workout_logs(user_id, created_at DESC);
```

**Why this table exists:**
- Complete history of all workouts
- Enables progress analytics (weekly/monthly stats)
- Feedback patterns inform fitness level adjustments
- Query recent workouts for recommendation logic

### 3.2 User Fitness Profile Table

**Purpose:** Tracks user's current fitness levels and progression state.

```sql
CREATE TABLE user_fitness_profile (
    user_id TEXT PRIMARY KEY NOT NULL,

    -- Current Fitness Levels (1-10 scale)
    overall_fitness_level INTEGER DEFAULT 1,
    -- Average of all specific levels

    strength_level INTEGER DEFAULT 1,
    -- For strength training workouts

    core_level INTEGER DEFAULT 1,
    -- For core workouts

    cardio_level INTEGER DEFAULT 1,
    -- For low impact cardio workouts

    flexibility_level INTEGER DEFAULT 1,
    -- For stretching/mobility workouts

    -- Workout Preferences
    preferred_duration INTEGER DEFAULT 30,
    -- Default: 30 minutes

    available_durations TEXT DEFAULT '[10,30]',
    -- JSON array of available time slots

    -- Progression Tracking
    total_workouts_completed INTEGER DEFAULT 0,
    -- Lifetime workout count

    current_week INTEGER DEFAULT 1,
    -- Week in progressive overload program (1-∞)

    last_difficulty_increase TEXT,
    -- ISO 8601 date of last fitness level increase

    -- Recovery Management
    last_workout_date TEXT,
    -- ISO 8601 date of most recent workout

    consecutive_workout_days INTEGER DEFAULT 0,
    -- How many days in a row user has worked out

    needs_recovery_day BOOLEAN DEFAULT 0,
    -- Flag for recovery day requirement

    -- Timestamps
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_fitness_profile_updated
    ON user_fitness_profile(updated_at);
```

**Why this table exists:**
- Single source of truth for user's fitness state
- Fitness levels drive difficulty recommendations
- Week tracking enables progressive phase logic
- Recovery flags prevent overtraining

---

## 4. Data Models

### 4.1 Enumerations

```dart
enum WorkoutType {
  strength,      // Resistance exercises (squats, lunges, arm work)
  lowImpact,     // Gentle cardio (walking, marching)
  core,          // Ab and core strengthening
  stretching,    // Full body flexibility work
  mobility,      // Joint mobility and movement prep
  recovery       // Gentle active recovery
}

enum UserFeedback {
  tooEasy,   // Workout was not challenging enough
  perfect,   // Workout was just right
  tooHard,   // Workout was too challenging
  skipped    // User did not complete workout
}

enum EnergyLevel {
  energized,  // Feeling great after workout
  tired,      // Normally tired after workout
  exhausted   // Too exhausted, might be overdoing it
}
```

### 4.2 Core Data Classes

```dart
class WorkoutLog {
  final String id;
  final String userId;

  // Workout details
  final String workoutName;
  final WorkoutType workoutType;
  final int durationMinutes;

  // Difficulty & feedback
  final int difficultyLevel;  // 1-10 scale
  final UserFeedback? feedback;
  final EnergyLevel? energyLevelAfter;

  // Timestamps
  final DateTime completedAt;
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'workout_name': workoutName,
    'workout_type': workoutType.name,
    'duration_minutes': durationMinutes,
    'difficulty_level': difficultyLevel,
    'user_feedback': feedback?.name,
    'energy_level_after': energyLevelAfter?.name,
    'completed_at': completedAt.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };
}

class UserFitnessProfile {
  final String userId;

  // Fitness levels (1-10 scale)
  final int overallFitnessLevel;
  final int strengthLevel;
  final int coreLevel;
  final int cardioLevel;
  final int flexibilityLevel;

  // Preferences
  final int preferredDuration;
  final List<int> availableDurations;

  // Progression
  final int totalWorkoutsCompleted;
  final int currentWeek;
  final DateTime? lastDifficultyIncrease;

  // Recovery
  final DateTime? lastWorkoutDate;
  final int consecutiveWorkoutDays;
  final bool needsRecoveryDay;

  // Timestamps
  final DateTime createdAt;
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

  // Calculate overall fitness from specific levels
  int calculateOverallFitness() {
    return ((strengthLevel + coreLevel + cardioLevel + flexibilityLevel) / 4)
        .round();
  }
}

class WorkoutRecommendation {
  final WorkoutType workoutType;
  final int difficultyLevel;
  final String workoutName;
  final int durationMinutes;
  final String reasoning;

  const WorkoutRecommendation({
    required this.workoutType,
    required this.difficultyLevel,
    required this.workoutName,
    required this.durationMinutes,
    required this.reasoning,
  });
}
```

### 4.3 Analytics Data Classes

```dart
class WeeklySummary {
  final int totalWorkouts;
  final int totalMinutes;
  final Map<WorkoutType, int> typeCounts;
  final List<WorkoutType> missingTypes;
  final DateTime weekStart;

  const WeeklySummary({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.typeCounts,
    required this.missingTypes,
    required this.weekStart,
  });
}

class MonthlyProgress {
  final int totalWorkouts;
  final int totalMinutes;
  final double avgWorkoutsPerWeek;
  final Map<WorkoutType, int> typeDistribution;
  final int currentFitnessLevel;
  final int fitnessLevelIncrease;
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
}

class RecoveryAssessment {
  final bool needsFullRest;
  final bool needsActiveRecovery;
  final int consecutiveWorkoutDays;
  final double recentIntensity;
  final int weeklyVolumeMinutes;
  final String recommendation;

  const RecoveryAssessment({
    required this.needsFullRest,
    required this.needsActiveRecovery,
    required this.consecutiveWorkoutDays,
    required this.recentIntensity,
    required this.weeklyVolumeMinutes,
    required this.recommendation,
  });
}
```

---

## 5. Recommendation Algorithm

### 5.1 Master Algorithm

```python
def recommend_workout(
    user_id: str,
    available_time: int = None
) -> WorkoutRecommendation:
    """
    Main algorithm that recommends appropriate workout.

    Args:
        user_id: User identifier
        available_time: Minutes available (10 or 30). If None, ask user.

    Returns:
        WorkoutRecommendation with type, difficulty, name, duration, reasoning

    Algorithm Steps:
    1. Get user fitness profile
    2. Get recent workout history (last 7 days)
    3. Check if recovery day is needed
    4. Determine workout type based on balance and phase
    5. Calculate appropriate difficulty level
    6. Determine duration (ask if not provided)
    7. Generate workout name and reasoning
    """
    # Step 1: Get user fitness profile
    profile = get_fitness_profile(user_id)

    # Step 2: Get recent workout history
    recent_workouts = get_recent_workouts(user_id, days=7)

    # Step 3: Check if recovery day is needed
    if needs_recovery_day(profile, recent_workouts):
        return recommend_recovery_workout(available_time or 30)

    # Step 4: Determine workout type based on balance
    workout_type = select_workout_type(profile, recent_workouts)

    # Step 5: Calculate appropriate difficulty level
    difficulty = calculate_difficulty_level(profile, workout_type)

    # Step 6: Determine duration
    duration = available_time or profile.preferred_duration

    # Step 7: Generate workout recommendation
    workout_name = generate_workout_name(workout_type, difficulty, duration)
    reasoning = explain_recommendation(workout_type, difficulty, profile, recent_workouts)

    return WorkoutRecommendation(
        workout_type=workout_type,
        difficulty_level=difficulty,
        workout_name=workout_name,
        duration_minutes=duration,
        reasoning=reasoning
    )
```

### 5.2 Example Usage

```python
# User asks: "What workout should I do?"
recommendation = recommend_workout(user_id="user123")

# Output:
# WorkoutRecommendation(
#     workout_type=WorkoutType.CORE,
#     difficulty_level=4,
#     workout_name="Deepthi Moderate Core Workout 30min",
#     duration_minutes=30,
#     reasoning="Building on your recent low impact work. Time to strengthen that core!"
# )

# AI presents conversationally:
# "Great! Try Deepthi Moderate Core Workout 30min. Building on your recent low impact work. Time to strengthen that core!"
```

---

## 6. Fitness Level Calculation

### 6.1 Overall Fitness Level

```python
def calculate_overall_fitness_level(profile: UserFitnessProfile) -> int:
    """
    Calculate overall fitness from specific levels.

    Returns:
        Integer 1-10 representing overall fitness

    Formula:
        Average of all specific fitness levels, rounded
    """
    levels = [
        profile.strength_level,
        profile.core_level,
        profile.cardio_level,
        profile.flexibility_level
    ]

    overall = sum(levels) / len(levels)
    return round(overall)
```

### 6.2 Fitness Level Update Logic

```python
def update_fitness_level_after_workout(
    profile: UserFitnessProfile,
    workout: WorkoutLog
) -> UserFitnessProfile:
    """
    Update fitness levels based on workout feedback.

    Progressive increase when user consistently reports 'perfect' or 'too_easy'.

    Rules:
    - Need 3 consecutive positive feedbacks for same workout type
    - Minimum 2 weeks between increases
    - Increase specific level by 1 (max 10)
    - Recalculate overall level

    Returns:
        Updated UserFitnessProfile
    """
    # Only consider positive feedback
    if workout.feedback not in [UserFeedback.PERFECT, UserFeedback.TOO_EASY]:
        return profile

    # Check time since last increase
    if profile.last_difficulty_increase:
        weeks_since = (datetime.now() - profile.last_difficulty_increase).days / 7
        if weeks_since < 2:
            return profile  # Too soon to increase

    # Get recent workouts of same type
    recent_same_type = get_recent_workouts_by_type(
        profile.user_id,
        workout.workout_type,
        count=3
    )

    # Count positive feedbacks
    positive_count = sum(
        1 for w in recent_same_type
        if w.feedback in [UserFeedback.PERFECT, UserFeedback.TOO_EASY]
    )

    # Need 3 consecutive positive feedbacks to increase
    if positive_count >= 3:
        # Increase the specific fitness level
        if workout.workout_type == WorkoutType.STRENGTH:
            profile.strength_level = min(10, profile.strength_level + 1)
        elif workout.workout_type == WorkoutType.CORE:
            profile.core_level = min(10, profile.core_level + 1)
        elif workout.workout_type == WorkoutType.LOW_IMPACT:
            profile.cardio_level = min(10, profile.cardio_level + 1)
        elif workout.workout_type in [WorkoutType.STRETCHING, WorkoutType.MOBILITY]:
            profile.flexibility_level = min(10, profile.flexibility_level + 1)

        # Update last increase date
        profile.last_difficulty_increase = datetime.now()

        # Recalculate overall fitness
        profile.overall_fitness_level = calculate_overall_fitness_level(profile)

    return profile
```

### 6.3 Fitness Level Decrease Logic

```python
def should_decrease_fitness_level(
    user_id: str,
    current_workout: WorkoutLog
) -> bool:
    """
    Determine if fitness level should decrease.

    Decrease if:
    - Last 2 workouts of same type were "too_hard"
    - User is struggling consistently

    Returns:
        True if level should decrease
    """
    recent_same_type = get_recent_workouts_by_type(
        user_id,
        current_workout.workout_type,
        count=2
    )

    if len(recent_same_type) < 2:
        return False

    # Check if both were too hard
    hard_count = sum(
        1 for w in recent_same_type
        if w.feedback == UserFeedback.TOO_HARD
    )

    return hard_count >= 2


def decrease_fitness_level(
    profile: UserFitnessProfile,
    workout_type: WorkoutType
) -> UserFitnessProfile:
    """
    Decrease specific fitness level by 1 (min 1).

    Used when user consistently reports "too hard".
    Better to step back than risk injury or burnout.
    """
    if workout_type == WorkoutType.STRENGTH:
        profile.strength_level = max(1, profile.strength_level - 1)
    elif workout_type == WorkoutType.CORE:
        profile.core_level = max(1, profile.core_level - 1)
    elif workout_type == WorkoutType.LOW_IMPACT:
        profile.cardio_level = max(1, profile.cardio_level - 1)
    elif workout_type in [WorkoutType.STRETCHING, WorkoutType.MOBILITY]:
        profile.flexibility_level = max(1, profile.flexibility_level - 1)

    # Recalculate overall fitness
    profile.overall_fitness_level = calculate_overall_fitness_level(profile)

    return profile
```

---

## 7. Recovery Day Detection

### 7.1 Recovery Day Algorithm

```python
def needs_recovery_day(
    profile: UserFitnessProfile,
    recent_workouts: List[WorkoutLog]
) -> bool:
    """
    Determine if user needs a recovery day.

    Recovery day needed if:
    1. 3+ consecutive workout days
    2. Last workout reported "exhausted"
    3. 2+ consecutive "too_hard" feedbacks
    4. High intensity workouts multiple days in a row

    Returns:
        True if recovery day is needed
    """
    # Rule 1: Check consecutive workout days
    if profile.consecutive_workout_days >= 3:
        return True

    # Rule 2: Check if last workout was exhausting
    if recent_workouts:
        last_workout = recent_workouts[0]
        if last_workout.energy_level_after == EnergyLevel.EXHAUSTED:
            return True

        # Rule 3: Check recent "too hard" feedback
        recent_hard = [
            w for w in recent_workouts[:3]
            if w.feedback == UserFeedback.TOO_HARD
        ]
        if len(recent_hard) >= 2:
            return True

    return False
```

### 7.2 Recovery Workout Recommendation

```python
def recommend_recovery_workout(duration: int) -> WorkoutRecommendation:
    """
    Recommend recovery workout.

    Recovery workouts are:
    - Stretching, mobility, or gentle movement
    - Always low difficulty (1-3)
    - Focus on flexibility and active recovery
    - No intensity, just gentle movement

    Args:
        duration: 10 or 30 minutes

    Returns:
        WorkoutRecommendation for recovery
    """
    recovery_types = [
        WorkoutType.STRETCHING,
        WorkoutType.MOBILITY,
        WorkoutType.RECOVERY
    ]

    workout_type = random.choice(recovery_types)

    if duration <= 10:
        name = "Deepthi Gentle Stretching 10min"
    else:
        name = "Deepthi Full Body Mobility 30min"

    return WorkoutRecommendation(
        workout_type=workout_type,
        difficulty_level=2,  # Always easy
        workout_name=name,
        duration_minutes=duration,
        reasoning="You've worked hard! Time for active recovery. Gentle stretching will help you feel refreshed."
    )
```

---

## 8. Workout Type Selection

### 8.1 Progressive Phases

```python
def select_workout_type(
    profile: UserFitnessProfile,
    recent_workouts: List[WorkoutLog]
) -> WorkoutType:
    """
    Select workout type based on:
    1. Progressive overload phase (week-based)
    2. Balance (avoid same type 2 days in a row)
    3. Weekly variety

    Progressive Phases:
    - Weeks 1-2: Foundation (Low Impact only)
    - Weeks 3-4: Core Building (Low Impact + Core)
    - Weeks 5-8: Strength Introduction (Low Impact + Core + Strength)
    - Week 9+: Full Rotation (all types)

    Returns:
        WorkoutType to recommend
    """
    week = profile.current_week
    recent_types = [w.workout_type for w in recent_workouts[:3]]

    # Phase 1: Foundation (Weeks 1-2)
    if week <= 2:
        return WorkoutType.LOW_IMPACT

    # Phase 2: Core Building (Weeks 3-4)
    elif week <= 4:
        # Mix low impact + core
        if recent_types and recent_types[0] == WorkoutType.CORE:
            return WorkoutType.LOW_IMPACT
        else:
            return WorkoutType.CORE if random.random() > 0.5 else WorkoutType.LOW_IMPACT

    # Phase 3: Strength Introduction (Weeks 5-8)
    elif week <= 8:
        # Add strength, rotate all three
        available_types = [
            WorkoutType.LOW_IMPACT,
            WorkoutType.CORE,
            WorkoutType.STRENGTH
        ]

        # Filter out yesterday's type (avoid back-to-back)
        if recent_types:
            available_types = [
                t for t in available_types
                if t != recent_types[0]
            ]

        # Count types in last 7 days
        type_counts = count_workout_types(recent_workouts)

        # Recommend least-done type
        return min(available_types, key=lambda t: type_counts.get(t, 0))

    # Phase 4: Full Rotation (Week 9+)
    else:
        # All types available
        all_types = [
            WorkoutType.LOW_IMPACT,
            WorkoutType.CORE,
            WorkoutType.STRENGTH,
            WorkoutType.MOBILITY,
            WorkoutType.STRETCHING
        ]

        # Filter out yesterday's type
        if recent_types:
            all_types = [t for t in all_types if t != recent_types[0]]

        # Recommend based on balance
        type_counts = count_workout_types(recent_workouts)
        return min(all_types, key=lambda t: type_counts.get(t, 0))


def count_workout_types(workouts: List[WorkoutLog]) -> Dict[WorkoutType, int]:
    """
    Count how many times each workout type was done.

    Returns:
        Dictionary mapping WorkoutType to count
    """
    counts = {}
    for workout in workouts:
        counts[workout.workout_type] = counts.get(workout.workout_type, 0) + 1
    return counts
```

### 8.2 Progressive Phase Timeline

```
Week 1-2: Foundation Phase
├─ Goal: Build base fitness, establish habit
├─ Types: Low Impact only
├─ Frequency: 3-4 workouts/week
└─ Example: "Deepthi Beginner Low Impact Cardio 30min"

Week 3-4: Core Building Phase
├─ Goal: Add core strength
├─ Types: Low Impact + Core (alternating)
├─ Frequency: 4-5 workouts/week
└─ Example: "Deepthi Moderate Core Workout 25min"

Week 5-8: Strength Introduction Phase
├─ Goal: Build overall strength
├─ Types: Low Impact + Core + Strength (rotation)
├─ Frequency: 5-6 workouts/week
└─ Example: "Deepthi Moderate Strength Training 30min"

Week 9+: Full Rotation Phase
├─ Goal: Balanced fitness, variety
├─ Types: All types (balanced rotation)
├─ Frequency: 6 workouts/week + 1 rest
└─ Example: Mix of all workout types
```

---

## 9. Difficulty Level Calculation

### 9.1 Difficulty Mapping

```python
def calculate_difficulty_level(
    profile: UserFitnessProfile,
    workout_type: WorkoutType
) -> int:
    """
    Calculate appropriate difficulty (1-10 scale).

    Difficulty matches specific fitness level for that workout type.

    Mapping:
    - Fitness Level 1-3 → Beginner (Difficulty 1-3)
    - Fitness Level 4-6 → Moderate (Difficulty 4-6)
    - Fitness Level 7-10 → Advanced (Difficulty 7-10)

    Returns:
        Integer 1-10 representing difficulty
    """
    # Get specific fitness level for this type
    if workout_type == WorkoutType.STRENGTH:
        base_level = profile.strength_level
    elif workout_type == WorkoutType.CORE:
        base_level = profile.core_level
    elif workout_type in [WorkoutType.LOW_IMPACT]:
        base_level = profile.cardio_level
    elif workout_type in [WorkoutType.STRETCHING, WorkoutType.MOBILITY, WorkoutType.RECOVERY]:
        base_level = profile.flexibility_level
    else:
        base_level = profile.overall_fitness_level

    # Difficulty matches fitness level
    difficulty = base_level

    # Cap at 10
    return min(10, difficulty)
```

### 9.2 Intensity Descriptors

```python
def get_intensity_descriptor(difficulty: int) -> str:
    """
    Get human-readable intensity descriptor.

    Args:
        difficulty: 1-10 scale

    Returns:
        "Beginner", "Moderate", or "Advanced"
    """
    if difficulty <= 3:
        return "Beginner"
    elif difficulty <= 6:
        return "Moderate"
    else:
        return "Advanced"
```

---

## 10. Feedback Processing

### 10.1 Feedback Parsing

```python
def process_workout_feedback(
    user_id: str,
    user_message: str,
    recommended_workout: WorkoutRecommendation
) -> WorkoutLog:
    """
    Parse user's feedback message and create workout log.

    Examples:
    - "Done! It was perfect." → completed, perfect
    - "Finished but it was too hard" → completed, too_hard, tired
    - "Done! I'm so energized!" → completed, perfect, energized
    - "Skipped today, too tired" → skipped

    Args:
        user_id: User identifier
        user_message: Natural language feedback
        recommended_workout: The workout that was recommended

    Returns:
        WorkoutLog with parsed feedback
    """
    message_lower = user_message.lower()

    # Extract completion status
    completion_keywords = ['done', 'finished', 'completed']
    skip_keywords = ['skipped', 'didn\'t do', 'couldn\'t']

    completed = any(kw in message_lower for kw in completion_keywords)
    skipped = any(kw in message_lower for kw in skip_keywords)

    # Determine feedback
    if skipped:
        feedback = UserFeedback.SKIPPED
    elif any(word in message_lower for word in ['easy', 'light', 'simple']):
        feedback = UserFeedback.TOO_EASY
    elif any(word in message_lower for word in ['perfect', 'good', 'right', 'great']):
        feedback = UserFeedback.PERFECT
    elif any(word in message_lower for word in ['hard', 'difficult', 'tough', 'challenging']):
        feedback = UserFeedback.TOO_HARD
    else:
        feedback = UserFeedback.PERFECT  # Default if completed

    # Extract energy level
    energy_level = None
    if any(word in message_lower for word in ['energized', 'pumped', 'great', 'amazing']):
        energy_level = EnergyLevel.ENERGIZED
    elif any(word in message_lower for word in ['exhausted', 'drained', 'wiped']):
        energy_level = EnergyLevel.EXHAUSTED
    elif any(word in message_lower for word in ['tired', 'worn out']):
        energy_level = EnergyLevel.TIRED

    # Create workout log
    workout_log = WorkoutLog(
        id=generate_uuid(),
        user_id=user_id,
        workout_name=recommended_workout.workout_name,
        workout_type=recommended_workout.workout_type,
        duration_minutes=recommended_workout.duration_minutes,
        difficulty_level=recommended_workout.difficulty_level,
        feedback=feedback,
        energy_level_after=energy_level,
        completed_at=datetime.now(),
        created_at=datetime.now()
    )

    # Save to database
    save_workout_log(workout_log)

    # Update fitness profile
    update_fitness_profile_after_workout(user_id, workout_log)

    return workout_log
```

### 10.2 Feedback Keywords

```python
FEEDBACK_KEYWORDS = {
    'completion': ['done', 'finished', 'completed', 'did it'],
    'skip': ['skipped', 'didn\'t do', 'couldn\'t', 'missed'],
    'too_easy': ['easy', 'light', 'simple', 'not challenging'],
    'perfect': ['perfect', 'good', 'right', 'great', 'just right'],
    'too_hard': ['hard', 'difficult', 'tough', 'challenging', 'struggled'],
    'energized': ['energized', 'pumped', 'great', 'amazing', 'refreshed'],
    'tired': ['tired', 'worn out', 'fatigued'],
    'exhausted': ['exhausted', 'drained', 'wiped', 'dead']
}
```

---

## 11. Progressive Overload System

### 11.1 Complete Update Flow

```python
def update_fitness_profile_after_workout(
    user_id: str,
    workout_log: WorkoutLog
) -> None:
    """
    Update user's fitness profile based on completed workout.

    Implements progressive overload by:
    1. Updating basic stats (total workouts, consecutive days)
    2. Checking if fitness level should increase (3 positive feedbacks)
    3. Checking if fitness level should decrease (2 negative feedbacks)
    4. Updating week progression

    Args:
        user_id: User identifier
        workout_log: Completed workout with feedback
    """
    profile = get_fitness_profile(user_id)

    # Skip updates if workout was skipped
    if workout_log.feedback == UserFeedback.SKIPPED:
        return

    # Update basic stats
    profile.total_workouts_completed += 1
    profile.last_workout_date = workout_log.completed_at

    # Update consecutive workout days
    if is_consecutive_day(profile.last_workout_date, workout_log.completed_at):
        profile.consecutive_workout_days += 1
    else:
        profile.consecutive_workout_days = 1

    # Check if fitness level should increase
    if should_increase_fitness_level(user_id, workout_log):
        increase_fitness_level(profile, workout_log.workout_type)

    # Check if fitness level should decrease
    if should_decrease_fitness_level(user_id, workout_log):
        decrease_fitness_level(profile, workout_log.workout_type)

    # Update week progression
    profile.current_week = calculate_current_week(profile.created_at)

    # Save updated profile
    save_fitness_profile(profile)


def calculate_current_week(profile_created_at: datetime) -> int:
    """
    Calculate which week the user is in (starting from week 1).

    Used for progressive overload phases.

    Returns:
        Week number (1-∞)
    """
    days_since_start = (datetime.now() - profile_created_at).days
    current_week = (days_since_start // 7) + 1
    return current_week
```

### 11.2 Increase Criteria

```python
def should_increase_fitness_level(
    user_id: str,
    current_workout: WorkoutLog
) -> bool:
    """
    Determine if fitness level should increase.

    Increase criteria (ALL must be true):
    1. Last 3 workouts of this type were "perfect" or "too_easy"
    2. At least 2 weeks since last increase
    3. Current difficulty matches current fitness level

    This ensures gradual, sustainable progression.

    Returns:
        True if level should increase
    """
    profile = get_fitness_profile(user_id)

    # Get recent workouts of same type
    recent_same_type = get_recent_workouts_by_type(
        user_id,
        current_workout.workout_type,
        count=3
    )

    # Need at least 3 workouts of this type
    if len(recent_same_type) < 3:
        return False

    # Check if all 3 were positive
    positive_feedbacks = [
        w for w in recent_same_type
        if w.feedback in [UserFeedback.PERFECT, UserFeedback.TOO_EASY]
    ]

    if len(positive_feedbacks) < 3:
        return False

    # Check time since last increase (minimum 2 weeks)
    if profile.last_difficulty_increase:
        weeks_since = (datetime.now() - profile.last_difficulty_increase).days / 7
        if weeks_since < 2:
            return False

    return True
```

### 11.3 Progressive Overload Timeline Example

```
User starts: Fitness Level 1 across all types

Week 1, Day 1:
- Recommend: "Deepthi Beginner Low Impact 30min" (Difficulty 1)
- Feedback: "Perfect"

Week 1, Day 3:
- Recommend: "Deepthi Beginner Low Impact 30min" (Difficulty 1)
- Feedback: "Perfect"

Week 2, Day 2:
- Recommend: "Deepthi Beginner Low Impact 30min" (Difficulty 1)
- Feedback: "Perfect"

Week 3, Day 1:
- System checks: 3 consecutive "perfect" for Low Impact
- Increases: cardio_level 1 → 2
- Recommend: "Deepthi Moderate Low Impact 30min" (Difficulty 2)

Week 4, Day 1:
- Now adding Core workouts (Week 3-4 phase)
- Recommend: "Deepthi Beginner Core Workout 25min" (Difficulty 1)
- Core level is still 1, so beginner difficulty

Week 6, Day 1:
- After 3 consecutive "perfect" core workouts + 2 weeks
- Increases: core_level 1 → 2
- Recommend: "Deepthi Moderate Core Workout 30min" (Difficulty 2)
```

---

## 12. Weekly Planning

### 12.1 Weekly Summary

```python
def get_weekly_workout_summary(user_id: str) -> WeeklySummary:
    """
    Get current week's workout summary.

    Provides:
    - Total workouts this week
    - Total minutes exercised
    - Type distribution (how many of each type)
    - Missing types (for variety)

    Returns:
        WeeklySummary with statistics
    """
    # Get workouts from Monday to today
    week_start = get_monday_of_current_week()
    workouts_this_week = get_workouts_since(user_id, week_start)

    # Count by type
    type_counts = {
        WorkoutType.STRENGTH: 0,
        WorkoutType.LOW_IMPACT: 0,
        WorkoutType.CORE: 0,
        WorkoutType.STRETCHING: 0,
        WorkoutType.MOBILITY: 0,
        WorkoutType.RECOVERY: 0
    }

    for workout in workouts_this_week:
        type_counts[workout.workout_type] += 1

    # Calculate stats
    total_workouts = len(workouts_this_week)
    total_minutes = sum(w.duration_minutes for w in workouts_this_week)

    # Find missing types (for variety)
    missing_types = [
        wtype for wtype, count in type_counts.items()
        if count == 0 and wtype != WorkoutType.RECOVERY
    ]

    return WeeklySummary(
        total_workouts=total_workouts,
        total_minutes=total_minutes,
        type_counts=type_counts,
        missing_types=missing_types,
        week_start=week_start
    )
```

### 12.2 Weekly Plan Guidance

```python
def generate_weekly_plan_suggestion(user_id: str) -> str:
    """
    Generate human-readable weekly plan for AI to present.

    Not a rigid schedule - just guidance based on current phase.

    Returns:
        String with weekly plan description
    """
    profile = get_fitness_profile(user_id)
    week = profile.current_week

    if week <= 2:
        return f"""
        Week {week} Focus: Building Foundation

        Goal: Establish workout habit, build base fitness

        Suggested Weekly Structure:
        - 3-4 Low Impact sessions (30 min each)
        - 1-2 Stretching sessions (10-15 min)
        - Rest when needed

        Remember: Quality over quantity. Listen to your body!
        """

    elif week <= 4:
        return f"""
        Week {week} Focus: Core Strength

        Goal: Add core stability, maintain cardio base

        Suggested Weekly Structure:
        - 2-3 Low Impact sessions (30 min)
        - 2 Core workouts (25-30 min)
        - 1 Stretching/Mobility session (15 min)

        Total: 4-5 workouts per week
        """

    elif week <= 8:
        return f"""
        Week {week} Focus: Balanced Strength

        Goal: Build overall strength, maintain variety

        Suggested Weekly Structure:
        - 2 Low Impact sessions (30 min)
        - 2 Strength sessions (30 min)
        - 1 Core workout (25 min)
        - 1 Stretching session (15 min)

        Total: 5-6 workouts per week
        """

    else:
        return f"""
        Week {week} Focus: Full Body Balance

        Goal: Maintain variety, continue progression

        Suggested Weekly Structure:
        - 2 Strength sessions (30 min)
        - 2 Low Impact/Cardio sessions (30 min)
        - 1 Core workout (25 min)
        - 1 Mobility/Stretching session (15 min)
        - 1 Rest or Recovery day

        Total: 6 workouts per week, 1 rest day
        """
```

---

## 13. Monthly Progress Tracking

### 13.1 Monthly Statistics

```python
def get_monthly_progress(user_id: str) -> MonthlyProgress:
    """
    Calculate monthly workout statistics and progress.

    Shows user:
    - Total workouts and minutes
    - Average workouts per week
    - Type distribution
    - Fitness level progression
    - Longest workout streak

    Returns:
        MonthlyProgress with all statistics
    """
    month_start = get_first_day_of_month()
    monthly_workouts = get_workouts_since(user_id, month_start)

    # Calculate basic stats
    total_workouts = len(monthly_workouts)
    total_minutes = sum(w.duration_minutes for w in monthly_workouts)

    # Calculate type distribution
    type_distribution = {}
    for workout in monthly_workouts:
        wtype = workout.workout_type
        type_distribution[wtype] = type_distribution.get(wtype, 0) + 1

    # Calculate consistency (workouts per week)
    weeks_in_month = (datetime.now() - month_start).days / 7
    avg_workouts_per_week = (
        total_workouts / weeks_in_month if weeks_in_month > 0 else 0
    )

    # Get fitness level progression
    profile = get_fitness_profile(user_id)

    # Calculate fitness increase this month
    # (Simplified - would need historical tracking)
    fitness_increase = 0
    if monthly_workouts:
        first_workout = monthly_workouts[-1]
        fitness_increase = (
            profile.overall_fitness_level - first_workout.difficulty_level
        )

    # Calculate longest streak
    longest_streak = calculate_longest_streak(monthly_workouts)

    return MonthlyProgress(
        total_workouts=total_workouts,
        total_minutes=total_minutes,
        avg_workouts_per_week=round(avg_workouts_per_week, 1),
        type_distribution=type_distribution,
        current_fitness_level=profile.overall_fitness_level,
        fitness_level_increase=fitness_increase,
        longest_streak=longest_streak
    )


def calculate_longest_streak(workouts: List[WorkoutLog]) -> int:
    """
    Calculate longest consecutive days with workouts.

    Args:
        workouts: List of workout logs

    Returns:
        Number of consecutive days (longest streak)
    """
    if not workouts:
        return 0

    # Sort by date
    sorted_workouts = sorted(workouts, key=lambda w: w.completed_at)

    longest_streak = 1
    current_streak = 1

    for i in range(1, len(sorted_workouts)):
        prev_date = sorted_workouts[i-1].completed_at.date()
        curr_date = sorted_workouts[i].completed_at.date()

        # Check if consecutive days
        if (curr_date - prev_date).days == 1:
            current_streak += 1
            longest_streak = max(longest_streak, current_streak)
        else:
            current_streak = 1

    return longest_streak
```

---

## 14. Recovery Management

### 14.1 Comprehensive Recovery Assessment

```python
def assess_recovery_needs(user_id: str) -> RecoveryAssessment:
    """
    Comprehensive recovery assessment.

    Considers multiple factors:
    1. Consecutive workout days
    2. Recent intensity (avg difficulty)
    3. Negative feedback count
    4. Total weekly volume (minutes)
    5. Energy levels reported

    Returns:
        RecoveryAssessment with recommendation
    """
    profile = get_fitness_profile(user_id)
    recent_workouts = get_recent_workouts(user_id, days=7)

    # Factor 1: Consecutive days
    consecutive_days = profile.consecutive_workout_days

    # Factor 2: Recent intensity (average difficulty)
    recent_intensity = calculate_avg_intensity(recent_workouts)

    # Factor 3: Negative feedback
    negative_feedback_count = count_negative_feedback(recent_workouts)

    # Factor 4: Weekly volume
    weekly_minutes = sum(w.duration_minutes for w in recent_workouts)

    # Decision logic
    needs_full_rest = False
    needs_active_recovery = False

    # Full rest needed if:
    if consecutive_days >= 5:
        needs_full_rest = True
    elif consecutive_days >= 3 and recent_intensity >= 8:
        needs_full_rest = True

    # Active recovery needed if:
    if consecutive_days >= 3:
        needs_active_recovery = True
    elif negative_feedback_count >= 2:
        needs_active_recovery = True
    elif weekly_minutes >= 180:  # 3+ hours this week
        needs_active_recovery = True

    return RecoveryAssessment(
        needs_full_rest=needs_full_rest,
        needs_active_recovery=needs_active_recovery,
        consecutive_workout_days=consecutive_days,
        recent_intensity=recent_intensity,
        weekly_volume_minutes=weekly_minutes,
        recommendation=generate_recovery_recommendation(
            needs_full_rest,
            needs_active_recovery
        )
    )


def generate_recovery_recommendation(
    needs_full_rest: bool,
    needs_active_recovery: bool
) -> str:
    """
    Generate recovery recommendation for AI to present.
    """
    if needs_full_rest:
        return "Your body needs complete rest today. Take the day off, stay hydrated, and focus on gentle stretching if you want to move."
    elif needs_active_recovery:
        return "Time for active recovery! Try gentle stretching or mobility work (10-15 min). Keep it light - this helps you recover faster."
    else:
        return "You're recovered and ready for your next workout!"


def calculate_avg_intensity(workouts: List[WorkoutLog]) -> float:
    """
    Calculate average workout intensity.

    Returns:
        Average difficulty level (1-10)
    """
    if not workouts:
        return 0.0

    return sum(w.difficulty_level for w in workouts) / len(workouts)


def count_negative_feedback(workouts: List[WorkoutLog]) -> int:
    """
    Count workouts with negative feedback.

    Negative feedback:
    - Feedback: TOO_HARD
    - Energy: EXHAUSTED

    Returns:
        Count of negative feedbacks
    """
    return sum(
        1 for w in workouts
        if w.feedback == UserFeedback.TOO_HARD or
           w.energy_level_after == EnergyLevel.EXHAUSTED
    )
```

---

## 15. AI Integration

### 15.1 System Prompt for Workout Coach

```python
WORKOUT_ENGINE_SYSTEM_PROMPT = """
You are a supportive workout coach specialized in Deepthi fitness videos.

## Your Role

You help users with home-based workouts that fit their busy life with a baby.
You recommend workouts from Deepthi's style - bodyweight exercises, small space, beginner to advanced.

## Workout Types You Know

1. **Low Impact Cardio**
   - Gentle, joint-friendly cardio
   - Walking, marching, low-intensity movement
   - Great for beginners and recovery days

2. **Strength Training**
   - Resistance exercises
   - Squats, lunges, arm work, full body
   - Builds muscle, increases metabolism

3. **Core Workout**
   - Ab and core strengthening
   - Planks, crunches, stability work
   - Essential for posture and overall strength

4. **Stretching**
   - Full body flexibility work
   - Gentle stretches, hold and breathe
   - Perfect for recovery and mobility

5. **Mobility**
   - Joint mobility and movement prep
   - Dynamic stretches, flow movements
   - Helps prevent injury

6. **Recovery**
   - Gentle active recovery
   - Light stretching, breathing work
   - For rest days when you want to move

## Deepthi Video Style

- All bodyweight (no equipment needed)
- Home-friendly (small space, baby nearby)
- Clear instructions with modifications
- Beginner to advanced options in same video
- Typical durations: 10 min (quick), 20-30 min (full session)
- Motivating but gentle, not aggressive

## Progressive Overload Phases

### Weeks 1-2: Foundation
- Focus: Low Impact only
- Goal: Build base fitness, establish habit
- Frequency: 3-4 workouts/week

### Weeks 3-4: Core Building
- Focus: Low Impact + Core
- Goal: Add core strength
- Frequency: 4-5 workouts/week

### Weeks 5-8: Strength Introduction
- Focus: Low Impact + Core + Strength (rotation)
- Goal: Build overall strength
- Frequency: 5-6 workouts/week

### Week 9+: Full Rotation
- Focus: All types, balanced variety
- Goal: Maintain progress, continue improvement
- Frequency: 6 workouts/week + 1 rest

## User Context (Dynamic)

Current Week: {current_week}
Overall Fitness Level: {fitness_level}/10

Specific Levels:
- Strength: {strength_level}/10
- Core: {core_level}/10
- Cardio: {cardio_level}/10
- Flexibility: {flexibility_level}/10

Recent Workouts:
{recent_workouts}

Recovery Status: {recovery_status}
Consecutive Workout Days: {consecutive_days}

Total Workouts Completed: {total_workouts}

## Your Recommendations

### When User Asks for Workout

1. **Check recovery first**
   - If recovery needed: Suggest stretching/mobility only
   - If full rest needed: Suggest complete day off

2. **Ask about time**
   - "Do you have 10 or 30 minutes today?"
   - Respect their available time

3. **Recommend appropriate workout**
   - Match difficulty to their fitness level
   - Follow progressive phase
   - Rotate types for variety
   - Example: "Try Deepthi Moderate Core Workout 30min"

4. **Explain briefly why**
   - "This builds on your recent low impact work"
   - "Let's strengthen that core today"
   - Keep it brief and motivating

### After Workout

1. **Ask how it was**
   - "How was it?"
   - "How are you feeling?"

2. **Listen for feedback**
   - "too easy", "perfect", "too hard"
   - Energy level: "energized", "tired", "exhausted"

3. **Acknowledge and encourage**
   - Positive feedback: "Amazing work! That's exactly what we want to hear!"
   - Too hard: "I hear you. Let's dial it back a bit next time."
   - Too easy: "Love the progress! Ready to level up soon?"

4. **Never shame or guilt**
   - Skipped: "That's okay! Rest is important. We'll get back to it when you're ready."
   - Exhausted: "Your body is telling us something important. Let's take it easier."

## Conversation Style

**DO:**
- Be supportive and encouraging
- Respect their time and energy
- Acknowledge their challenges (baby, busy life)
- Keep it brief and actionable
- Celebrate small wins
- Use their name if you know it

**DON'T:**
- Shame or guilt for skipping workouts
- Push too hard
- Use aggressive fitness language
- Assume they have unlimited time/energy
- Compare them to others

## Example Conversations

### Scenario 1: First Workout Request

User: "What workout should I do today?"

You: "Great! You're in Week 1, so we're building that foundation. Do you have 10 or 30 minutes?"

User: "30 minutes"

You: "Perfect! Try Deepthi Beginner Low Impact Cardio 30min. It's a gentle introduction to get your body moving - no jumping, easy on the joints. Ready to start?"

### Scenario 2: After Perfect Workout

User: "Done! It was perfect."

You: "Excellent work! That's exactly what we want to hear - challenging but doable. How are you feeling energy-wise?"

User: "Energized!"

You: "Love it! That's a sign you're at the right level. Rest well tonight, and I'll have another good one for you tomorrow 💪"

### Scenario 3: After Too-Hard Workout

User: "Finished but it was too hard."

You: "I hear you, and thank you for being honest. That's valuable feedback. Let's dial it back a bit next time - there's no rush. Your body is telling us something important. How are you feeling energy-wise?"

User: "Pretty tired."

You: "Got it. Take it easy today, maybe some gentle stretching later if you feel up to it. Tomorrow we'll try something lighter. You're doing great by listening to your body!"

### Scenario 4: Recovery Day Needed

User: "What workout should I do?"

You: "You've been crushing it! 3 days in a row - your body has earned a recovery day. I recommend either:
1. Complete rest (totally okay!)
2. Gentle stretching (10-15 min, super light)

What sounds better to you?"

### Scenario 5: Time-Limited

User: "What workout today? But I only have 10 minutes."

You: "10 minutes is perfect! Try Deepthi Quick Core Workout 10min. Short and effective - you'll feel it! Every minute counts 💪"

## Success Metrics

You're doing great if:
- User completes workouts consistently (3-5 times/week)
- User reports "perfect" or "too easy" most of the time
- User's fitness level increases gradually (every 2-4 weeks)
- User feels motivated, not guilty
- User sticks with it long-term (months, not weeks)

Remember: Sustainable progress > Quick results. You're building a lifelong habit, not a 30-day challenge.
"""


def build_workout_context_for_ai(user_id: str) -> Dict[str, Any]:
    """
    Build dynamic context to inject into AI system prompt.

    Returns:
        Dictionary with all context variables
    """
    profile = get_fitness_profile(user_id)
    recent_workouts = get_recent_workouts(user_id, days=7)
    recovery = assess_recovery_needs(user_id)

    # Format recent workouts
    workouts_text = "\n".join([
        f"- {w.completed_at.strftime('%A')}: {w.workout_name} ({w.feedback.value if w.feedback else 'no feedback'})"
        for w in recent_workouts[:5]
    ]) if recent_workouts else "No workouts yet this week"

    return {
        'current_week': profile.current_week,
        'fitness_level': profile.overall_fitness_level,
        'strength_level': profile.strength_level,
        'core_level': profile.core_level,
        'cardio_level': profile.cardio_level,
        'flexibility_level': profile.flexibility_level,
        'recent_workouts': workouts_text,
        'recovery_status': recovery.recommendation,
        'consecutive_days': profile.consecutive_workout_days,
        'total_workouts': profile.total_workouts_completed
    }
```

### 15.2 AI Prompt Building

```python
def build_ai_prompt_for_workout(user_id: str) -> str:
    """
    Build complete AI prompt with dynamic context.

    Returns:
        Complete system prompt with user context injected
    """
    context = build_workout_context_for_ai(user_id)

    return WORKOUT_ENGINE_SYSTEM_PROMPT.format(**context)
```

---

## 16. Complete Flow Examples

### 16.1 Example: First Workout (Week 1, Day 1)

```
Initial State:
- User: Week 1, Day 1
- Fitness Level: 1 across all types
- No workout history

---

User: "What workout should I do today?"

System Processing:
1. Get fitness profile: Week 1, Overall Level 1
2. Recent workouts: None
3. Recovery needed: No
4. Workout type: LOW_IMPACT (Week 1-2 phase)
5. Difficulty: 1 (matches fitness level)
6. Duration: Need to ask

AI Response:
"Starting your fitness journey - exciting! You're in Week 1, so we're building that foundation with low-impact cardio. Do you have 10 or 30 minutes?"

User: "30 minutes"

System: Generates recommendation
- Type: LOW_IMPACT
- Difficulty: 1
- Name: "Deepthi Beginner Low Impact Cardio 30min"

AI Response:
"Perfect! Try Deepthi Beginner Low Impact Cardio 30min. It's a gentle introduction - no jumping, easy on the joints, perfect for starting out. Ready to go?"

User: "Yes!"

---

[After workout]

User: "Done! It was perfect."

System Processing:
1. Parse feedback: completed=True, feedback=PERFECT, energy=None
2. Create WorkoutLog:
   - workout_type: LOW_IMPACT
   - difficulty_level: 1
   - feedback: PERFECT
3. Update profile:
   - total_workouts_completed: 0 → 1
   - consecutive_workout_days: 0 → 1
   - last_workout_date: today
4. Check progressive overload: Not yet (need 3 consecutive)

AI Response:
"Excellent work! That's a great start. How are you feeling energy-wise?"

User: "Energized!"

System: Updates energy_level_after = ENERGIZED

AI Response:
"Love it! That's a sign you're at the right level. Rest well tonight. Tomorrow you can do another session or take a rest day - totally your choice 💪"
```

### 16.2 Example: Fitness Level Increase (Week 3)

```
Current State:
- User: Week 3, Day 1
- Fitness Level: Cardio 1, Others 1
- Recent workouts: 3x Low Impact (all "perfect")
- No difficulty increase yet

---

User: "What workout should I do?"

System Processing:
1. Get fitness profile: Week 3, Cardio Level 1
2. Recent workouts: 3x Low Impact (all PERFECT feedback)
3. Check progressive overload:
   - Last 3 Low Impact workouts: All PERFECT
   - Time since last increase: N/A (first time)
   - Criteria met: YES
4. Increase fitness level:
   - cardio_level: 1 → 2
   - overall_fitness_level: 1 → 1.25 → rounds to 1
5. Workout type: Still LOW_IMPACT (Week 3-4 can add CORE)
6. Difficulty: 2 (matches new cardio level)

AI Response:
"Amazing progress! You've been crushing those beginner workouts. Your fitness level just increased to 2 - ready for more challenge? Do you have 10 or 30 minutes?"

User: "30"

System: Generates recommendation
- Type: LOW_IMPACT
- Difficulty: 2
- Name: "Deepthi Moderate Low Impact Cardio 30min"

AI Response:
"Perfect! Try Deepthi Moderate Low Impact Cardio 30min. This is a step up from what you've been doing - you're ready for it! Let me know how it feels."

---

[After workout]

User: "Done! It was a bit harder but still good."

System: Logs feedback=PERFECT, difficulty matched well

AI Response:
"That's exactly what we want - a bit of a challenge but still manageable. You're progressing beautifully! Tomorrow we can add some core work to mix things up."
```

### 16.3 Example: Recovery Day (After 3 Consecutive Days)

```
Current State:
- User: Week 5
- Fitness Level: Overall 3
- Recent workouts:
  - Yesterday: Strength (PERFECT)
  - 2 days ago: Core (PERFECT)
  - 3 days ago: Low Impact (PERFECT)
- Consecutive workout days: 3

---

User: "What workout today?"

System Processing:
1. Get fitness profile: Week 5, Level 3, consecutive_days=3
2. Recovery assessment:
   - Consecutive days: 3
   - Recent intensity: 4.3 (average difficulty)
   - Negative feedback: 0
   - Weekly volume: 90 minutes
   - Decision: needs_active_recovery = True
3. Recommend recovery workout

AI Response:
"You've been amazing! 3 days in a row - your body has earned some recovery. I recommend:
1. Complete rest (totally okay!)
2. Gentle stretching or mobility (10-15 min, super light)

What sounds better?"

User: "I'll do some stretching."

System: Generates recovery recommendation
- Type: STRETCHING
- Difficulty: 2 (always low for recovery)
- Name: "Deepthi Gentle Full Body Stretch 15min"

AI Response:
"Great choice! Try Deepthi Gentle Full Body Stretch 15min. Keep it slow and relaxed - this helps you recover faster. You'll be fresh for tomorrow's workout!"

---

[After stretching]

User: "Done! Feel so much better."

System:
- Logs workout (RECOVERY type)
- Resets consecutive_workout_days: 3 → 1 (recovery doesn't count as intense workout)

AI Response:
"Perfect! That's what recovery is for - helping you feel refreshed. Tomorrow you can jump back into a regular workout, or take another day if you need it. Listening to your body is the key to long-term success!"
```

### 16.4 Example: "Too Hard" Feedback Pattern

```
Current State:
- User: Week 7
- Fitness Level: Strength 4
- Recent strength workouts: 2x "too hard"

---

User: "What workout should I do?"

System Processing:
1. Get recent workouts: 2x Strength workouts with TOO_HARD feedback
2. Check decrease criteria: 2 consecutive "too hard" = YES
3. Decrease strength level: 4 → 3
4. Workout type: STRENGTH (need to rebuild confidence)
5. Difficulty: 3 (matches decreased level)

AI Response:
"Hey! I noticed your last couple strength workouts felt too hard. Let's dial it back a bit - there's no rush. Do you have 30 minutes?"

User: "Yes"

System: Generates recommendation
- Type: STRENGTH
- Difficulty: 3
- Name: "Deepthi Moderate Strength Training 30min"

AI Response:
"Perfect! Try Deepthi Moderate Strength Training 30min. This is a bit lighter than what we've been doing - let's make sure it feels good. No pressure, just focus on form!"

---

[After workout]

User: "That was perfect! Felt much better."

System: Logs feedback=PERFECT, good sign

AI Response:
"Yes! That's exactly what I wanted to hear. Sometimes we need to take a small step back to move forward sustainably. You're listening to your body - that's the smart approach. We'll build back up gradually!"
```

### 16.5 Example: Time-Limited (10 Minutes)

```
User: "I only have 10 minutes today. What should I do?"

System Processing:
1. Duration specified: 10 minutes
2. Get fitness profile: Week 8, Core Level 5
3. Workout type: CORE (balanced rotation)
4. Difficulty: 5
5. Generate 10-minute workout

AI Response:
"10 minutes is perfect! Try Deepthi Moderate Core Workout 10min. Short and effective - you'll feel it working! Every minute counts 💪"

User: "Done! That was intense but good."

AI Response:
"Love it! 10 minutes of focused work is better than 30 minutes of distracted exercise. You made it count - great job!"
```

---

## Conclusion

The Workout Recommendation Engine provides intelligent, adaptive, conversational workout recommendations that:

1. **Progress gradually** - Week-based phases, feedback-driven difficulty increases
2. **Prevent overtraining** - Automatic recovery days, intensity monitoring
3. **Adapt to user** - Learns from feedback, adjusts difficulty up or down
4. **Fit real life** - 10 or 30 minute options, home-based, baby-friendly
5. **Stay motivating** - Celebrate progress, never shame, supportive tone

**Key Success Factors:**
- Structured data (workout logs, fitness profile) + AI intelligence
- Progressive overload with clear phases (Weeks 1-2, 3-4, 5-8, 9+)
- Feedback-driven adaptation (3 "perfect" → level up, 2 "too hard" → step back)
- Recovery management (3 consecutive days → recovery needed)
- Conversational presentation (AI presents, user doesn't see the structure)

**Integration Points:**
- Fits into existing AI chat interface
- Uses same conversation patterns as nutrition engine
- Stores data in SQLite (matches existing architecture)
- Syncs to Firebase for backup
- Analytics ready (weekly/monthly progress tracking)

---

**Document prepared by:** Fitness Algorithm Specialist
**Last updated:** 2026-07-03
**Version:** 1.0
