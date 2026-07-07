class ApiEndpoints {
  ApiEndpoints._();

  // Claude AI
  static const String claudeMessages = '/v1/messages';
  static const String claudeModels = '/v1/models';

  // Firebase Firestore Collections
  static const String usersCollection = 'users';
  static const String userProfilesCollection = 'user_profiles';
  static const String chatMessagesCollection = 'chat_messages';
  static const String mealsCollection = 'meals';
  static const String workoutsCollection = 'workouts';
  static const String progressLogsCollection = 'progress_logs';
  static const String goalsCollection = 'goals';
  static const String remindersCollection = 'reminders';
  static const String achievementsCollection = 'achievements';
  static const String feedbackCollection = 'feedback';

  // Firebase Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String mealImagesPath = 'meal_images';
  static const String workoutImagesPath = 'workout_images';
  static const String progressImagesPath = 'progress_images';
}
