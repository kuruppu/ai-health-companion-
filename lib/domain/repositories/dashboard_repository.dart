import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/dashboard_summary.dart';
import '../entities/progress_log.dart';

abstract class DashboardRepository {
  /// Get today's dashboard summary
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(String userId);

  /// Log energy level for today
  Future<Either<Failure, ProgressLog>> logEnergyLevel({
    required String userId,
    required int energyLevel,
    String? notes,
  });

  /// Get progress logs for date range
  Future<Either<Failure, List<ProgressLog>>> getProgressLogs({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get today's progress log
  Future<Either<Failure, ProgressLog?>> getTodayProgressLog(String userId);
}
