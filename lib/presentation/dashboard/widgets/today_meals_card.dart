import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/meal.dart';

/// Card showing today's meals with real data
class TodayMealsCard extends StatelessWidget {

  const TodayMealsCard({
    required this.meals,
    required this.avgHealthScore,
    required this.mealsSkipped,
    required this.onTap,
    super.key,
  });
  final List<Meal> meals;
  final double avgHealthScore;
  final int mealsSkipped;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today\'s Meals',
                          style: AppTextStyles.body1Medium,
                        ),
                        Text(
                          meals.isEmpty
                              ? 'No meals logged yet'
                              : '${meals.length} meal${meals.length == 1 ? '' : 's'} logged',
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

              if (meals.isNotEmpty) ...[
                const SizedBox(height: 16),

                // Stats row
                Row(
                  children: [
                    // Health score
                    Expanded(
                      child: _buildStat(
                        icon: Icons.favorite,
                        label: 'Health Score',
                        value: avgHealthScore.toStringAsFixed(1),
                        color: _getHealthScoreColor(avgHealthScore),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Latest meal
                    Expanded(
                      child: _buildStat(
                        icon: Icons.schedule,
                        label: 'Latest',
                        value: _getTimeAgo(meals.last.eatenAt),
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],

              // Warning for skipped meals
              if (mealsSkipped > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You skipped $mealsSkipped meal${mealsSkipped == 1 ? '' : 's'} today',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Empty state encouragement
              if (meals.isEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Tap to log your first meal',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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

  Color _getHealthScoreColor(double score) {
    if (score >= 4.0) return AppColors.success;
    if (score >= 3.0) return AppColors.warning;
    return AppColors.error;
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
