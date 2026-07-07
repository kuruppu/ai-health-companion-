import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class WeeklySummaryCard extends StatelessWidget {
  final int workoutsCompleted;
  final double avgEnergy;
  final int daysLogged;
  final int currentStreak;

  const WeeklySummaryCard({
    required this.workoutsCompleted,
    required this.avgEnergy,
    required this.daysLogged,
    required this.currentStreak,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: AppColors.success,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Week',
                        style: AppTextStyles.body1Medium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getWeeklySummaryMessage(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.fitness_center,
                    label: 'Workouts',
                    value: workoutsCompleted.toString(),
                    color: AppColors.workout,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatItem(
                    icon: Icons.bolt,
                    label: 'Avg Energy',
                    value: avgEnergy > 0 ? avgEnergy.toStringAsFixed(1) : 'N/A',
                    color: AppColors.energy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.calendar_today,
                    label: 'Days Logged',
                    value: daysLogged.toString(),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatItem(
                    icon: Icons.local_fire_department,
                    label: 'Streak',
                    value: currentStreak.toString(),
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getWeeklySummaryMessage() {
    if (workoutsCompleted == 0 && daysLogged == 0) {
      return 'Let\'s get started!';
    } else if (workoutsCompleted >= 3) {
      return 'You\'re crushing it! 🔥';
    } else if (daysLogged >= 5) {
      return 'Great consistency! 💪';
    } else {
      return 'Keep building momentum!';
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h5.copyWith(color: color),
          ),
          const SizedBox(height: 4),
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
}
