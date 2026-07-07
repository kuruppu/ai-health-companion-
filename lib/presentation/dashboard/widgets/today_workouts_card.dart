import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/workout_log.dart';

/// Card showing today's workouts with real data
class TodayWorkoutsCard extends StatelessWidget {
  final List<WorkoutLog> workouts;
  final int minutesExercised;
  final VoidCallback onTap;

  const TodayWorkoutsCard({
    required this.workouts,
    required this.minutesExercised,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Workouts',
                          style: AppTextStyles.body1Medium,
                        ),
                        Text(
                          workouts.isEmpty
                              ? 'No workouts yet'
                              : '${workouts.length} workout${workouts.length == 1 ? '' : 's'} completed',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),

              if (workouts.isNotEmpty) ...[
                const SizedBox(height: 16),

                // Stats row
                Row(
                  children: [
                    // Minutes exercised
                    Expanded(
                      child: _buildStat(
                        icon: Icons.timer,
                        label: 'Minutes',
                        value: minutesExercised.toString(),
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Completion rate
                    Expanded(
                      child: _buildStat(
                        icon: Icons.check_circle,
                        label: 'Completion',
                        value: '${_getAvgCompletion()}%',
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Latest workout
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          workouts.last.workoutName,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _getTimeAgo(workouts.last.completedAt),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Empty state encouragement
              if (workouts.isEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Tap to start your first workout',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat({
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.body1Medium.copyWith(color: color),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  int _getAvgCompletion() {
    if (workouts.isEmpty) return 0;

    final totalCompletion = workouts
        .map((w) => w.completionPercentage)
        .reduce((a, b) => a + b);

    return (totalCompletion / workouts.length).round();
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
