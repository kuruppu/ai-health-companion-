import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/chat_message.dart';
import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<ChatMessageModel> sendMessageToClaude({
    required String userId,
    required String content,
    required List<ChatMessageModel> conversationHistory,
    String? imageUrl,
  });
}

@LazySingleton(as: ChatRemoteDataSource)
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {

  ChatRemoteDataSourceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<ChatMessageModel> sendMessageToClaude({
    required String userId,
    required String content,
    required List<ChatMessageModel> conversationHistory,
    String? imageUrl,
  }) async {
    try {
      final apiKey = dotenv.env['CLAUDE_API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw const ServerException(
          message: 'Claude API key not configured',
        );
      }

      // Build messages for Claude API
      final messages = _buildMessages(conversationHistory, content, imageUrl);

      // Build system prompt
      final systemPrompt = _buildSystemPrompt(userId);

      final requestBody = {
        'model': 'claude-3-sonnet-20240229',
        'max_tokens': 1024,
        'system': systemPrompt,
        'messages': messages,
      };

      final response = await _dioClient.post(
        ApiEndpoints.claudeMessages,
        data: requestBody,
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
        ),
      );

      final responseData = response.data as Map<String, dynamic>;
      final assistantContent = responseData['content'][0]['text'] as String;
      final tokenCount = responseData['usage']['output_tokens'] as int;

      return ChatMessageModel(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        role: 'assistant',
        content: assistantContent,
        messageType: MessageType.text,
        tokenCount: tokenCount,
        timestamp: DateTime.now(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException(
          message: 'Invalid API key',
          code: '401',
        );
      } else if (e.response?.statusCode == 429) {
        throw const ServerException(
          message: 'Rate limit exceeded. Please try again later.',
          statusCode: 429,
        );
      } else {
        throw ServerException(
          message: e.message ?? 'Failed to send message',
          statusCode: e.response?.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  List<Map<String, dynamic>> _buildMessages(
    List<ChatMessageModel> history,
    String newContent,
    String? imageUrl,
  ) {
    final messages = <Map<String, dynamic>>[];

    // Add conversation history (last 10 messages for context)
    final recentHistory =
        history.length > 10 ? history.sublist(history.length - 10) : history;

    for (final msg in recentHistory) {
      messages.add({
        'role': msg.role,
        'content': msg.content,
      });
    }

    // Add new message
    if (imageUrl != null) {
      messages.add({
        'role': 'user',
        'content': [
          {
            'type': 'image',
            'source': {
              'type': 'url',
              'url': imageUrl,
            },
          },
          {
            'type': 'text',
            'text': newContent,
          },
        ],
      });
    } else {
      messages.add({
        'role': 'user',
        'content': newContent,
      });
    }

    return messages;
  }

  String _buildSystemPrompt(String userId) => '''
You are an AI health coach for the AI Health Companion app. Your role is to help users achieve their wellness goals through personalized guidance, motivation, and support.

Key Responsibilities:
1. Provide nutrition advice tailored to Sri Lankan cuisine
2. Recommend personalized workouts for users (especially new moms with limited time)
3. Track and celebrate progress toward emotional goals (e.g., "play with baby without getting tired")
4. Offer motivation and encouragement
5. Answer health and wellness questions

Communication Style:
- Be warm, supportive, and encouraging
- Use simple, conversational language
- Celebrate small wins
- Focus on outcomes and feelings, not just numbers
- Be concise but helpful
- Use emojis occasionally for warmth (but not excessively)

Important Guidelines:
- Always relate advice back to the user's emotional goal
- Emphasize energy, strength, and functional improvements over weight
- For meal logging, estimate calories and suggest healthier alternatives
- For workouts, consider time constraints (10-30 minute sessions)
- Never diagnose medical conditions - recommend seeing a doctor when appropriate

User Context:
- User ID: $userId
- Primary goal: Achieve emotional wellness outcome (e.g., more energy for parenting)
- Preferences: Sri Lankan cuisine, home workouts, practical advice

Your responses should feel like talking to a supportive friend who happens to be a health expert.''';
}
