import 'package:equatable/equatable.dart';

/// Represents a meal check-in event
class MealCheckIn extends Equatable {
  /// Unique identifier
  final String checkInId;

  /// User being checked in on
  final String userId;

  /// Meal period (breakfast, lunch, dinner)
  final MealPeriod mealPeriod;

  /// When the check-in occurred
  final DateTime checkInTime;

  /// Whether user had eaten
  final bool hadEaten;

  /// User's response (text or "photo_sent")
  final String? response;

  /// Meal ID if they logged one
  final String? mealId;

  const MealCheckIn({
    required this.checkInId,
    required this.userId,
    required this.mealPeriod,
    required this.checkInTime,
    required this.hadEaten,
    this.response,
    this.mealId,
  });

  @override
  List<Object?> get props => [
        checkInId,
        userId,
        mealPeriod,
        checkInTime,
        hadEaten,
        response,
        mealId,
      ];
}

/// Meal periods for check-ins
enum MealPeriod {
  breakfast, // 9am check
  lunch, // 12:30pm check
  dinner; // 7pm check

  String get displayName {
    switch (this) {
      case MealPeriod.breakfast:
        return 'breakfast';
      case MealPeriod.lunch:
        return 'lunch';
      case MealPeriod.dinner:
        return 'dinner';
    }
  }

  /// Time window for each meal (start hour, end hour)
  (int, int) get window {
    switch (this) {
      case MealPeriod.breakfast:
        return (6, 10); // 6am-10am
      case MealPeriod.lunch:
        return (11, 14); // 11am-2pm
      case MealPeriod.dinner:
        return (18, 21); // 6pm-9pm
    }
  }

  /// Check-in time (hour of day)
  int get checkInHour {
    switch (this) {
      case MealPeriod.breakfast:
        return 9; // 9am
      case MealPeriod.lunch:
        return 12; // 12:30pm (handle minutes separately)
      case MealPeriod.dinner:
        return 19; // 7pm
    }
  }

  /// Check-in minute
  int get checkInMinute {
    switch (this) {
      case MealPeriod.breakfast:
        return 0; // 9:00am
      case MealPeriod.lunch:
        return 30; // 12:30pm
      case MealPeriod.dinner:
        return 0; // 7:00pm
    }
  }
}
