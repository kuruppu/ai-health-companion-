import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/chat_message.dart';
import '../local/cache/hive_manager.dart';
import '../local/database/app_database.dart';
import '../models/chat_message_model.dart';

abstract class ChatLocalDataSource {
  Future<List<ChatMessageModel>> getChatHistory(String userId, int limit);
  Future<void> saveChatMessage(ChatMessageModel message);
  Future<void> clearChatHistory(String userId);
  Future<List<ChatMessageModel>> getCachedMessages(String userId);
  Future<void> cacheMessages(String userId, List<ChatMessageModel> messages);
}

@LazySingleton(as: ChatLocalDataSource)
class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final AppDatabase _database;
  final HiveManager _hiveManager;

  ChatLocalDataSourceImpl(this._database, this._hiveManager);

  @override
  Future<List<ChatMessageModel>> getChatHistory(
    String userId,
    int limit,
  ) async {
    try {
      final messages = await _database
          .watchChatMessages(userId)
          .first
          .then((list) => list.reversed.take(limit).toList().reversed.toList());

      return messages.map((msg) {
        return ChatMessageModel(
          messageId: msg.messageId,
          userId: msg.userId,
          role: msg.role,
          content: msg.content,
          messageType: _parseMessageType(msg.messageType),
          imageUrl: msg.imageUrl,
          audioUrl: msg.audioUrl,
          tokenCount: msg.tokenCount,
          isImportant: msg.isImportant,
          timestamp: msg.timestamp,
        );
      }).toList();
    } catch (e) {
      throw DatabaseException(message: e.toString());
    }
  }

  @override
  Future<void> saveChatMessage(ChatMessageModel message) async {
    try {
      await _database.insertChatMessage(
        ChatMessagesTableCompanion.insert(
          messageId: message.messageId,
          userId: message.userId,
          role: message.role,
          content: message.content,
          messageType: Value(message.messageType.toString().split('.').last),
          imageUrl: Value(message.imageUrl),
          audioUrl: Value(message.audioUrl),
          tokenCount: Value(message.tokenCount),
          isImportant: Value(message.isImportant),
          timestamp: Value(message.timestamp),
        ),
      );
    } catch (e) {
      throw DatabaseException(message: e.toString());
    }
  }

  @override
  Future<void> clearChatHistory(String userId) async {
    try {
      // TODO: Implement delete query in database
      // For now, this is a placeholder
    } catch (e) {
      throw DatabaseException(message: e.toString());
    }
  }

  @override
  Future<List<ChatMessageModel>> getCachedMessages(String userId) async {
    try {
      final cached = _hiveManager.getCachedChatHistory();

      if (cached == null) {
        return [];
      }

      return cached
          .map((json) => ChatMessageModel.fromJson(json))
          .take(AppConstants.maxChatHistoryMessages)
          .toList();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheMessages(
    String userId,
    List<ChatMessageModel> messages,
  ) async {
    try {
      final jsonList = messages
          .take(AppConstants.maxChatHistoryMessages)
          .map((msg) => msg.toJson())
          .toList();

      await _hiveManager.cacheChatHistory(jsonList);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  MessageType _parseMessageType(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'voice':
        return MessageType.voice;
      default:
        return MessageType.text;
    }
  }
}
