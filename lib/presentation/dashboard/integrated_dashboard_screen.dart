import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../providers/auth_provider.dart';
import '../providers/integrated_dashboard_provider.dart';
import 'widgets/next_action_card.dart';
import 'widgets/today_meals_card.dart';
import 'widgets/today_workouts_card.dart';

/// Integrated dashboard showing real data from meals and workouts
class IntegratedDashboardScreen extends ConsumerWidget {
  const IntegratedDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final dashboardState = ref.watch(integratedDashboardProvider);

    final user = authState.value?.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Health Companion',
          style: AppTextStyles.h6.copyWith(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(integratedDashboardProvider.notifier).refresh(),
          ),
        ],
      ),
      body: dashboardState.when(
        data: (data) => RefreshIndicator(
          onRefresh: () =>
              ref.read(integratedDashboardProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  _getGreeting(user?.displayName),
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 8),
                Text(
                  _getMotivationalMessage(data),
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                // Next action (AI suggestion)
                NextActionCard(
                  suggestion: data.nextActionSuggestion,
                  onTap: () => _handleNextAction(context, data),
                ),

                const SizedBox(height: 24),

                // Today's meals
                TodayMealsCard(
                  meals: data.todaysMeals,
                  avgHealthScore: data.avgHealthScore,
                  mealsSkipped: data.mealsSkipped,
                  onTap: () => context.push('/nutrition'),
                ),

                const SizedBox(height: 16),

                // Today's workouts
                TodayWorkoutsCard(
                  workouts: data.todaysWorkouts,
                  minutesExercised: data.minutesExercised,
                  onTap: () => context.push('/workout'),
                ),

                const SizedBox(height: 24),

                // Weekly summary
                _buildWeeklySummary(data),

                const SizedBox(height: 24),

                // Quick stats
                _buildQuickStats(data),
              ],
            ),
          ),
        ),
        loading: () => const LoadingIndicator(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load dashboard',
                style: AppTextStyles.body1,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    ref.read(integratedDashboardProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklySummary(IntegratedDashboardData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week',
              style: AppTextStyles.body1Medium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildWeekStat(
                    icon: Icons.restaurant,
                    label: 'Meal Skip Rate',
                    value: '${(data.weeklyMealSkipRate * 100).toInt()}%',
                    color: data.weeklyMealSkipRate < 0.3
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildWeekStat(
                    icon: Icons.fitness_center,
                    label: 'Workouts',
                    value: data.weeklyWorkoutCount.toString(),
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h6.copyWith(color: color),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(IntegratedDashboardData data) {
    return Card(
      color: AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickStat(
              icon: Icons.local_fire_department,
              value: data.mealsLogged.toString(),
              label: 'Meals',
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.divider,
            ),
            _buildQuickStat(
              icon: Icons.trending_up,
              value: data.workoutsCompleted.toString(),
              label: 'Workouts',
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.divider,
            ),
            _buildQuickStat(
              icon: Icons.timer,
              value: '${data.minutesExercised}m',
              label: 'Active',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body1Medium,
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getGreeting(String? name) {
    final hour = DateTime.now().hour;
    String timeGreeting;

    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }

    return name != null ? '$timeGreeting, $name!' : '$timeGreeting!';
  }

  String _getMotivationalMessage(IntegratedDashboardData data) {
    if (data.mealsLogged >= 3 && data.workoutsCompleted >= 1) {
      return 'You\'re crushing it today! 🔥';
    } else if (data.mealsLogged >= 2) {
      return 'Great job staying consistent with meals!';
    } else if (data.mealsSkipped > 1) {
      return 'Remember to eat regularly today';
    } else if (data.workoutsCompleted == 0 && DateTime.now().hour > 14) {
      return 'Still time for a quick workout!';
    } else {
      return 'Let\'s make today count!';
    }
  }

  void _handleNextAction(
    BuildContext context,
    IntegratedDashboardData data,
  ) {
    final suggestion = data.nextActionSuggestion;

    if (suggestion.contains('breakfast') ||
        suggestion.contains('lunch') ||
        suggestion.contains('dinner') ||
        suggestion.contains('meal')) {
      context.push('/nutrition');
    } else if (suggestion.contains('workout')) {
      context.push('/workout');
    } else {
      // Default to chat for guidance
      context.push('/chat');
    }
  }
}
