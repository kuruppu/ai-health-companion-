import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  /// Format DateTime to readable string (e.g., "Jan 15, 2024")
  static String formatDate(DateTime dateTime) => DateFormat('MMM d, y').format(dateTime);

  /// Format DateTime to time string (e.g., "2:30 PM")
  static String formatTime(DateTime dateTime) => DateFormat('h:mm a').format(dateTime);

  /// Format DateTime to full string (e.g., "Jan 15, 2024 at 2:30 PM")
  static String formatDateTime(DateTime dateTime) => DateFormat('MMM d, y \'at\' h:mm a').format(dateTime);

  /// Format DateTime to ISO 8601 string
  static String formatIso8601(DateTime dateTime) => dateTime.toIso8601String();

  /// Parse ISO 8601 string to DateTime
  static DateTime parseIso8601(String dateTimeString) => DateTime.parse(dateTimeString);

  /// Get time ago string (e.g., "2 hours ago", "3 days ago")
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  /// Get start of day
  static DateTime startOfDay(DateTime dateTime) => DateTime(dateTime.year, dateTime.month, dateTime.day);

  /// Get end of day
  static DateTime endOfDay(DateTime dateTime) => DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      23,
      59,
      59,
      999,
    );

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime dateTime) {
    final daysFromMonday = dateTime.weekday - 1;
    return startOfDay(dateTime.subtract(Duration(days: daysFromMonday)));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime dateTime) {
    final daysToSunday = 7 - dateTime.weekday;
    return endOfDay(dateTime.add(Duration(days: daysToSunday)));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime dateTime) => DateTime(dateTime.year, dateTime.month);

  /// Get end of month
  static DateTime endOfMonth(DateTime dateTime) => DateTime(dateTime.year, dateTime.month + 1, 0, 23, 59, 59, 999);

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) => date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;

  /// Get days difference between two dates
  static int daysBetween(DateTime from, DateTime to) {
    final fromDay = startOfDay(from);
    final toDay = startOfDay(to);
    return toDay.difference(fromDay).inDays;
  }

  /// Format duration to readable string (e.g., "1h 30m", "45m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Format short duration (e.g., "1:30" for 1 hour 30 minutes)
  static String formatShortDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
