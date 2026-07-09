import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/meal_check_in.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_check_provider.dart';

/// Widget to display AI meal check-in message with quick response buttons
class MealCheckMessage extends ConsumerWidget {

  const MealCheckMessage({
    required this.message,
    required this.period,
    super.key,
  });
  final String message;
  final MealPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              message,
              style: AppTextStyles.body1,
            ),
          ),

          const SizedBox(height: 12),

          // Quick response buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleResponse(
                    context,
                    ref,
                    hadEaten: true,
                    response: 'Yes, I ate',
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Yes, I ate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleResponse(
                    context,
                    ref,
                    hadEaten: false,
                    response: 'Not yet',
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Not yet'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Send photo option
          Center(
            child: TextButton.icon(
              onPressed: () => _handlePhotoResponse(context, ref),
              icon: const Icon(Icons.camera_alt, size: 18),
              label: const Text('Send photo'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );

  void _handleResponse(
    BuildContext context,
    WidgetRef ref, {
    required bool hadEaten,
    required String response,
  }) {
    final authState = ref.read(authProvider);
    final user = authState.value?.getCurrentUser();

    if (user == null) return;

    // Record response
    ref.read(mealCheckChatProvider.notifier).handleResponse(
          userId: user.userId,
          hadEaten: hadEaten,
          response: response,
        );

    // Show AI acknowledgment
    if (hadEaten) {
      _showAIResponse(context, 'Great! Keep it up 👍');
    } else {
      _showAIResponse(
        context,
        'Okay, try to eat something in the next 30 minutes',
      );
    }
  }

  void _handlePhotoResponse(BuildContext context, WidgetRef ref) {
    // Navigate to nutrition screen to take photo
    Navigator.of(context).pushNamed('/nutrition');

    // Clear check-in (will be recorded when photo is uploaded)
    final authState = ref.read(authProvider);
    final user = authState.value?.getCurrentUser();

    if (user != null) {
      ref.read(mealCheckChatProvider.notifier).handleResponse(
            userId: user.userId,
            hadEaten: true,
            response: 'photo_sent',
          );
    }
  }

  void _showAIResponse(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
