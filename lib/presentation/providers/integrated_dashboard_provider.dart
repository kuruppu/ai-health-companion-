import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/meal.dart';
import '../../domain/entities/workout_log.dart';
import 'auth_provider.dart';
import 'meal_check_provider.dart';
import 'meal_provider.dart';
import 'workout_provider.dart';

part 'integrated_dashboard_provider.g.dart';

/// Integrated dashboard data combining meals, workouts, and check-ins
class IntegratedDashboardData {
  // Today's meals
  final List<Meal> todaysMeals;
  final double avgHealthScore;
  final int mealsLogged;

  // Today's workouts
  final List<WorkoutLog> todaysWorkouts;
  final int workoutsCompleted;
  final int minutesExercised;

  // Meal check status
  final bool hadBreakfast;
  final bool hadLunch;
  final bool hadDinner;
  final int mealsSkipped;

  // Weekly stats
  final double weeklyMealSkipRate;
  final int weeklyWorkoutCount;

  const IntegratedDashboardData({
    required this.todaysMeals,
    required this.avgHealthScore,
    required this.mealsLogged,
    required this.todaysWorkouts,
    required this.workoutsCompleted,
    required this.minutesExercised,
    required this.hadBreakfast,
    required this.hadLunch,
    required this.hadDinner,
    required this.mealsSkipped,
    required this.weeklyMealSkipRate,
    required this.weeklyWorkoutCount,
  });

  /// Get status message for meals
  String get mealStatusMessage {
    if (mealsLogged == 0) {
      return 'No meals logged yet today';
    } else if (mealsLogged == 1) {
      return '1 meal logged today';
    } else {
      return '$mealsLogged meals logged today';
    }
  }

  /// Get status message for workouts
  String get workoutStatusMessage {
    if (workoutsCompleted == 0) {
      return 'No workouts yet today';
    } else if (workoutsCompleted == 1) {
      return '1 workout completed';
    } else {
      return '$workoutsCompleted workouts completed';
    }
  }

  /// Get health score message
  String get healthScoreMessage {
    if (mealsLogged == 0) return '';

    if (avgHealthScore >= 4.0) {
      return 'Excellent food choices today!';
    } else if (avgHealthScore >= 3.0) {
      return 'Good nutrition choices';
    } else {
      return 'Room for improvement';
    }
  }

  /// Get skip warning message
  String? get skipWarningMessage {
    if (mealsSkipped == 0) return null;

    if (mealsSkipped == 1) {
      return 'You skipped 1 meal today';
    } else {
      return 'You skipped $mealsSkipped meals today';
    }
  }

  /// Get next action suggestion
  String get nextActionSuggestion {
    final now = DateTime.now();
    final hour = now.hour;

    // Check meal skips first
    if (!hadBreakfast && hour < 11) {
      return 'Log your breakfast';
    } else if (!hadLunch && hour >= 11 && hour < 15) {
      return 'Log your lunch';
    } else if (!hadDinner && hour >= 17) {
      return 'Log your dinner';
    }

    // Then workouts
    if (workoutsCompleted == 0 && hour >= 14 && hour < 20) {
      return 'Start a workout';
    }

    // Default
    if (mealsLogged < 3) {
      return 'Keep logging meals';
    } else if (workoutsCompleted == 0) {
      return 'Do a quick workout';
    } else {
      return 'Great job today!';
    }
  }
}

@riverpod
class IntegratedDashboard extends _$IntegratedDashboard {
  @override
  Future<IntegratedDashboardData> build() async {
    final authState = ref.watch(authProvider);
    final user = authState.value?.getCurrentUser();

    if (user == null) {
      return const IntegratedDashboardData(
        todaysMeals: [],
        avgHealthScore: 0,
        mealsLogged: 0,
        todaysWorkouts: [],
        workoutsCompleted: 0,
        minutesExercised: 0,
        hadBreakfast: false,
        hadLunch: false,
        hadDinner: false,
        mealsSkipped: 0,
        weeklyMealSkipRate: 0,
        weeklyWorkoutCount: 0,
      );
    }

    // Get today's meals
    final mealsState = ref.watch(todaysMealsProvider);
    final meals = mealsState.maybeWhen(
      data: (meals) => meals,
      orElse: () => <Meal>[],
    );

    // Calculate meal stats
    final mealsLogged = meals.length;
    final avgHealthScore = meals.isEmpty
        ? 0.0
        : meals.map((m) => m.analysis.healthScore).reduce((a, b) => a + b) /
            meals.length;

    // Get today's workout logs
    final workoutLogsState = ref.watch(todaysWorkoutLogsProvider);
    final workoutLogs = workoutLogsState.maybeWhen(
      data: (logs) => logs,
      orElse: () => <WorkoutLog>[],
    );

    final workoutsCompleted = workoutLogs.length;
    final minutesExercised = workoutLogs.isEmpty
        ? 0
        : workoutLogs.map((w) => w.durationMinutes).reduce((a, b) => a + b);

    // Get meal check status
    final skipRate =
        ref.read(mealCheckNotifierProvider.notifier).getSkipRate(user.userId);

    // Determine which meals were eaten today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool hadBreakfast = false;
    bool hadLunch = false;
    bool hadDinner = false;

    for (final meal in meals) {
      final hour = meal.eatenAt.hour;

      if (hour >= 6 && hour < 11) {
        hadBreakfast = true;
      } else if (hour >= 11 && hour < 15) {
        hadLunch = true;
      } else if (hour >= 17 && hour < 22) {
        hadDinner = true;
      }
    }

    // Calculate skipped meals
    int mealsSkipped = 0;
    if (now.hour >= 11 && !hadBreakfast) mealsSkipped++;
    if (now.hour >= 15 && !hadLunch) mealsSkipped++;
    if (now.hour >= 21 && !hadDinner) mealsSkipped++;

    // Calculate weekly workout count
    final weekStart = now.subtract(Duration(days: 7));
    final allWorkoutLogsState = ref.watch(workoutLogsProvider);
    final weeklyWorkoutCount = allWorkoutLogsState.maybeWhen(
      data: (logs) =>
          logs.where((log) => log.completedAt.isAfter(weekStart)).length,
      orElse: () => 0,
    );

    return IntegratedDashboardData(
      todaysMeals: meals,
      avgHealthScore: avgHealthScore,
      mealsLogged: mealsLogged,
      todaysWorkouts: workoutLogs,
      workoutsCompleted: workoutsCompleted,
      minutesExercised: minutesExercised,
      hadBreakfast: hadBreakfast,
      hadLunch: hadLunch,
      hadDinner: hadDinner,
      mealsSkipped: mealsSkipped,
      weeklyMealSkipRate: skipRate,
      weeklyWorkoutCount: weeklyWorkoutCount,
    );
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
