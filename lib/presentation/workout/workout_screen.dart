import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../providers/workout_provider.dart';
import 'widgets/generate_workout_sheet.dart';
import 'widgets/workout_card.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    final workoutHistoryState = ref.watch(workoutHistoryProvider);
    final recommendedWorkoutsState = ref.watch(recommendedWorkoutsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workouts',
              style: AppTextStyles.body1Medium,
            ),
            Text(
              'Personalized for you',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Show workout logs history
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(workoutHistoryProvider.notifier).refresh();
              ref.read(recommendedWorkoutsProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: workoutHistoryState.when(
        data: (workouts) {
          if (workouts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(workoutHistoryProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Recommended workouts section
                recommendedWorkoutsState.when(
                  data: (recommended) {
                    if (recommended.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.stars,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Recommended for You',
                                style: AppTextStyles.body1Medium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...recommended.map((workout) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: WorkoutCard(
                                  workout: workout,
                                  isRecommended: true,
                                ),
                              ),),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // All workouts section
                const Text(
                  'Your Workouts',
                  style: AppTextStyles.body1Medium,
                ),
                const SizedBox(height: 12),
                ...workouts.map((workout) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: WorkoutCard(workout: workout),
                    ),),
              ],
            ),
          );
        },
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
                    ref.read(workoutHistoryProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGenerateWorkoutSheet(context),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Generate Workout'),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ready to Start Your Fitness Journey?',
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Let me create a personalized workout plan based on your goals, energy level, and available time!',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showGenerateWorkoutSheet(context),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Your First Workout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  _buildFeatureItem(
                    icon: Icons.psychology,
                    title: 'AI-Powered',
                    description: 'Workouts tailored to your needs',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    icon: Icons.timer,
                    title: 'Flexible Duration',
                    description: 'From 10 to 60 minutes',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    icon: Icons.favorite,
                    title: 'Energy-Aware',
                    description: 'Adapts to how you feel today',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) => Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body1Medium,
              ),
              Text(
                description,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );

  void _showGenerateWorkoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GenerateWorkoutSheet(),
    );
  }
}
