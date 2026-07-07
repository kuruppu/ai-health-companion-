import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  // Today's metrics
  final int? todayEnergyLevel;
  final String todayEnergyMessage;

  // This week
  final int workoutsThisWeek;
  final double avgEnergyThisWeek;
  final int daysLoggedThisWeek;

  // Goal progress
  final String? emotionalGoal;
  final double goalProgress; // 0.0 to 1.0
  final String goalProgressMessage;

  // Weight tracking (secondary)
  final double? currentWeight;
  final double? goalWeight;
  final double? weightLostSoFar;

  // Milestones
  final List<String> recentMilestones;

  // Streak
  final int currentStreak;

  const DashboardSummary({
    this.todayEnergyLevel,
    required this.todayEnergyMessage,
    required this.workoutsThisWeek,
    required this.avgEnergyThisWeek,
    required this.daysLoggedThisWeek,
    this.emotionalGoal,
    required this.goalProgress,
    required this.goalProgressMessage,
    this.currentWeight,
    this.goalWeight,
    this.weightLostSoFar,
    required this.recentMilestones,
    required this.currentStreak,
  });

  @override
  List<Object?> get props => [
        todayEnergyLevel,
        todayEnergyMessage,
        workoutsThisWeek,
        avgEnergyThisWeek,
        daysLoggedThisWeek,
        emotionalGoal,
        goalProgress,
        goalProgressMessage,
        currentWeight,
        goalWeight,
        weightLostSoFar,
        recentMilestones,
        currentStreak,
      ];
}
