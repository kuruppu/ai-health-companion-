class AppRoutes {
  AppRoutes._();

  // Splash
  static const String splash = '/';
  static const String splashName = 'splash';

  // Onboarding
  static const String onboarding = '/onboarding';
  static const String onboardingName = 'onboarding';

  // Auth
  static const String login = '/login';
  static const String loginName = 'login';
  static const String register = '/register';
  static const String registerName = 'register';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordName = 'forgot-password';

  // Main App
  static const String home = '/home';
  static const String homeName = 'home';

  // Dashboard
  static const String dashboard = '/dashboard';
  static const String dashboardName = 'dashboard';

  // Chat
  static const String chat = '/chat';
  static const String chatName = 'chat';

  // Nutrition
  static const String nutrition = '/nutrition';
  static const String nutritionName = 'nutrition';
  static const String mealDetailsSuffix = 'meal/:mealId';
  static const String mealDetailsName = 'meal-details';
  static const String addMealSuffix = 'add-meal';
  static const String addMealName = 'add-meal';

  // Helper methods for meal routes
  static String mealDetails(String mealId) => '/nutrition/meal/$mealId';
  static String addMeal() => '/nutrition/add-meal';

  // Workout
  static const String workout = '/workout';
  static const String workoutName = 'workout';
  static const String workoutDetailsSuffix = 'workout/:workoutId';
  static const String workoutDetailsName = 'workout-details';
  static const String startWorkoutSuffix = 'start/:workoutId';
  static const String startWorkoutName = 'start-workout';

  // Helper methods for workout routes
  static String workoutDetails(String workoutId) => '/workout/workout/$workoutId';
  static String startWorkout(String workoutId) => '/workout/start/$workoutId';

  // Profile
  static const String profile = '/profile';
  static const String profileName = 'profile';
  static const String editProfileSuffix = 'edit';
  static const String editProfileName = 'edit-profile';
  static const String settingsSuffix = 'settings';
  static const String settingsName = 'settings';

  // Helper methods for profile routes
  static String editProfile() => '/profile/edit';
  static String settings() => '/profile/settings';

  // Progress
  static const String progress = '/progress';
  static const String progressName = 'progress';

  // Goals
  static const String goals = '/goals';
  static const String goalsName = 'goals';
  static const String goalDetailsSuffix = 'goal/:goalId';
  static const String goalDetailsName = 'goal-details';

  // Helper methods for goal routes
  static String goalDetails(String goalId) => '/goals/goal/$goalId';
}
