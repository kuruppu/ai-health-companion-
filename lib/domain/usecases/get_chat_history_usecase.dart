import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

@injectable
class GetChatHistoryUseCase {

  GetChatHistoryUseCase(this._repository);
  final ChatRepository _repository;

  Future<Either<Failure, List<ChatMessage>>> call({
    required String userId,
    int limit = 50,
  }) async {
    if (userId.isEmpty) {
      return const Left(
        ValidationFailure(message: 'User ID is required'),
      );
    }

    if (limit < 1 || limit > 100) {
      return const Left(
        ValidationFailure(message: 'Limit must be between 1 and 100'),
      );
    }

    return _repository.getChatHistory(
      userId: userId,
      limit: limit,
    );
  }
}
