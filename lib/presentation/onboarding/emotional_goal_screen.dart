import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class EmotionalGoalScreen extends ConsumerStatefulWidget {
  const EmotionalGoalScreen({super.key});

  @override
  ConsumerState<EmotionalGoalScreen> createState() =>
      _EmotionalGoalScreenState();
}

class _EmotionalGoalScreenState extends ConsumerState<EmotionalGoalScreen> {
  String? _selectedGoal;

  final List<EmotionalGoalOption> _goals = [
    EmotionalGoalOption(
      icon: '👶',
      title: 'Play with my baby without getting tired',
      description: 'Build stamina for active parenting',
    ),
    EmotionalGoalOption(
      icon: '👗',
      title: 'Fit into my pre-baby clothes',
      description: 'Feel confident in your favorite outfits',
    ),
    EmotionalGoalOption(
      icon: '💍',
      title: 'Look amazing at an upcoming event',
      description: 'Feel your best for special occasions',
    ),
    EmotionalGoalOption(
      icon: '💪',
      title: 'Feel strong and confident',
      description: 'Build strength and self-assurance',
    ),
    EmotionalGoalOption(
      icon: '⚡',
      title: 'Have more energy throughout the day',
      description: 'Beat fatigue and stay energized',
    ),
    EmotionalGoalOption(
      icon: '🏃',
      title: 'Be more active and mobile',
      description: 'Move freely and enjoy physical activities',
    ),
  ];

  void _handleContinue() {
    if (_selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a goal to continue'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // TODO: Update user profile with emotional goal
    // For now, just navigate to chat
    context.go(AppRoutes.chat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('What\'s your goal?'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What would make you feel healthier?',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose what matters most to you right now',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _goals.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final goal = _goals[index];
                  final isSelected = _selectedGoal == goal.title;

                  return _GoalCard(
                    goal: goal,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedGoal = goal.title;
                      });
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: 'Continue',
                onPressed: _handleContinue,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmotionalGoalOption {
  final String icon;
  final String title;
  final String description;

  EmotionalGoalOption({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _GoalCard extends StatelessWidget {
  final EmotionalGoalOption goal;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  goal.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: AppTextStyles.body1Medium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal.description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
