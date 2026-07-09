import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import 'widgets/energy_rating_card.dart';
import 'widgets/goal_progress_card.dart';
import 'widgets/quick_actions_card.dart';
import 'widgets/weekly_summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Health Companion',
          style: AppTextStyles.h6.copyWith(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
          ),
        ],
      ),
      body: authState.when(
        data: (authStatus) => dashboardState.when(
            data: (summary) => RefreshIndicator(
              onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text(
                      _getGreeting(),
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How are you feeling today?',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Energy Rating Card
                    EnergyRatingCard(
                      currentLevel: summary.todayEnergyLevel,
                      message: summary.todayEnergyMessage,
                      onRatingChanged: (level) {
                        ref
                            .read(dashboardProvider.notifier)
                            .logEnergyLevel(level);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Goal Progress Card
                    if (summary.emotionalGoal != null)
                      GoalProgressCard(
                        goal: summary.emotionalGoal!,
                        progress: summary.goalProgress,
                        message: summary.goalProgressMessage,
                      ),
                    const SizedBox(height: 16),

                    // Weekly Summary Card
                    WeeklySummaryCard(
                      workoutsCompleted: summary.workoutsThisWeek,
                      avgEnergy: summary.avgEnergyThisWeek,
                      daysLogged: summary.daysLoggedThisWeek,
                      currentStreak: summary.currentStreak,
                    ),
                    const SizedBox(height: 16),

                    // Quick Actions
                    const QuickActionsCard(),
                    const SizedBox(height: 24),
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
                    error.toString(),
                    style: AppTextStyles.body1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(dashboardProvider.notifier).refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        loading: () => const LoadingIndicator(),
        error: (error, stack) => Center(child: Text(error.toString())),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }
}
