import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/workout.dart';
import 'exercise_list_card.dart';
import 'workout_in_progress_sheet.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final bool isRecommended;

  const WorkoutCard({
    required this.workout,
    this.isRecommended = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isRecommended
                  ? LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isRecommended ? null : AppColors.primary.withOpacity(0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (workout.isAiGenerated) ...[
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: isRecommended ? Colors.white : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        workout.name,
                        style: AppTextStyles.h6.copyWith(
                          color: isRecommended ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _DifficultyBadge(
                      difficulty: workout.difficulty,
                      isLight: isRecommended,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  workout.description,
                  style: AppTextStyles.body2.copyWith(
                    color: isRecommended
                        ? Colors.white.withOpacity(0.9)
                        : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.timer,
                      label: '${workout.durationMinutes} min',
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.fitness_center,
                      label: '${workout.exercises.length} exercises',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Target muscles
                if (workout.targetMuscles.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: workout.targetMuscles.take(4).map((muscle) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          muscle,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _startWorkout(context),
                        icon: const Icon(Icons.play_arrow, size: 20),
                        label: const Text('Start Workout'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showExerciseList(context),
                      icon: const Icon(Icons.list),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startWorkout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkoutInProgressSheet(workout: workout),
    );
  }

  void _showExerciseList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseListCard(workout: workout),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final WorkoutDifficulty difficulty;
  final bool isLight;

  const _DifficultyBadge({
    required this.difficulty,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getDifficultyColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLight ? Colors.white.withOpacity(0.2) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficulty.displayName,
        style: AppTextStyles.caption.copyWith(
          color: isLight ? Colors.white : color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (difficulty) {
      case WorkoutDifficulty.beginner:
        return AppColors.success;
      case WorkoutDifficulty.intermediate:
        return AppColors.warning;
      case WorkoutDifficulty.advanced:
        return AppColors.error;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
