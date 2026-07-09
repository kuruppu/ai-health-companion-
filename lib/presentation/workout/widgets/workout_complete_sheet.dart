import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/workout_log.dart';

class WorkoutCompleteSheet extends StatefulWidget {

  const WorkoutCompleteSheet({
    required this.log,
    super.key,
  });
  final WorkoutLog log;

  @override
  State<WorkoutCompleteSheet> createState() => _WorkoutCompleteSheetState();
}

class _WorkoutCompleteSheetState extends State<WorkoutCompleteSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int? _energyRating;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success animation
            ScaleTransition(
              scale: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Workout Complete!',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 8),
            Text(
              'Great job finishing "${widget.log.workoutName}"',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: Icons.timer,
                  label: 'Duration',
                  value: '${widget.log.durationMinutes} min',
                ),
                _StatItem(
                  icon: Icons.fitness_center,
                  label: 'Exercises',
                  value:
                      '${widget.log.exercisesCompleted}/${widget.log.totalExercises}',
                ),
                _StatItem(
                  icon: Icons.percent,
                  label: 'Complete',
                  value: '${widget.log.completionPercentage.toInt()}%',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Energy rating
            const Text(
              'How do you feel?',
              style: AppTextStyles.body1Medium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final level = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _energyRating = level),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _energyRating == level
                          ? AppColors.primary
                          : AppColors.surfaceLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        level.toString(),
                        style: AppTextStyles.body1Medium.copyWith(
                          color: _energyRating == level
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Optional notes
            TextField(
              controller: _notesController,
              maxLines: 2,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Add notes (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),

            const SizedBox(height: 24),

            // Done button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
}

class _StatItem extends StatelessWidget {

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
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
