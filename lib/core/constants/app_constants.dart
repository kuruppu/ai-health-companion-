class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'AI Health Companion';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // API
  static const String claudeApiBaseUrl = 'https://api.anthropic.com';
  static const String claudeApiVersion = '2023-06-01';
  static const String claudeModel = 'claude-3-sonnet-20240229';

  // Database
  static const String databaseName = 'ai_health_companion.db';
  static const int databaseVersion = 1;

  // Hive Boxes
  static const String authBoxName = 'auth_box';
  static const String userBoxName = 'user_box';
  static const String chatBoxName = 'chat_box';
  static const String nutritionBoxName = 'nutrition_box';
  static const String workoutBoxName = 'workout_box';
  static const String settingsBoxName = 'settings_box';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const double imageQuality = 0.8;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;

  // Voice
  static const Duration maxRecordingDuration = Duration(minutes: 5);
  static const Duration minRecordingDuration = Duration(seconds: 1);

  // Notifications
  static const String notificationChannelId = 'ai_health_companion_channel';
  static const String notificationChannelName = 'AI Health Companion';
  static const String notificationChannelDescription =
      'Notifications for reminders and updates';

  // Reminders
  static const Duration defaultWaterReminderInterval = Duration(hours: 2);
  static const Duration defaultStandReminderInterval = Duration(hours: 1);
  static const Duration defaultMealReminderInterval = Duration(hours: 4);

  // Nutrition
  static const double defaultDailyCaloricIntake = 1500;
  static const double defaultProteinPercentage = 0.30;
  static const double defaultCarbsPercentage = 0.40;
  static const double defaultFatsPercentage = 0.30;
  static const double defaultWaterIntakeMl = 2000;

  // Workout
  static const int defaultWorkoutDurationMinutes = 30;
  static const int minWorkoutDurationMinutes = 10;
  static const int maxWorkoutDurationMinutes = 90;
  static const int defaultWorkoutsPerWeek = 3;

  // Goals
  static const double defaultWeightLossRateKgPerWeek = 0.5;
  static const double minWeightLossRateKgPerWeek = 0.25;
  static const double maxWeightLossRateKgPerWeek = 1;

  // UI
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration splashScreenDuration = Duration(seconds: 2);
  static const Duration snackBarDuration = Duration(seconds: 3);

  // Chat
  static const int maxChatHistoryMessages = 50;
  static const int maxMessageLength = 2000;

  // Error Messages
  static const String networkErrorMessage =
      'Please check your internet connection and try again.';
  static const String serverErrorMessage =
      'Something went wrong. Please try again later.';
  static const String unknownErrorMessage = 'An unexpected error occurred.';
  static const String authErrorMessage =
      'Authentication failed. Please login again.';
  static const String permissionDeniedMessage = 'Permission denied.';
}
