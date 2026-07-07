import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  /// Send a message to Claude AI and get response
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String userId,
    required String content,
    required MessageType messageType,
    String? imageUrl,
    Map<String, dynamic>? context,
  });

  /// Get chat history for user
  Future<Either<Failure, List<ChatMessage>>> getChatHistory({
    required String userId,
    int limit = 50,
  });

  /// Clear chat history
  Future<Either<Failure, void>> clearChatHistory(String userId);

  /// Stream of new messages
  Stream<ChatMessage> get messageStream;
}
