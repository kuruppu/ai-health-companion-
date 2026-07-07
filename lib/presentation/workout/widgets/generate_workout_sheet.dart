import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/workout.dart';
import '../../providers/workout_provider.dart';
import 'workout_in_progress_sheet.dart';

class GenerateWorkoutSheet extends ConsumerStatefulWidget {
  const GenerateWorkoutSheet({super.key});

  @override
  ConsumerState<GenerateWorkoutSheet> createState() =>
      _GenerateWorkoutSheetState();
}

class _GenerateWorkoutSheetState extends ConsumerState<GenerateWorkoutSheet> {
  String _goalType = 'general_fitness';
  int _energyLevel = 3;
  int _durationMinutes = 30;
  WorkoutDifficulty _difficulty = WorkoutDifficulty.beginner;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Generate Workout',
                  style: AppTextStyles.h5,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell me about your workout preferences',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Goal type
                Text(
                  'What\'s your goal?',
                  style: AppTextStyles.body1Medium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _GoalChip(
                      label: 'General Fitness',
                      value: 'general_fitness',
                      selected: _goalType == 'general_fitness',
                      onTap: () => setState(() => _goalType = 'general_fitness'),
                    ),
                    _GoalChip(
                      label: 'Weight Loss',
                      value: 'weight_loss',
                      selected: _goalType == 'weight_loss',
                      onTap: () => setState(() => _goalType = 'weight_loss'),
                    ),
                    _GoalChip(
                      label: 'Muscle Gain',
                      value: 'muscle_gain',
                      selected: _goalType == 'muscle_gain',
                      onTap: () => setState(() => _goalType = 'muscle_gain'),
                    ),
                    _GoalChip(
                      label: 'Endurance',
                      value: 'endurance',
                      selected: _goalType == 'endurance',
                      onTap: () => setState(() => _goalType = 'endurance'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Energy level
                Text(
                  'How\'s your energy today?',
                  style: AppTextStyles.body1Medium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    final level = index + 1;
                    return GestureDetector(
                      onTap: () => setState(() => _energyLevel = level),
                      child: Column(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _energyLevel >= level
                                  ? AppColors.primary
                                  : AppColors.surfaceLight,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                level.toString(),
                                style: AppTextStyles.h6.copyWith(
                                  color: _energyLevel >= level
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (level == 1 || level == 5)
                            Text(
                              level == 1 ? 'Low' : 'High',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Duration
                Text(
                  'How long do you have?',
                  style: AppTextStyles.body1Medium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '$_durationMinutes min',
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _durationMinutes.toDouble(),
                        min: 10,
                        max: 60,
                        divisions: 10,
                        label: '$_durationMinutes min',
                        onChanged: (value) {
                          setState(() {
                            _durationMinutes = value.toInt();
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Difficulty
                Text(
                  'Difficulty level',
                  style: AppTextStyles.body1Medium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DifficultyOption(
                        difficulty: WorkoutDifficulty.beginner,
                        selected: _difficulty == WorkoutDifficulty.beginner,
                        onTap: () =>
                            setState(() => _difficulty = WorkoutDifficulty.beginner),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DifficultyOption(
                        difficulty: WorkoutDifficulty.intermediate,
                        selected: _difficulty == WorkoutDifficulty.intermediate,
                        onTap: () => setState(
                            () => _difficulty = WorkoutDifficulty.intermediate),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DifficultyOption(
                        difficulty: WorkoutDifficulty.advanced,
                        selected: _difficulty == WorkoutDifficulty.advanced,
                        onTap: () =>
                            setState(() => _difficulty = WorkoutDifficulty.advanced),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Generate button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateWorkout,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_isGenerating
                        ? 'Generating...'
                        : 'Generate My Workout'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateWorkout() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final workout = await ref.read(workoutGeneratorProvider.notifier).generateWorkout(
            goalType: _goalType,
            energyLevel: _energyLevel,
            durationMinutes: _durationMinutes,
            difficulty: _difficulty,
          );

      if (mounted) {
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout generated successfully!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );

        // Offer to start immediately
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showStartWorkoutDialog(workout);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate workout: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showStartWorkoutDialog(Workout workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workout Ready!'),
        content: Text('Would you like to start "${workout.name}" now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                isDismissible: false,
                backgroundColor: Colors.transparent,
                builder: (context) => WorkoutInProgressSheet(workout: workout),
              );
            },
            child: const Text('Start Now'),
          ),
        ],
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _GoalChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  final WorkoutDifficulty difficulty;
  final bool selected;
  final VoidCallback onTap;

  const _DifficultyOption({
    required this.difficulty,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            difficulty.displayName,
            style: AppTextStyles.body2.copyWith(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
