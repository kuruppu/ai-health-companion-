import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/injection_container.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/get_chat_history_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../providers/auth_provider.dart';

part 'chat_provider.g.dart';

@riverpod
class Chat extends _$Chat {
  late final SendMessageUseCase _sendMessageUseCase;
  late final GetChatHistoryUseCase _getChatHistoryUseCase;

  @override
  Future<List<ChatMessage>> build() async {
    _sendMessageUseCase = getIt<SendMessageUseCase>();
    _getChatHistoryUseCase = getIt<GetChatHistoryUseCase>();

    final user = ref.watch(authProvider).value?.getCurrentUser();

    if (user == null) {
      return [];
    }

    final result = await _getChatHistoryUseCase(
      userId: user.userId,
      limit: 50,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (messages) => messages,
    );
  }

  Future<void> sendMessage({
    required String content,
    MessageType messageType = MessageType.text,
    String? imageUrl,
  }) async {
    final user = ref.read(authProvider).value?.getCurrentUser();

    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Add user message to state immediately (optimistic update)
    final userMessage = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.userId,
      role: 'user',
      content: content,
      messageType: messageType,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
    );

    state = state.whenData((messages) => [...messages, userMessage]);

    // Send to backend
    final result = await _sendMessageUseCase(
      userId: user.userId,
      content: content,
      messageType: messageType,
      imageUrl: imageUrl,
    );

    result.fold(
      (failure) {
        // Remove optimistic message on error
        state = state.whenData(
          (messages) => messages.where((m) => m != userMessage).toList(),
        );
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (assistantMessage) {
        // Add assistant response
        state = state.whenData(
          (messages) => [...messages, assistantMessage],
        );
      },
    );
  }

  Future<void> refresh() async {
    final user = ref.read(authProvider).value?.getCurrentUser();

    if (user == null) {
      return;
    }

    state = const AsyncValue.loading();

    final result = await _getChatHistoryUseCase(
      userId: user.userId,
      limit: 50,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (messages) => AsyncValue.data(messages),
    );
  }
}
