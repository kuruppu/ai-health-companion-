import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/chat/integrated_chat_screen.dart';
import '../../presentation/dashboard/integrated_dashboard_screen.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) => GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboardingName,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPasswordName,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main App (Bottom Navigation)
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (context, state) => const HomeScreen(),
      ),

      // Dashboard Tab
      GoRoute(
        path: AppRoutes.dashboard,
        name: AppRoutes.dashboardName,
        builder: (context, state) => const IntegratedDashboardScreen(),
      ),

      // Chat Tab
      GoRoute(
        path: AppRoutes.chat,
        name: AppRoutes.chatName,
        builder: (context, state) => const IntegratedChatScreen(),
      ),

      // Nutrition Tab
      GoRoute(
        path: AppRoutes.nutrition,
        name: AppRoutes.nutritionName,
        builder: (context, state) => const NutritionScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.mealDetailsSuffix,
            name: AppRoutes.mealDetailsName,
            builder: (context, state) {
              final mealId = state.pathParameters['mealId']!;
              return MealDetailsScreen(mealId: mealId);
            },
          ),
          GoRoute(
            path: AppRoutes.addMealSuffix,
            name: AppRoutes.addMealName,
            builder: (context, state) => const AddMealScreen(),
          ),
        ],
      ),

      // Workout Tab
      GoRoute(
        path: AppRoutes.workout,
        name: AppRoutes.workoutName,
        builder: (context, state) => const WorkoutScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.workoutDetailsSuffix,
            name: AppRoutes.workoutDetailsName,
            builder: (context, state) {
              final workoutId = state.pathParameters['workoutId']!;
              return WorkoutDetailsScreen(workoutId: workoutId);
            },
          ),
          GoRoute(
            path: AppRoutes.startWorkoutSuffix,
            name: AppRoutes.startWorkoutName,
            builder: (context, state) {
              final workoutId = state.pathParameters['workoutId']!;
              return StartWorkoutScreen(workoutId: workoutId);
            },
          ),
        ],
      ),

      // Profile Tab
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profileName,
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.editProfileSuffix,
            name: AppRoutes.editProfileName,
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsSuffix,
            name: AppRoutes.settingsName,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // Progress
      GoRoute(
        path: AppRoutes.progress,
        name: AppRoutes.progressName,
        builder: (context, state) => const ProgressScreen(),
      ),

      // Goals
      GoRoute(
        path: AppRoutes.goals,
        name: AppRoutes.goalsName,
        builder: (context, state) => const GoalsScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.goalDetailsSuffix,
            name: AppRoutes.goalDetailsName,
            builder: (context, state) {
              final goalId = state.pathParameters['goalId']!;
              return GoalDetailsScreen(goalId: goalId);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );

// Placeholder screens - will be implemented in respective milestones
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Onboarding')),
    );
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Login')),
    );
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Register')),
    );
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Forgot Password')),
    );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Home')),
    );
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Dashboard')),
    );
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Chat')),
    );
}

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Nutrition')),
    );
}

class MealDetailsScreen extends StatelessWidget {

  const MealDetailsScreen({required this.mealId, super.key});
  final String mealId;

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Center(child: Text('Meal Details: $mealId')),
    );
}

class AddMealScreen extends StatelessWidget {
  const AddMealScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Add Meal')),
    );
}

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Workout')),
    );
}

class WorkoutDetailsScreen extends StatelessWidget {

  const WorkoutDetailsScreen({required this.workoutId, super.key});
  final String workoutId;

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Center(child: Text('Workout Details: $workoutId')),
    );
}

class StartWorkoutScreen extends StatelessWidget {

  const StartWorkoutScreen({required this.workoutId, super.key});
  final String workoutId;

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Center(child: Text('Start Workout: $workoutId')),
    );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Profile')),
    );
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Edit Profile')),
    );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Settings')),
    );
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Progress')),
    );
}

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text('Goals')),
    );
}

class GoalDetailsScreen extends StatelessWidget {

  const GoalDetailsScreen({required this.goalId, super.key});
  final String goalId;

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Center(child: Text('Goal Details: $goalId')),
    );
}

class ErrorScreen extends StatelessWidget {

  const ErrorScreen({this.error, super.key});
  final Exception? error;

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Center(
        child: Text('Error: ${error?.toString() ?? "Unknown error"}'),
      ),
    );
}
