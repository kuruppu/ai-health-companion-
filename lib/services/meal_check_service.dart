import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../domain/entities/meal_check_in.dart';

/// Service to handle meal check-in logic
@singleton
class MealCheckService {

  MealCheckService(this._uuid);
  final Uuid _uuid;
  final Map<String, DateTime> _lastMealTimes = {};
  final List<MealCheckIn> _checkInHistory = [];

  /// Record that user logged a meal
  void recordMealLogged(String userId, DateTime mealTime) {
    _lastMealTimes[userId] = mealTime;
  }

  /// Get last meal time for user
  DateTime? getLastMealTime(String userId) => _lastMealTimes[userId];

  /// Check if user needs a check-in for this meal period
  bool needsCheckIn(String userId, MealPeriod period) {
    final lastMealTime = _lastMealTimes[userId];
    if (lastMealTime == null) return true;

    // Check if last meal was in this period's window
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final (startHour, endHour) = period.window;
    final windowStart = today.add(Duration(hours: startHour));
    final windowEnd = today.add(Duration(hours: endHour));

    // User doesn't need check-in if they ate in this window
    return !(lastMealTime.isAfter(windowStart) &&
        lastMealTime.isBefore(windowEnd));
  }

  /// Generate AI check-in message
  String generateCheckInMessage(MealPeriod period, String userName) {
    final messages = {
      MealPeriod.breakfast: [
        'Morning $userName! Have you eaten breakfast?',
        'Good morning! Breakfast check - have you eaten?',
        'Hey $userName, breakfast time - did you eat?',
      ],
      MealPeriod.lunch: [
        'Lunch check - have you eaten?',
        'Hey $userName, have you had lunch yet?',
        'Lunch time! Have you eaten?',
      ],
      MealPeriod.dinner: [
        'Dinner check - have you eaten?',
        'Evening $userName! Have you had dinner?',
        'Dinner time - did you eat?',
      ],
    };

    final options = messages[period]!;
    return options[DateTime.now().second % options.length];
  }

  /// Record check-in response
  MealCheckIn recordCheckIn({
    required String userId,
    required MealPeriod period,
    required bool hadEaten,
    String? response,
    String? mealId,
  }) {
    final checkIn = MealCheckIn(
      checkInId: _uuid.v4(),
      userId: userId,
      mealPeriod: period,
      checkInTime: DateTime.now(),
      hadEaten: hadEaten,
      response: response,
      mealId: mealId,
    );

    _checkInHistory.add(checkIn);

    // If user ate, update last meal time
    if (hadEaten) {
      _lastMealTimes[userId] = DateTime.now();
    }

    return checkIn;
  }

  /// Get check-in history for user
  List<MealCheckIn> getCheckInHistory(String userId, {int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));

    return _checkInHistory
        .where((c) => c.userId == userId && c.checkInTime.isAfter(cutoff))
        .toList()
      ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
  }

  /// Get meal skip rate for user (last 7 days)
  double getMealSkipRate(String userId) {
    final history = getCheckInHistory(userId);
    if (history.isEmpty) return 0;

    final skipped = history.where((c) => !c.hadEaten).length;
    return skipped / history.length;
  }

  /// Get most commonly skipped meal period
  MealPeriod? getMostSkippedPeriod(String userId) {
    final history = getCheckInHistory(userId);
    if (history.isEmpty) return null;

    final skippedByPeriod = <MealPeriod, int>{};

    for (final checkIn in history) {
      if (!checkIn.hadEaten) {
        skippedByPeriod[checkIn.mealPeriod] =
            (skippedByPeriod[checkIn.mealPeriod] ?? 0) + 1;
      }
    }

    if (skippedByPeriod.isEmpty) return null;

    return skippedByPeriod.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
