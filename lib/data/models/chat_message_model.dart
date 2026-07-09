
import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.messageId,
    required super.userId,
    required super.role,
    required super.content,
    required super.messageType,
    required super.timestamp, super.imageUrl,
    super.audioUrl,
    super.tokenCount,
    super.context,
    super.isImportant,
  });

  factory ChatMessageModel.fromEntity(ChatMessage message) => ChatMessageModel(
      messageId: message.messageId,
      userId: message.userId,
      role: message.role,
      content: message.content,
      messageType: message.messageType,
      imageUrl: message.imageUrl,
      audioUrl: message.audioUrl,
      tokenCount: message.tokenCount,
      context: message.context,
      isImportant: message.isImportant,
      timestamp: message.timestamp,
    );

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
      messageId: json['messageId'] as String,
      userId: json['userId'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      messageType: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['messageType']}',
        orElse: () => MessageType.text,
      ),
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      tokenCount: json['tokenCount'] as int?,
      context: json['context'] != null
          ? Map<String, dynamic>.from(json['context'] as Map)
          : null,
      isImportant: json['isImportant'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

  Map<String, dynamic> toJson() => {
      'messageId': messageId,
      'userId': userId,
      'role': role,
      'content': content,
      'messageType': messageType.toString().split('.').last,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'tokenCount': tokenCount,
      'context': context,
      'isImportant': isImportant,
      'timestamp': timestamp.toIso8601String(),
    };

  ChatMessage toEntity() => ChatMessage(
      messageId: messageId,
      userId: userId,
      role: role,
      content: content,
      messageType: messageType,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      tokenCount: tokenCount,
      context: context,
      isImportant: isImportant,
      timestamp: timestamp,
    );
}
