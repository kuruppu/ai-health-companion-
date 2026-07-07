import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/chat/chat_screen.dart';
import '../../presentation/dashboard/dashboard_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/nutrition/nutrition_screen.dart';
import '../../presentation/onboarding/emotional_goal_screen.dart';
import '../../presentation/onboarding/get_started_screen.dart';
import '../../presentation/onboarding/user_info_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/splash/splash_screen.dart';
import '../../presentation/workout/workout_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/get-started',
        name: 'get-started',
        builder: (context, state) => const GetStartedScreen(),
      ),
      GoRoute(
        path: '/emotional-goal',
        name: 'emotional-goal',
        builder: (context, state) => const EmotionalGoalScreen(),
      ),
      GoRoute(
        path: '/user-info',
        name: 'user-info',
        builder: (context, state) {
          final emotionalGoal = state.extra as String;
          return UserInfoScreen(emotionalGoal: emotionalGoal);
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/nutrition',
        name: 'nutrition',
        builder: (context, state) => const NutritionScreen(),
      ),
      GoRoute(
        path: '/workout',
        name: 'workout',
        builder: (context, state) => const WorkoutScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
}
