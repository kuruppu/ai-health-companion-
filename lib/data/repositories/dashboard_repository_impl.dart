import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/progress_log.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../local/database/app_database.dart';
import '../models/progress_log_model.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final AppDatabase _database;
  final Uuid _uuid;

  DashboardRepositoryImpl(this._database, this._uuid);

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    String userId,
  ) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      // Get progress logs for this week
      final logs = await _database
          .watchProgressLogs(
            userId,
            weekStart,
            weekEnd,
          )
          .first;

      // Get today's log
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      final todayLogs = logs.where((log) {
        return log.loggedAt.isAfter(todayStart) &&
            log.loggedAt.isBefore(todayEnd);
      }).toList();

      final todayLog = todayLogs.isNotEmpty ? todayLogs.first : null;

      // Calculate metrics
      final energyLevels = logs
          .where((log) => log.energyLevel != null)
          .map((e) => e.energyLevel!);
      final avgEnergy = energyLevels.isNotEmpty
          ? energyLevels.reduce((a, b) => a + b) / energyLevels.length
          : 0.0;

      // TODO: Get workout count from workouts table
      final workoutsThisWeek = 0;

      // Get user profile for goal info
      final profile = await _database.getUserProfile(userId);

      // Calculate goal progress (mock for now)
      final goalProgress = 0.6; // 60%

      final summary = DashboardSummary(
        todayEnergyLevel: todayLog?.energyLevel,
        todayEnergyMessage: _getEnergyMessage(todayLog?.energyLevel),
        workoutsThisWeek: workoutsThisWeek,
        avgEnergyThisWeek: avgEnergy,
        daysLoggedThisWeek: logs.length,
        emotionalGoal: profile?.emotionalGoal,
        goalProgress: goalProgress,
        goalProgressMessage: _getGoalProgressMessage(goalProgress),
        currentWeight: profile?.currentWeightKg,
        goalWeight: profile?.goalWeightKg,
        weightLostSoFar: profile != null && profile.currentWeightKg != null
            ? (81.0 - profile.currentWeightKg!) // Starting weight hardcoded
            : null,
        recentMilestones: _getRecentMilestones(logs),
        currentStreak: logs.length,
      );

      return Right(summary);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProgressLog>> logEnergyLevel({
    required String userId,
    required int energyLevel,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final logId = _uuid.v4();

      final log = ProgressLogModel(
        logId: logId,
        userId: userId,
        energyLevel: energyLevel,
        notes: notes,
        loggedAt: now,
        createdAt: now,
      );

      await _database.insertProgressLog(
        ProgressLogsTableCompanion.insert(
          logId: logId,
          userId: userId,
          energyLevel: Value(energyLevel),
          notes: Value(notes),
          loggedAt: Value(now),
          createdAt: Value(now),
        ),
      );

      return Right(log.toEntity());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProgressLog>>> getProgressLogs({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final logs = await _database
          .watchProgressLogs(
            userId,
            startDate,
            endDate,
          )
          .first;

      return Right(logs.map((log) {
        return ProgressLog(
          logId: log.logId,
          userId: log.userId,
          weightKg: log.weightKg,
          energyLevel: log.energyLevel,
          sleepQuality: log.sleepQuality,
          moodRating: log.moodRating,
          stressLevel: log.stressLevel,
          notes: log.notes,
          loggedAt: log.loggedAt,
          createdAt: log.createdAt,
        );
      }).toList());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProgressLog?>> getTodayProgressLog(
    String userId,
  ) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final logs = await _database
          .watchProgressLogs(
            userId,
            todayStart,
            todayEnd,
          )
          .first;

      if (logs.isEmpty) {
        return const Right(null);
      }

      final log = logs.first;
      return Right(ProgressLog(
        logId: log.logId,
        userId: log.userId,
        weightKg: log.weightKg,
        energyLevel: log.energyLevel,
        sleepQuality: log.sleepQuality,
        moodRating: log.moodRating,
        stressLevel: log.stressLevel,
        notes: log.notes,
        loggedAt: log.loggedAt,
        createdAt: log.createdAt,
      ));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  String _getEnergyMessage(int? energyLevel) {
    if (energyLevel == null) {
      return 'How are you feeling today?';
    }

    switch (energyLevel) {
      case 5:
        return 'You\'re on fire today! 🔥';
      case 4:
        return 'Feeling great! Keep it up! ⚡';
      case 3:
        return 'Doing okay. Stay consistent! 💪';
      case 2:
        return 'A bit low. Rest if needed 💤';
      case 1:
        return 'Take it easy today. Rest matters 🌙';
      default:
        return 'How are you feeling?';
    }
  }

  String _getGoalProgressMessage(double progress) {
    if (progress < 0.25) {
      return 'Just getting started!';
    } else if (progress < 0.5) {
      return 'Making steady progress!';
    } else if (progress < 0.75) {
      return 'More than halfway there!';
    } else if (progress < 1.0) {
      return 'Almost at your goal!';
    } else {
      return 'Goal achieved! 🎉';
    }
  }

  List<String> _getRecentMilestones(List<ProgressLogsTableData> logs) {
    // TODO: Extract actual milestones from logs
    return [
      'Played with baby for 30 min straight',
      'Climbed 3 flights without breathlessness',
    ];
  }
}
