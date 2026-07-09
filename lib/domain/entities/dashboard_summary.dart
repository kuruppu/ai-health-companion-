import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {

  const DashboardSummary({
    required this.todayEnergyMessage, required this.workoutsThisWeek, required this.avgEnergyThisWeek, required this.daysLoggedThisWeek, required this.goalProgress, required this.goalProgressMessage, required this.recentMilestones, required this.currentStreak, this.todayEnergyLevel,
    this.emotionalGoal,
    this.currentWeight,
    this.goalWeight,
    this.weightLostSoFar,
  });
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
