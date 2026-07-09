import 'dart:async';

import 'package:injectable/injectable.dart';

import '../domain/entities/meal_check_in.dart';
import 'meal_check_service.dart';

/// Integrated scheduler that triggers check-ins through chat
@singleton
class IntegratedMealCheckScheduler {

  IntegratedMealCheckScheduler(this._checkService);
  final MealCheckService _checkService;
  Timer? _timer;

  /// Start scheduling check-ins
  void start({
    required Function(MealPeriod) onCheckIn,
  }) {
    // Check every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      _checkSchedule(now, onCheckIn);
    });
  }

  /// Stop scheduling
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Check if current time matches any check-in time
  void _checkSchedule(DateTime now, Function(MealPeriod) onCheckIn) {
    final hour = now.hour;
    final minute = now.minute;

    // Check each meal period
    for (final period in MealPeriod.values) {
      if (hour == period.checkInHour && minute == period.checkInMinute) {
        onCheckIn(period);
      }
    }
  }

  /// Manually trigger check-in (for testing)
  void triggerCheckIn(MealPeriod period, Function(MealPeriod) onCheckIn) {
    onCheckIn(period);
  }

  /// Get next scheduled check-in time
  DateTime getNextCheckIn() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check all meal periods today
    for (final period in MealPeriod.values) {
      final checkInTime = today.add(
        Duration(
          hours: period.checkInHour,
          minutes: period.checkInMinute,
        ),
      );

      if (checkInTime.isAfter(now)) {
        return checkInTime;
      }
    }

    // If all today's check-ins passed, return tomorrow's breakfast
    return today.add(
      Duration(
        days: 1,
        hours: MealPeriod.breakfast.checkInHour,
        minutes: MealPeriod.breakfast.checkInMinute,
      ),
    );
  }
}
