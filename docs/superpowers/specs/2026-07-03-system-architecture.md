# AI Health Companion - Complete System Architecture

**Date:** 2026-07-03
**Version:** 1.0
**Platform:** Android (Flutter)
**Architecture:** Clean Architecture + MVVM

---

## Table of Contents

1. [Folder Structure (Clean Architecture)](#1-folder-structure-clean-architecture)
2. [API Layer Design](#2-api-layer-design)
3. [State Management (Riverpod)](#3-state-management-riverpod)
4. [Navigation & UI Flow](#4-navigation--ui-flow)
5. [Error Handling Strategy](#5-error-handling-strategy)
6. [Offline Support](#6-offline-support)
7. [Security & Authentication](#7-security--authentication)
8. [Performance Optimization](#8-performance-optimization)
9. [Testing Strategy](#9-testing-strategy)
10. [Deployment & CI/CD](#10-deployment--cicd)

---

## 1. Folder Structure (Clean Architecture)

### 1.1 Project Structure Overview

```
ai_health_companion/
├── android/                          # Android native code
├── ios/                              # iOS native code (future)
├── assets/                           # Static assets
│   ├── images/
│   ├── fonts/
│   ├── animations/
│   └── data/                         # Seed data, food database
├── lib/
│   ├── main.dart                     # App entry point
│   ├── app.dart                      # MaterialApp configuration
│   │
│   ├── core/                         # Shared utilities
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   ├── app_constants.dart
│   │   │   ├── storage_constants.dart
│   │   │   └── theme_constants.dart
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   ├── failures.dart
│   │   │   └── error_handler.dart
│   │   ├── network/
│   │   │   ├── network_info.dart
│   │   │   └── dio_client.dart
│   │   ├── utils/
│   │   │   ├── date_utils.dart
│   │   │   ├── validators.dart
│   │   │   ├── formatters.dart
│   │   │   └── extensions.dart
│   │   ├── themes/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_text_styles.dart
│   │   └── di/
│   │       └── injection_container.dart  # Dependency injection
│   │
│   ├── features/                     # Feature modules
│   │   │
│   │   ├── auth/                     # Authentication feature
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_local_datasource.dart
│   │   │   │   │   └── auth_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── user_model.dart
│   │   │   │   │   └── auth_token_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── login_with_email.dart
│   │   │   │       ├── login_with_phone.dart
│   │   │   │       ├── verify_otp.dart
│   │   │   │       ├── logout.dart
│   │   │   │       └── get_current_user.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── auth_provider.dart
│   │   │       │   └── auth_state.dart
│   │   │       ├── screens/
│   │   │       │   ├── login_screen.dart
│   │   │       │   ├── otp_verification_screen.dart
│   │   │       │   └── onboarding_screen.dart
│   │   │       └── widgets/
│   │   │           ├── email_input_field.dart
│   │   │           ├── phone_input_field.dart
│   │   │           └── otp_input_field.dart
│   │   │
│   │   ├── profile/                  # User profile management
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   │       ├── get_user_profile.dart
│   │   │   │       ├── update_user_profile.dart
│   │   │   │       └── calculate_bmr_tdee.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── screens/
│   │   │       │   ├── profile_screen.dart
│   │   │       │   └── edit_profile_screen.dart
│   │   │       └── widgets/
│   │   │
│   │   ├── chat/                     # AI Chat feature
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── chat_local_datasource.dart
│   │   │   │   │   └── chat_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── message_model.dart
│   │   │   │   │   └── conversation_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── chat_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── message_entity.dart
│   │   │   │   │   └── conversation_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── chat_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── send_message.dart
│   │   │   │       ├── get_conversation_history.dart
│   │   │   │       ├── create_conversation.dart
│   │   │   │       └── stream_ai_response.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── chat_provider.dart
│   │   │       │   └── message_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── chat_screen.dart
│   │   │       └── widgets/
│   │   │           ├── message_bubble.dart
│   │   │           ├── message_input.dart
│   │   │           ├── typing_indicator.dart
│   │   │           └── suggestion_chips.dart
│   │   │
│   │   ├── meals/                    # Meal logging feature
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   │   └── meal_model.dart
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── meal_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   │       ├── log_meal.dart
│   │   │   │       ├── get_today_meals.dart
│   │   │   │       ├── get_remaining_calories.dart
│   │   │   │       ├── check_flex_meal_status.dart
│   │   │   │       └── get_meal_history.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── screens/
│   │   │       │   ├── meals_history_screen.dart
│   │   │       │   └── meal_detail_screen.dart
│   │   │       └── widgets/
│   │   │           ├── meal_card.dart
│   │   │           ├── calorie_progress_bar.dart
│   │   │           └── flex_meal_indicator.dart
│   │   │
│   │   ├── workouts/                 # Workout recommendations
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   │   └── usecases/
│   │   │   │       ├── get_daily_workout.dart
│   │   │   │       ├── complete_workout.dart
│   │   │   │       ├── skip_workout.dart
│   │   │   │       └── get_workout_history.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── workout_screen.dart
│   │   │       │   └── workout_history_screen.dart
│   │   │       └── widgets/
│   │   │           ├── workout_card.dart
│   │   │           ├── video_player_widget.dart
│   │   │           └── workout_timer.dart
│   │   │
│   │   ├── progress/                 # Weight & progress tracking
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   │   └── usecases/
│   │   │   │       ├── log_weight.dart
│   │   │   │       ├── get_weight_history.dart
│   │   │   │       ├── calculate_progress.dart
│   │   │   │       └── check_milestones.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── progress_screen.dart
│   │   │       │   └── weight_log_screen.dart
│   │   │       └── widgets/
│   │   │           ├── weight_graph.dart
│   │   │           ├── milestone_card.dart
│   │   │           └── progress_stats.dart
│   │   │
│   │   ├── reminders/                # Water & stand-up reminders
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   │   └── usecases/
│   │   │   │       ├── schedule_reminders.dart
│   │   │   │       ├── log_water_intake.dart
│   │   │   │       ├── log_activity.dart
│   │   │   │       └── get_today_logs.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── reminders_settings_screen.dart
│   │   │       └── widgets/
│   │   │           ├── water_intake_widget.dart
│   │   │           └── activity_log_widget.dart
│   │   │
│   │   └── dashboard/                # Home dashboard
│   │       ├── data/
│   │       ├── domain/
│   │       │   └── usecases/
│   │       │       ├── get_daily_summary.dart
│   │       │       └── refresh_dashboard.dart
│   │       └── presentation/
│   │           ├── screens/
│   │           │   └── dashboard_screen.dart
│   │           └── widgets/
│   │               ├── calorie_card.dart
│   │               ├── workout_card.dart
│   │               ├── water_tracker.dart
│   │               └── ai_suggestion_card.dart
│   │
│   └── services/                     # Shared services
│       ├── ai/
│       │   ├── claude_service.dart
│       │   ├── ai_context_builder.dart
│       │   └── prompt_templates.dart
│       ├── notifications/
│       │   ├── notification_service.dart
│       │   └── reminder_scheduler.dart
│       ├── storage/
│       │   ├── hive_service.dart
│       │   ├── sqlite_service.dart
│       │   └── secure_storage_service.dart
│       ├── sync/
│       │   ├── sync_manager.dart
│       │   ├── offline_queue_manager.dart
│       │   └── conflict_resolver.dart
│       └── analytics/
│           └── analytics_service.dart
│
├── test/                             # Unit tests
├── integration_test/                 # Integration tests
├── docs/                             # Documentation
├── pubspec.yaml                      # Dependencies
└── README.md

```

### 1.2 Why This Structure?

**Clean Architecture Benefits:**
- ✅ **Separation of Concerns:** Each layer has single responsibility
- ✅ **Testability:** Business logic independent of UI/infrastructure
- ✅ **Maintainability:** Changes in one layer don't cascade
- ✅ **Scalability:** Easy to add new features without affecting existing code
- ✅ **Team Collaboration:** Multiple developers can work on different features

**Layer Dependencies (Dependency Rule):**
```
Presentation Layer (UI)
       ↓  (depends on)
  Domain Layer (Business Logic)
       ↓  (depends on)
   Data Layer (Data Sources)
```

**Key Rule:** Inner layers (Domain) NEVER depend on outer layers (Presentation, Data)

---

## 2. API Layer Design

### 2.1 Claude API Integration

```dart
// lib/services/ai/claude_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClaudeService {
  final Dio _dio;
  final String _apiKey;
  final String _baseUrl = 'https://api.anthropic.com/v1';

  ClaudeService({
    required Dio dio,
    required String apiKey,
  })  : _dio = dio,
        _apiKey = apiKey {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['anthropic-version'] = '2023-06-01';
          options.headers['x-api-key'] = _apiKey;
          options.headers['content-type'] = 'application/json';
          return handler.next(options);
        },
        onError: (error, handler) {
          _handleApiError(error);
          return handler.next(error);
        },
      ),
    );
  }

  /// Send message to Claude with streaming response
  Stream<String> sendMessageStream({
    required String message,
    required List<Message> conversationHistory,
    required String userId,
  }) async* {
    try {
      // Build AI context
      final context = await _buildContext(userId);

      // Prepare messages
      final messages = [
        ...conversationHistory.map((m) => {
              'role': m.role,
              'content': m.content,
            }),
        {
          'role': 'user',
          'content': message,
        },
      ];

      // API request
      final response = await _dio.post(
        '$_baseUrl/messages',
        data: {
          'model': 'claude-3-5-sonnet-20241022',
          'max_tokens': 2048,
          'system': context,
          'messages': messages,
          'stream': true,
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      // Stream response
      final stream = response.data.stream;
      await for (final chunk in stream) {
        final lines = utf8.decode(chunk).split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') break;

            final json = jsonDecode(data);
            if (json['type'] == 'content_block_delta') {
              final text = json['delta']['text'];
              yield text;
            }
          }
        }
      }
    } catch (e) {
      throw AIException('Failed to send message: $e');
    }
  }

  /// Send message without streaming (simpler)
  Future<AIResponse> sendMessage({
    required String message,
    required List<Message> conversationHistory,
    required String userId,
  }) async {
    try {
      final context = await _buildContext(userId);

      final messages = [
        ...conversationHistory.map((m) => {
              'role': m.role,
              'content': m.content,
            }),
        {
          'role': 'user',
          'content': message,
        },
      ];

      final response = await _dio.post(
        '$_baseUrl/messages',
        data: {
          'model': 'claude-3-5-sonnet-20241022',
          'max_tokens': 2048,
          'system': context,
          'messages': messages,
        },
      );

      return AIResponse.fromJson(response.data);
    } catch (e) {
      throw AIException('Failed to send message: $e');
    }
  }

  /// Build AI context with user data
  Future<String> _buildContext(String userId) async {
    final contextBuilder = AIContextBuilder();

    // Load user profile
    final profile = await _getUserProfile(userId);
    contextBuilder.addUserProfile(profile);

    // Load recent weight logs
    final weightLogs = await _getRecentWeightLogs(userId, days: 7);
    contextBuilder.addWeightTrend(weightLogs);

    // Load today's meals
    final meals = await _getTodayMeals(userId);
    contextBuilder.addTodayMeals(meals);

    // Load AI learned context
    final aiContext = await _getAIContext(userId);
    contextBuilder.addLearnedContext(aiContext);

    return contextBuilder.build();
  }

  void _handleApiError(DioException error) {
    if (error.response?.statusCode == 429) {
      throw RateLimitException('Too many requests');
    } else if (error.response?.statusCode == 401) {
      throw AuthenticationException('Invalid API key');
    } else {
      throw AIException('API error: ${error.message}');
    }
  }
}

// Provider
final claudeServiceProvider = Provider<ClaudeService>((ref) {
  return ClaudeService(
    dio: ref.watch(dioProvider),
    apiKey: ref.watch(apiKeyProvider),
  );
});
```

### 2.2 AI Context Builder

```dart
// lib/services/ai/ai_context_builder.dart

class AIContextBuilder {
  final StringBuffer _context = StringBuffer();

  void addUserProfile(UserProfile profile) {
    _context.writeln('''
You are a personal AI health coach for a user with the following profile:

**Personal Information:**
- Age: ${profile.age} years old
- Height: ${profile.heightCm} cm
- Current Weight: ${profile.currentWeightKg} kg
- Goal Weight: ${profile.goalWeightKg} kg
- Goal Deadline: ${profile.goalDeadline.toIso8601String()}
- Gender: ${profile.gender}

**Metabolic Data:**
- BMR (Basal Metabolic Rate): ${profile.bmr} calories/day
- TDEE (Total Daily Energy Expenditure): ${profile.tdee} calories/day
- Daily Calorie Target: ${profile.dailyCalorieTarget} calories

**Lifestyle:**
- Occupation: ${profile.occupation}
- Activity Level: ${profile.activityLevel}
- Has a baby: ${profile.hasBaby}
- Preferred Workout: ${profile.preferredWorkoutStyle}
- Flex Meals Per Week: ${profile.flexMealsPerWeek}
- Alcohol Frequency: ${profile.alcoholFrequency}

**Your Role:**
- Provide portion size recommendations for meals
- Suggest specific Deepthi workout videos
- Track progress and provide motivation
- Help maintain 2 flex meals per week
- Monitor water intake and activity levels
''');
  }

  void addWeightTrend(List<WeightLog> logs) {
    if (logs.isEmpty) return;

    _context.writeln('\n**Recent Weight Progress:**');
    for (final log in logs) {
      _context.writeln('- ${log.measuredAt.toLocal()}: ${log.weightKg} kg');
    }

    final firstWeight = logs.last.weightKg;
    final lastWeight = logs.first.weightKg;
    final change = lastWeight - firstWeight;

    _context.writeln(
        '\nWeight change over last 7 days: ${change.toStringAsFixed(1)} kg');
  }

  void addTodayMeals(List<Meal> meals) {
    if (meals.isEmpty) {
      _context.writeln('\n**Today\'s Meals:** None logged yet.');
      return;
    }

    final totalCalories = meals.fold(0.0, (sum, meal) => sum + meal.calories);

    _context.writeln('\n**Today\'s Meals:**');
    for (final meal in meals) {
      _context.writeln(
          '- ${meal.mealType}: ${meal.mealDescription} (${meal.calories} cal)');
    }
    _context.writeln('Total consumed: $totalCalories calories');
  }

  void addLearnedContext(List<AIContext> contexts) {
    if (contexts.isEmpty) return;

    _context.writeln('\n**Learned Preferences:**');
    for (final ctx in contexts) {
      _context.writeln('- ${ctx.contextKey}: ${ctx.contextValue}');
    }
  }

  String build() {
    _context.writeln('''

**Guidelines:**
1. Always provide specific portion sizes (e.g., "1 cup rice, 150g chicken")
2. Consider remaining calories when recommending portions
3. Detect potential flex meals (>800 calories) and ask user
4. Suggest Deepthi videos by title based on user's energy and progress
5. Be conversational, supportive, and motivating
6. Use simple language suitable for daily interactions

**Important Rules:**
- Never recommend less than 1200 calories per day
- Always account for cultural Sri Lankan food preferences
- Respect the 2 flex meals per week limit
- Encourage consistency over perfection
''');

    return _context.toString();
  }
}
```

### 2.3 API Error Handling

```dart
// lib/core/errors/exceptions.dart

abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class AIException extends AppException {
  AIException(String message) : super(message, code: 'AI_ERROR');
}

class RateLimitException extends AppException {
  RateLimitException(String message)
      : super(message, code: 'RATE_LIMIT_EXCEEDED');
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, code: 'NETWORK_ERROR');
}

class AuthenticationException extends AppException {
  AuthenticationException(String message) : super(message, code: 'AUTH_ERROR');
}

class CacheException extends AppException {
  CacheException(String message) : super(message, code: 'CACHE_ERROR');
}

// lib/core/errors/failures.dart

abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});
}

class AIFailure extends Failure {
  const AIFailure(String message) : super(message, code: 'AI_FAILURE');
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message)
      : super(message, code: 'NETWORK_FAILURE');
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message, code: 'CACHE_FAILURE');
}
```

### 2.4 Retry Logic & Circuit Breaker

```dart
// lib/core/network/retry_policy.dart

class RetryPolicy {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;

  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
  });

  Future<T> execute<T>(Future<T> Function() operation) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;

        if (attempt >= maxAttempts) {
          rethrow;
        }

        // Exponential backoff
        await Future.delayed(delay);
        delay *= backoffMultiplier;
      }
    }
  }
}

// Circuit Breaker Pattern
class CircuitBreaker {
  final int failureThreshold;
  final Duration resetTimeout;

  int _failureCount = 0;
  CircuitState _state = CircuitState.closed;
  DateTime? _lastFailureTime;

  CircuitBreaker({
    this.failureThreshold = 5,
    this.resetTimeout = const Duration(minutes: 1),
  });

  Future<T> execute<T>(Future<T> Function() operation) async {
    if (_state == CircuitState.open) {
      if (_shouldAttemptReset()) {
        _state = CircuitState.halfOpen;
      } else {
        throw CircuitBreakerOpenException('Circuit breaker is open');
      }
    }

    try {
      final result = await operation();
      _onSuccess();
      return result;
    } catch (e) {
      _onFailure();
      rethrow;
    }
  }

  bool _shouldAttemptReset() {
    return _lastFailureTime != null &&
        DateTime.now().difference(_lastFailureTime!) > resetTimeout;
  }

  void _onSuccess() {
    _failureCount = 0;
    _state = CircuitState.closed;
  }

  void _onFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();

    if (_failureCount >= failureThreshold) {
      _state = CircuitState.open;
    }
  }
}

enum CircuitState { closed, open, halfOpen }

class CircuitBreakerOpenException implements Exception {
  final String message;
  CircuitBreakerOpenException(this.message);
}
```

---

## 3. State Management (Riverpod)

### 3.1 Riverpod Architecture

**Why Riverpod?**
- ✅ Compile-time safety (no context required)
- ✅ Easy testing (no BuildContext needed)
- ✅ Automatic disposal
- ✅ Provider composition
- ✅ DevTools integration

### 3.2 State Management Patterns

```dart
// lib/features/chat/presentation/providers/chat_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_state.freezed.dart';

// State definition
@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<Message> messages,
    @Default('') String currentConversationId,
    @Default(false) bool isLoading,
    @Default(false) bool isStreaming,
    @Default('') String streamingText,
    String? errorMessage,
  }) = _ChatState;
}

// State notifier
class ChatNotifier extends StateNotifier<ChatState> {
  final SendMessage _sendMessage;
  final GetConversationHistory _getHistory;
  final StreamAIResponse _streamResponse;

  ChatNotifier({
    required SendMessage sendMessage,
    required GetConversationHistory getHistory,
    required StreamAIResponse streamResponse,
  })  : _sendMessage = sendMessage,
        _getHistory = getHistory,
        _streamResponse = streamResponse,
        super(const ChatState());

  /// Load conversation history
  Future<void> loadConversation(String conversationId) async {
    state = state.copyWith(isLoading: true);

    final result = await _getHistory(conversationId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (messages) => state = state.copyWith(
        isLoading: false,
        messages: messages,
        currentConversationId: conversationId,
      ),
    );
  }

  /// Send message with streaming response
  Future<void> sendMessageWithStream(String message) async {
    // Add user message immediately
    final userMessage = Message(
      id: uuid.v4(),
      role: 'user',
      content: message,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isStreaming: true,
      streamingText: '',
    );

    try {
      // Stream AI response
      await for (final chunk in _streamResponse(
        message: message,
        conversationId: state.currentConversationId,
      )) {
        state = state.copyWith(
          streamingText: state.streamingText + chunk,
        );
      }

      // Complete streaming, add AI message
      final aiMessage = Message(
        id: uuid.v4(),
        role: 'assistant',
        content: state.streamingText,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isStreaming: false,
        streamingText: '',
      );
    } catch (e) {
      state = state.copyWith(
        isStreaming: false,
        errorMessage: 'Failed to send message: $e',
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    sendMessage: ref.watch(sendMessageProvider),
    getHistory: ref.watch(getConversationHistoryProvider),
    streamResponse: ref.watch(streamAIResponseProvider),
  );
});
```

### 3.3 Dashboard State (Complex Aggregation)

```dart
// lib/features/dashboard/presentation/providers/dashboard_provider.dart

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState({
    required DailySummary summary,
    Workout? todayWorkout,
    @Default([]) List<Message> recentSuggestions,
    @Default(false) bool isRefreshing,
    String? errorMessage,
  }) = _DashboardState;
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final GetDailySummary _getDailySummary;
  final GetTodayWorkout _getTodayWorkout;
  final GetRecentSuggestions _getRecentSuggestions;

  DashboardNotifier({
    required GetDailySummary getDailySummary,
    required GetTodayWorkout getTodayWorkout,
    required GetRecentSuggestions getRecentSuggestions,
  })  : _getDailySummary = getDailySummary,
        _getTodayWorkout = getTodayWorkout,
        _getRecentSuggestions = getRecentSuggestions,
        super(DashboardState(
          summary: DailySummary.empty(),
        ));

  /// Load all dashboard data
  Future<void> loadDashboard() async {
    state = state.copyWith(isRefreshing: true);

    // Parallel fetch
    final results = await Future.wait([
      _getDailySummary(),
      _getTodayWorkout(),
      _getRecentSuggestions(),
    ]);

    final summaryResult = results[0] as Either<Failure, DailySummary>;
    final workoutResult = results[1] as Either<Failure, Workout?>;
    final suggestionsResult = results[2] as Either<Failure, List<Message>>;

    summaryResult.fold(
      (failure) => state = state.copyWith(
        isRefreshing: false,
        errorMessage: failure.message,
      ),
      (summary) {
        workoutResult.fold(
          (failure) => null,
          (workout) {
            suggestionsResult.fold(
              (failure) => null,
              (suggestions) {
                state = state.copyWith(
                  summary: summary,
                  todayWorkout: workout,
                  recentSuggestions: suggestions,
                  isRefreshing: false,
                );
              },
            );
          },
        );
      },
    );
  }

  /// Refresh dashboard
  Future<void> refresh() => loadDashboard();
}

// Provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(
    getDailySummary: ref.watch(getDailySummaryProvider),
    getTodayWorkout: ref.watch(getTodayWorkoutProvider),
    getRecentSuggestions: ref.watch(getRecentSuggestionsProvider),
  );
});

// Auto-refresh provider (every 5 minutes)
final dashboardAutoRefreshProvider = StreamProvider<void>((ref) {
  return Stream.periodic(const Duration(minutes: 5), (_) {
    ref.read(dashboardProvider.notifier).refresh();
  });
});
```

### 3.4 Global App State

```dart
// lib/core/providers/app_providers.dart

// Current user provider
final currentUserProvider = FutureProvider<UserProfile>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.user == null) {
    throw UnauthorizedException('Not logged in');
  }

  final getUserProfile = ref.watch(getUserProfileProvider);
  final result = await getUserProfile(authState.user!.id);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (profile) => profile,
  );
});

// Network status provider
final networkStatusProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((result) {
    return result != ConnectivityResult.none;
  });
});

// Sync status provider
final syncStatusProvider = StateNotifierProvider<SyncStatusNotifier, SyncStatus>(
  (ref) => SyncStatusNotifier(ref.watch(syncManagerProvider)),
);

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  void setTheme(ThemeMode mode) {
    state = mode;
    // Persist to Hive
    Hive.box('preferences').put('theme_mode', mode.index);
  }
}
```

---

## 4. Navigation & UI Flow

### 4.1 Navigation Architecture (go_router)

```dart
// lib/core/navigation/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        final isLoggedIn = authState.user != null;

        // Auth redirect logic
        if (!isLoggedIn && !state.location.startsWith('/auth')) {
          return '/auth/login';
        }

        if (isLoggedIn && state.location.startsWith('/auth')) {
          return '/dashboard';
        }

        return null;
      },
      routes: [
        // Splash
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Auth flow
        GoRoute(
          path: '/auth',
          routes: [
            GoRoute(
              path: 'login',
              builder: (context, state) => const LoginScreen(),
            ),
            GoRoute(
              path: 'verify-otp',
              builder: (context, state) => OTPVerificationScreen(
                phoneOrEmail: state.extra as String,
              ),
            ),
            GoRoute(
              path: 'onboarding',
              builder: (context, state) => const OnboardingScreen(),
            ),
          ],
        ),

        // Main app (bottom navigation shell)
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return MainScaffold(child: child);
          },
          routes: [
            // Dashboard
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) => NoTransitionPage(
                child: DashboardScreen(),
              ),
            ),

            // Chat
            GoRoute(
              path: '/chat',
              pageBuilder: (context, state) => NoTransitionPage(
                child: ChatScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'conversation/:id',
                  builder: (context, state) => ChatScreen(
                    conversationId: state.pathParameters['id'],
                  ),
                ),
              ],
            ),

            // Progress
            GoRoute(
              path: '/progress',
              pageBuilder: (context, state) => NoTransitionPage(
                child: ProgressScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'log-weight',
                  builder: (context, state) => WeightLogScreen(),
                ),
              ],
            ),

            // Profile
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => NoTransitionPage(
                child: ProfileScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => EditProfileScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => SettingsScreen(),
                ),
              ],
            ),
          ],
        ),

        // Full-screen routes
        GoRoute(
          path: '/workout/:id',
          builder: (context, state) => WorkoutScreen(
            workoutId: state.pathParameters['id']!,
          ),
        ),

        GoRoute(
          path: '/meal-history',
          builder: (context, state) => MealsHistoryScreen(),
        ),
      ],

      errorBuilder: (context, state) => ErrorScreen(
        error: state.error.toString(),
      ),
    );
  }
}

// Provider
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter(ref);
});
```

### 4.2 Bottom Navigation Shell

```dart
// lib/core/navigation/main_scaffold.dart

class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouter.of(context).location;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(currentPath),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/chat')) return 1;
    if (location.startsWith('/progress')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/chat');
        break;
      case 2:
        context.go('/progress');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}
```

### 4.3 User Flow Diagram

```
┌──────────────┐
│ Splash Screen│
└──────┬───────┘
       │
       ├──[Not Logged In]─→ Login Screen
       │                         │
       │                         ├─→ Enter Email/Phone
       │                         │
       │                         ├─→ OTP Verification
       │                         │
       │                         └─→ Onboarding (first time)
       │                              │
       │                              ├─→ Personal Info
       │                              ├─→ Goals Setup
       │                              └─→ Preferences
       │
       └──[Logged In]─────→ Dashboard (Home)
                                │
                                ├─→ View Daily Summary
                                ├─→ Quick Actions
                                └─→ AI Suggestions
                                │
                      ┌─────────┴──────────┐
                      │                    │
                   Chat Tab           Progress Tab
                      │                    │
            ┌─────────┴──────┐            ├─→ Weight Graph
            │                │            ├─→ Milestones
            ├─→ Ask AI       │            └─→ Log Weight
            ├─→ Meal Portion │
            ├─→ Workout Rec  │
            └─→ Motivat ion  │
                             │
                        Profile Tab
                             │
                             ├─→ Edit Profile
                             ├─→ Settings
                             ├─→ Reminders Config
                             └─→ Logout
```

---

## 5. Error Handling Strategy

### 5.1 Global Error Handler

```dart
// lib/core/errors/error_handler.dart

class GlobalErrorHandler {
  static void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack);
    };

    // Handle async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack);
      return true;
    };
  }

  static void _logError(Object error, StackTrace? stack) {
    // Log to analytics
    AnalyticsService.logError(error.toString(), stack);

    // Log to console in debug mode
    if (kDebugMode) {
      print('Error: $error');
      print('Stack: $stack');
    }

    // Send to crash reporting (Sentry/Firebase Crashlytics)
    // SentryService.captureException(error, stackTrace: stack);
  }

  static void handleException(
    BuildContext context,
    Object exception, {
    VoidCallback? onRetry,
  }) {
    String message = 'An error occurred';
    String? actionLabel;
    VoidCallback? action;

    if (exception is NetworkException) {
      message = 'No internet connection';
      actionLabel = 'Retry';
      action = onRetry;
    } else if (exception is AIException) {
      message = 'AI service unavailable';
      actionLabel = 'Try Again';
      action = onRetry;
    } else if (exception is RateLimitException) {
      message = 'Too many requests. Please wait.';
    } else if (exception is AuthenticationException) {
      message = 'Authentication failed';
      actionLabel = 'Login';
      action = () => context.go('/auth/login');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action != null
            ? SnackBarAction(label: actionLabel!, onPressed: action)
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
```

### 5.2 Error Widget

```dart
// lib/core/widgets/error_widget.dart

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 6. Offline Support

### 6.1 Offline Queue Manager

```dart
// lib/services/sync/offline_queue_manager.dart

class OfflineQueueManager {
  final HiveService _hiveService;
  final NetworkInfo _networkInfo;

  OfflineQueueManager({
    required HiveService hiveService,
    required NetworkInfo networkInfo,
  })  : _hiveService = hiveService,
        _networkInfo = networkInfo;

  /// Add item to offline queue
  Future<void> enqueue(QueueItem item) async {
    final box = await Hive.openBox<OfflineQueueItem>('offline_queue');
    await box.add(OfflineQueueItem.fromDomain(item));

    // Try to process immediately if online
    if (await _networkInfo.isConnected) {
      processQueue();
    }
  }

  /// Process entire queue
  Future<void> processQueue() async {
    if (!await _networkInfo.isConnected) return;

    final box = await Hive.openBox<OfflineQueueItem>('offline_queue');
    final items = box.values.toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));

    for (final item in items) {
      try {
        await _processItem(item);
        await box.delete(item.key);
      } catch (e) {
        item.retryCount++;
        item.errorMessage = e.toString();
        await item.save();

        if (item.retryCount >= 5) {
          await box.delete(item.key);
          _logFailedItem(item);
        }
      }
    }
  }

  Future<void> _processItem(OfflineQueueItem item) async {
    switch (item.type) {
      case 'chat_message':
        await _processChatMessage(item);
        break;
      case 'meal_log':
        await _processMealLog(item);
        break;
      case 'workout_log':
        await _processWorkoutLog(item);
        break;
      case 'water_log':
        await _processWaterLog(item);
        break;
      default:
        throw UnimplementedError('Unknown queue item type: ${item.type}');
    }
  }

  Future<void> _processChatMessage(OfflineQueueItem item) async {
    final data = jsonDecode(item.jsonData);
    final message = Message.fromJson(data);

    // Send to API
    await _chatRepository.sendMessage(message);

    // Sync to Firestore
    await _syncManager.syncMessage(message);
  }

  // Similar methods for other types...
}
```

### 6.2 Offline Indicator

```dart
// lib/core/widgets/offline_indicator.dart

class OfflineIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(networkStatusProvider).value ?? true;
    final queueSize = ref.watch(offlineQueueSizeProvider).value ?? 0;

    if (isOnline && queueSize == 0) {
      return const SizedBox.shrink();
    }

    return Material(
      color: isOnline ? Colors.orange : Colors.red,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                isOnline ? Icons.sync : Icons.cloud_off,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isOnline
                      ? 'Syncing $queueSize items...'
                      : 'Offline - Changes will sync later',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

**This is Part 1 of the System Architecture. Should I continue with:**
- Security & Authentication (detailed implementation)
- Performance Optimization (lazy loading, caching strategies)
- Testing Strategy (unit, widget, integration tests)
- Deployment & CI/CD pipeline

Let me know if you'd like me to continue or if you want me to write this out to the file first!