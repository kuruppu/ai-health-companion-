import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {

  const ChatMessage({
    required this.messageId,
    required this.userId,
    required this.role,
    required this.content,
    required this.messageType,
    required this.timestamp, this.imageUrl,
    this.audioUrl,
    this.tokenCount,
    this.context,
    this.isImportant = false,
  });
  final String messageId;
  final String userId;
  final String role; // 'user' or 'assistant'
  final String content;
  final MessageType messageType; // text, image, voice

  // Optional fields for different message types
  final String? imageUrl;
  final String? audioUrl;
  final int? tokenCount;

  // Context tracking
  final Map<String, dynamic>? context;
  final bool isImportant;

  final DateTime timestamp;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get hasImage => imageUrl != null;
  bool get hasAudio => audioUrl != null;

  ChatMessage copyWith({
    String? messageId,
    String? userId,
    String? role,
    String? content,
    MessageType? messageType,
    String? imageUrl,
    String? audioUrl,
    int? tokenCount,
    Map<String, dynamic>? context,
    bool? isImportant,
    DateTime? timestamp,
  }) => ChatMessage(
      messageId: messageId ?? this.messageId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      tokenCount: tokenCount ?? this.tokenCount,
      context: context ?? this.context,
      isImportant: isImportant ?? this.isImportant,
      timestamp: timestamp ?? this.timestamp,
    );

  @override
  List<Object?> get props => [
        messageId,
        userId,
        role,
        content,
        messageType,
        imageUrl,
        audioUrl,
        tokenCount,
        context,
        isImportant,
        timestamp,
      ];
}

enum MessageType {
  text,
  image,
  voice,
}
