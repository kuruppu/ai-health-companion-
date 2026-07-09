import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../providers/auth_provider.dart';
import '../providers/integrated_chat_provider.dart';
import 'widgets/chat_input_field.dart';
import 'widgets/message_bubble.dart';

/// Integrated chat screen that handles both messages and meal check-ins
class IntegratedChatScreen extends ConsumerStatefulWidget {
  const IntegratedChatScreen({super.key});

  @override
  ConsumerState<IntegratedChatScreen> createState() =>
      _IntegratedChatScreenState();
}

class _IntegratedChatScreenState extends ConsumerState<IntegratedChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final chatState = ref.watch(integratedChatProvider);
    final hasPendingCheckIn = ref.watch(hasPendingCheckInProvider);

    final user = authState.value?.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Coach',
                  style: AppTextStyles.body1Medium,
                ),
                Text(
                  hasPendingCheckIn
                      ? 'Waiting for response...'
                      : 'Always here to help',
                  style: AppTextStyles.caption.copyWith(
                    color: hasPendingCheckIn
                        ? AppColors.warning
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(integratedChatProvider.notifier).clearPendingCheckIn(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Pending check-in indicator
          if (hasPendingCheckIn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.warning.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Meal check-in - please respond',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: chatState.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return _buildEmptyState();
                }

                // Scroll to bottom after messages load
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isLastMessage = index == messages.length - 1;

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: isLastMessage ? 8 : 12,
                      ),
                      child: MessageBubble(
                        message: message,
                        isUser: message.isUser,
                      ),
                    );
                  },
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
                  ],
                ),
              ),
            ),
          ),

          // Input field
          ChatInputField(
            onSendMessage: (content, messageType) async {
              await ref.read(integratedChatProvider.notifier).sendMessage(
                    content: content,
                    messageType: messageType,
                  );

              // Scroll to bottom after sending
              Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
            },
          ),
        ],
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
                Icons.waving_hand,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Hi! I\'m your AI health coach',
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'I\'ll check in with you throughout the day to help you stay on track with meals and workouts.',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'I\'ll check in at:',
                        style: AppTextStyles.body1Medium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildCheckInTime('9:00am', 'Breakfast check'),
                  _buildCheckInTime('12:30pm', 'Lunch check'),
                  _buildCheckInTime('7:00pm', 'Dinner check'),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildCheckInTime(String time, String label) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const SizedBox(width: 28),
          Text(
            '• ',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.primary,
            ),
          ),
          Text(
            time,
            style: AppTextStyles.body1Medium,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
}
