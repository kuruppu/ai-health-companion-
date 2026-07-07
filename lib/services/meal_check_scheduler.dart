import 'package:injectable/injectable.dart';

import '../domain/entities/meal_check_in.dart';

/// Service to schedule and trigger meal check-ins
@singleton
class MealCheckScheduler {
  final List<Function(MealPeriod)> _listeners = [];

  /// Register a listener for meal check events
  void addListener(Function(MealPeriod) listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  void removeListener(Function(MealPeriod) listener) {
    _listeners.remove(listener);
  }

  /// Check if current time matches any meal check-in time
  void checkSchedule(DateTime now) {
    final hour = now.hour;
    final minute = now.minute;

    // Check each meal period
    for (final period in MealPeriod.values) {
      if (hour == period.checkInHour && minute == period.checkInMinute) {
        _triggerCheckIn(period);
      }
    }
  }

  /// Manually trigger a check-in (for testing)
  void triggerCheckIn(MealPeriod period) {
    _triggerCheckIn(period);
  }

  void _triggerCheckIn(MealPeriod period) {
    for (final listener in _listeners) {
      listener(period);
    }
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

  /// Check if user has eaten during meal window
  bool hasEatenInWindow(MealPeriod period, DateTime? lastMealTime) {
    if (lastMealTime == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final (startHour, endHour) = period.window;
    final windowStart = today.add(Duration(hours: startHour));
    final windowEnd = today.add(Duration(hours: endHour));

    return lastMealTime.isAfter(windowStart) &&
        lastMealTime.isBefore(windowEnd);
  }
}
