import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/injection_container.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/meal_check_in.dart';
import '../../services/meal_check_service.dart';
import 'auth_provider.dart';
import 'chat_provider.dart';
import 'meal_check_provider.dart';

part 'integrated_chat_provider.g.dart';

/// Integrated chat that handles both regular messages and meal check-ins
@riverpod
class IntegratedChat extends _$IntegratedChat {
  MealPeriod? _pendingCheckIn;
  String? _lastCheckInMessageId;

  @override
  Future<List<ChatMessage>> build() async {
    // Watch regular chat messages
    final chatState = ref.watch(chatProvider);

    return chatState.maybeWhen(
      data: (messages) => messages,
      orElse: () => [],
    );
  }

  /// Add AI check-in message to chat
  Future<void> addCheckInMessage(MealPeriod period, String userName) async {
    final user = ref.read(authProvider).value?.getCurrentUser();
    if (user == null) return;

    _pendingCheckIn = period;

    // Generate check-in message
    final checkService = getIt<MealCheckService>();
    final messageContent = checkService.generateCheckInMessage(period, userName);

    // Create AI message
    final checkInMessage = ChatMessage(
      messageId: 'check_in_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.userId,
      role: 'assistant',
      content: messageContent,
      messageType: MessageType.text,
      timestamp: DateTime.now(),
    );

    _lastCheckInMessageId = checkInMessage.messageId;

    // Add to chat state
    state = state.whenData((messages) => [...messages, checkInMessage]);
  }

  /// Handle user response to check-in
  Future<void> handleCheckInResponse(String userResponse) async {
    if (_pendingCheckIn == null) return;

    final user = ref.read(authProvider).value?.getCurrentUser();
    if (user == null) return;

    final checkService = getIt<MealCheckService>();

    // Detect response type
    final responseLower = userResponse.toLowerCase();
    bool hadEaten = false;

    if (responseLower.contains('yes') ||
        responseLower.contains('ate') ||
        responseLower.contains('eaten') ||
        responseLower.contains('already')) {
      hadEaten = true;
    }

    // Record check-in
    checkService.recordCheckIn(
      userId: user.userId,
      period: _pendingCheckIn!,
      hadEaten: hadEaten,
      response: userResponse,
    );

    // Generate AI follow-up response
    String followUpMessage;
    if (hadEaten) {
      followUpMessage = _generatePositiveResponse();
    } else {
      followUpMessage = _generateReminderResponse(_pendingCheckIn!);
    }

    // Add AI follow-up to chat
    final followUpChatMessage = ChatMessage(
      messageId: 'followup_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.userId,
      role: 'assistant',
      content: followUpMessage,
      messageType: MessageType.text,
      timestamp: DateTime.now(),
    );

    state = state.whenData((messages) => [...messages, followUpChatMessage]);

    // Clear pending check-in
    _pendingCheckIn = null;
    _lastCheckInMessageId = null;
  }

  /// Send regular message (also checks if it's a check-in response)
  Future<void> sendMessage({
    required String content,
    MessageType messageType = MessageType.text,
    String? imageUrl,
  }) async {
    // Check if this is a response to a pending check-in
    if (_pendingCheckIn != null &&
        _lastCheckInMessageId != null &&
        messageType == MessageType.text) {
      // This is a check-in response
      await handleCheckInResponse(content);
    }

    // Send through regular chat system
    await ref.read(chatProvider.notifier).sendMessage(
          content: content,
          messageType: messageType,
          imageUrl: imageUrl,
        );
  }

  /// Get pending check-in period
  MealPeriod? get pendingCheckIn => _pendingCheckIn;

  /// Check if last message was a check-in
  bool isLastMessageCheckIn() {
    return _lastCheckInMessageId != null;
  }

  String _generatePositiveResponse() {
    final responses = [
      'Great! Keep it up 👍',
      'Nice work! Staying consistent.',
      'Perfect! That\'s what I like to see.',
      'Excellent! You\'re on track today.',
    ];

    return responses[DateTime.now().second % responses.length];
  }

  String _generateReminderResponse(MealPeriod period) {
    final mealName = period.displayName;

    final responses = [
      'Okay, try to eat something in the next 30 minutes. What do you have available?',
      'No problem. Set a timer for 30 minutes and grab something quick. What\'s in your kitchen?',
      'Got it. Quick $mealName idea: Something simple like toast + eggs takes 5 minutes. Can you do that?',
      'Alright. I\'ll check back in 30 minutes. Even something small is better than skipping!',
    ];

    return responses[DateTime.now().second % responses.length];
  }

  /// Clear pending check-in (if user navigates away)
  void clearPendingCheckIn() {
    _pendingCheckIn = null;
    _lastCheckInMessageId = null;
  }
}

/// Provider to expose if there's a pending check-in
@riverpod
bool hasPendingCheckIn(HasPendingCheckInRef ref) {
  return ref.watch(integratedChatProvider.notifier).pendingCheckIn != null;
}
