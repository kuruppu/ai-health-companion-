import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_datasource.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_message_model.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {

  ChatRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
    this._uuid,
  );
  final ChatRemoteDataSource _remoteDataSource;
  final ChatLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final Uuid _uuid;

  final _messageStreamController = StreamController<ChatMessage>.broadcast();

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String userId,
    required String content,
    required MessageType messageType,
    String? imageUrl,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Save user message locally
      final userMessage = ChatMessageModel(
        messageId: _uuid.v4(),
        userId: userId,
        role: 'user',
        content: content,
        messageType: messageType,
        imageUrl: imageUrl,
        context: context,
        timestamp: DateTime.now(),
      );

      await _localDataSource.saveChatMessage(userMessage);
      _messageStreamController.add(userMessage.toEntity());

      // Check network
      if (!await _networkInfo.isConnected) {
        return const Left(
          NetworkFailure(
            message: 'No internet connection. Message saved locally.',
          ),
        );
      }

      // Get conversation history for context
      final history = await _localDataSource.getChatHistory(userId, 10);

      // Send to Claude API
      final assistantMessage = await _remoteDataSource.sendMessageToClaude(
        userId: userId,
        content: content,
        conversationHistory: history,
        imageUrl: imageUrl,
      );

      // Save assistant response locally
      await _localDataSource.saveChatMessage(assistantMessage);
      _messageStreamController.add(assistantMessage.toEntity());

      // Cache recent messages
      final allMessages = await _localDataSource.getChatHistory(userId, 50);
      await _localDataSource.cacheMessages(userId, allMessages);

      return Right(assistantMessage.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getChatHistory({
    required String userId,
    int limit = 50,
  }) async {
    try {
      // Try to get from database
      final messages = await _localDataSource.getChatHistory(userId, limit);

      return Right(messages.map((m) => m.toEntity()).toList());
    } on DatabaseException catch (e) {
      // Fallback to cache
      try {
        final cached = await _localDataSource.getCachedMessages(userId);
        return Right(cached.map((m) => m.toEntity()).toList());
      } catch (_) {
        return Left(DatabaseFailure(message: e.message));
      }
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearChatHistory(String userId) async {
    try {
      await _localDataSource.clearChatHistory(userId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Stream<ChatMessage> get messageStream => _messageStreamController.stream;

  void dispose() {
    _messageStreamController.close();
  }
}
