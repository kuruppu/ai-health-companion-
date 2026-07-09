import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/workout.dart';
import '../../providers/workout_provider.dart';
import 'workout_complete_sheet.dart';

class WorkoutInProgressSheet extends ConsumerStatefulWidget {

  const WorkoutInProgressSheet({
    required this.workout,
    super.key,
  });
  final Workout workout;

  @override
  ConsumerState<WorkoutInProgressSheet> createState() =>
      _WorkoutInProgressSheetState();
}

class _WorkoutInProgressSheetState
    extends ConsumerState<WorkoutInProgressSheet> {
  int _currentExerciseIndex = 0;
  bool _isResting = false;
  int _remainingRestSeconds = 0;
  Timer? _restTimer;
  DateTime? _workoutStartTime;

  @override
  void initState() {
    super.initState();
    _workoutStartTime = DateTime.now();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  bool get _isLastExercise =>
      _currentExerciseIndex >= widget.workout.exercises.length - 1;

  double get _progress =>
      (_currentExerciseIndex + 1) / widget.workout.exercises.length;

  @override
  Widget build(BuildContext context) {
    final currentExercise = widget.workout.exercises[_currentExerciseIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final shouldPop = await _showQuitConfirmation();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceLight,
                border: Border(
                  bottom: BorderSide(color: AppColors.divider),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: _showQuitConfirmation,
                          icon: const Icon(Icons.close),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                widget.workout.name,
                                style: AppTextStyles.body1Medium,
                              ),
                              Text(
                                'Exercise ${_currentExerciseIndex + 1} of ${widget.workout.exercises.length}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Pause/resume (optional feature)
                          },
                          icon: const Icon(Icons.pause_circle_outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: _isResting
                  ? _buildRestScreen()
                  : _buildExerciseScreen(currentExercise),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseScreen(dynamic exercise) => SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name
          Text(
            exercise.name,
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 8),

          // Work info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              exercise.workString,
              style: AppTextStyles.body1Medium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Description
          const Text(
            'How to Perform',
            style: AppTextStyles.body1Medium,
          ),
          const SizedBox(height: 8),
          Text(
            exercise.description,
            style: AppTextStyles.body1,
          ),

          // Form tips
          if (exercise.formTips.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Form Tips',
              style: AppTextStyles.body1Medium,
            ),
            const SizedBox(height: 12),
            ...exercise.formTips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 20,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tip,
                          style: AppTextStyles.body1,
                        ),
                      ),
                    ],
                  ),
                ),),
          ],

          const SizedBox(height: 32),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _completeExercise,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isLastExercise ? 'Finish Workout' : 'Next Exercise',
                style: AppTextStyles.body1Medium.copyWith(color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Skip button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _skipExercise,
              child: const Text('Skip Exercise'),
            ),
          ),
        ],
      ),
    );

  Widget _buildRestScreen() => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _remainingRestSeconds.toString(),
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.secondary,
                    fontSize: 64,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Rest Time',
              style: AppTextStyles.h5,
            ),
            const SizedBox(height: 12),
            Text(
              'Take a breather before the next exercise',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _skipRest,
                child: const Text('Skip Rest'),
              ),
            ),
          ],
        ),
      ),
    );

  void _completeExercise() {
    if (_isLastExercise) {
      _finishWorkout();
    } else {
      final currentExercise = widget.workout.exercises[_currentExerciseIndex];
      setState(() {
        _isResting = true;
        _remainingRestSeconds = currentExercise.restSeconds;
      });

      _startRestTimer();
    }
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingRestSeconds--;
      });

      if (_remainingRestSeconds <= 0) {
        timer.cancel();
        setState(() {
          _isResting = false;
          _currentExerciseIndex++;
        });
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _currentExerciseIndex++;
    });
  }

  void _skipExercise() {
    if (_isLastExercise) {
      _finishWorkout();
    } else {
      setState(() {
        _currentExerciseIndex++;
      });
    }
  }

  Future<void> _finishWorkout() async {
    final completedAt = DateTime.now();
    final startedAt = _workoutStartTime ?? completedAt;

    try {
      final log = await ref.read(workoutLoggerProvider.notifier).logWorkout(
            workoutId: widget.workout.workoutId,
            workoutName: widget.workout.name,
            startedAt: startedAt,
            completedAt: completedAt,
            exercisesCompleted: _currentExerciseIndex + 1,
            totalExercises: widget.workout.exercises.length,
          );

      if (mounted) {
        Navigator.pop(context);

        unawaited(
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isDismissible: false,
            builder: (context) => WorkoutCompleteSheet(log: log),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log workout: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<bool> _showQuitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Workout?'),
        content: const Text(
          'Are you sure you want to quit? Your progress will not be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Quit'),
          ),
        ],
      ),
    );

    if ((result ?? false) && mounted) {
      Navigator.pop(context);
    }

    return result ?? false;
  }
}
