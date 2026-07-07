import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

@injectable
class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<Either<Failure, ChatMessage>> call({
    required String userId,
    required String content,
    required MessageType messageType,
    String? imageUrl,
    Map<String, dynamic>? context,
  }) async {
    if (userId.isEmpty) {
      return const Left(
        ValidationFailure(message: 'User ID is required'),
      );
    }

    if (content.isEmpty && imageUrl == null) {
      return const Left(
        ValidationFailure(message: 'Message content or image is required'),
      );
    }

    if (content.length > 2000) {
      return const Left(
        ValidationFailure(message: 'Message is too long (max 2000 characters)'),
      );
    }

    return await _repository.sendMessage(
      userId: userId,
      content: content,
      messageType: messageType,
      imageUrl: imageUrl,
      context: context,
    );
  }
}
