# AI Health Companion - Complete API Documentation

**Date:** 2026-07-03
**Version:** 1.0
**API Version:** v1
**Platform:** Android (Flutter)
**Architecture:** Real-time AI with streaming responses

---

## Table of Contents

1. [Overview](#1-overview)
2. [Claude API Integration](#2-claude-api-integration)
3. [Firebase APIs](#3-firebase-apis)
4. [Internal APIs/Services](#4-internal-apisservices)
5. [Request/Response Formats](#5-requestresponse-formats)
6. [Error Handling](#6-error-handling)
7. [Rate Limiting](#7-rate-limiting)
8. [API Versioning](#8-api-versioning)
9. [Security](#9-security)
10. [Performance Optimization](#10-performance-optimization)
11. [Testing & Monitoring](#11-testing--monitoring)

---

## 1. Overview

### 1.1 API Architecture

The AI Health Companion uses a hybrid API architecture:

- **Primary AI Backend:** Claude API (Anthropic)
- **Authentication & Storage:** Firebase (Auth, Firestore, Cloud Functions)
- **Local Processing:** Internal services for offline support

```
┌─────────────────────────────────────────────────┐
│              Flutter App (Client)               │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────┐  ┌────────────────────────┐  │
│  │   Internal   │  │   External APIs        │  │
│  │   Services   │  │                        │  │
│  │              │  │  • Claude API          │  │
│  │  • AI Context│  │  • Firebase Auth       │  │
│  │  • Sync Mgr  │  │  • Firestore           │  │
│  │  • Queue Mgr │  │  • Cloud Functions     │  │
│  │  • Biometric │  │                        │  │
│  └──────────────┘  └────────────────────────┘  │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 1.2 Base URLs

| Service | Environment | Base URL |
|---------|-------------|----------|
| Claude API | Production | `https://api.anthropic.com` |
| Firebase Auth | All | `https://identitytoolkit.googleapis.com` |
| Firestore | All | `https://firestore.googleapis.com` |
| Cloud Functions | Production | `https://us-central1-{project-id}.cloudfunctions.net` |

### 1.3 Authentication Flow

All API requests use token-based authentication:

1. User authenticates via Firebase Auth (OTP)
2. Firebase returns ID token
3. Token included in all subsequent requests
4. Claude API key stored securely (never in client code)

---

## 2. Claude API Integration

### 2.1 API Overview

**Provider:** Anthropic
**Documentation:** https://docs.anthropic.com/claude/reference
**Model Used:** `claude-3-5-sonnet-20241022`
**API Version:** `2023-06-01`

### 2.2 Authentication

```dart
// lib/core/network/claude_api_client.dart

class ClaudeApiClient {
  final String _apiKey; // Loaded from secure storage
  final Dio _dio;

  static const String baseUrl = 'https://api.anthropic.com';
  static const String apiVersion = '2023-06-01';

  ClaudeApiClient({
    required String apiKey,
    required Dio dio,
  })  : _apiKey = apiKey,
        _dio = dio {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'x-api-key': _apiKey,
      'anthropic-version': apiVersion,
      'content-type': 'application/json',
    };
  }
}
```

**API Key Management:**
- Stored in Android Keystore via `flutter_secure_storage`
- Never hardcoded in source
- Loaded at app initialization
- Rotated via remote config

### 2.3 Endpoints

#### 2.3.1 Create Message (Non-Streaming)

**Endpoint:** `POST /v1/messages`

**Headers:**
```http
x-api-key: {API_KEY}
anthropic-version: 2023-06-01
content-type: application/json
```

**Request Body:**
```json
{
  "model": "claude-3-5-sonnet-20241022",
  "max_tokens": 1024,
  "system": "You are a health and fitness AI assistant...",
  "messages": [
    {
      "role": "user",
      "content": "I ate chicken curry with rice. How much should I eat?"
    }
  ],
  "temperature": 0.7,
  "top_p": 0.9
}
```

**Response:**
```json
{
  "id": "msg_01XYZ123ABC",
  "type": "message",
  "role": "assistant",
  "content": [
    {
      "type": "text",
      "text": "Based on your profile (target: 1200 cal/day, consumed: 800 cal), I recommend:\n\n• Chicken curry: 1 cup (250ml)\n• Rice: 1/2 cup cooked (90g)\n\nThis provides approximately 350 calories..."
    }
  ],
  "model": "claude-3-5-sonnet-20241022",
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": {
    "input_tokens": 245,
    "output_tokens": 128
  }
}
```

#### 2.3.2 Create Message (Streaming)

**Endpoint:** `POST /v1/messages`

**Headers:**
```http
x-api-key: {API_KEY}
anthropic-version: 2023-06-01
content-type: application/json
accept: text/event-stream
```

**Request Body:**
```json
{
  "model": "claude-3-5-sonnet-20241022",
  "max_tokens": 1024,
  "system": "You are a health and fitness AI assistant...",
  "messages": [
    {
      "role": "user",
      "content": "Suggest a workout for today"
    }
  ],
  "stream": true
}
```

**Response (Server-Sent Events):**
```
event: message_start
data: {"type":"message_start","message":{"id":"msg_01ABC","type":"message","role":"assistant"}}

event: content_block_start
data: {"type":"content_block_start","index":0,"content_block":{"type":"text","text":""}}

event: content_block_delta
data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Great"}}

event: content_block_delta
data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":" choice!"}}

event: content_block_stop
data: {"type":"content_block_stop","index":0}

event: message_delta
data: {"type":"message_delta","delta":{"stop_reason":"end_turn"},"usage":{"output_tokens":156}}

event: message_stop
data: {"type":"message_stop"}
```

**Dart Implementation:**

```dart
// lib/features/chat/data/datasources/claude_remote_datasource.dart

class ClaudeRemoteDataSource {
  final ClaudeApiClient _client;

  /// Send message with streaming response
  Stream<String> sendMessageStream({
    required String userId,
    required List<Message> conversationHistory,
    required String userMessage,
  }) async* {
    try {
      final systemPrompt = await _buildSystemPrompt(userId);

      final response = await _client.dio.post(
        '/v1/messages',
        data: {
          'model': 'claude-3-5-sonnet-20241022',
          'max_tokens': 2048,
          'system': systemPrompt,
          'messages': _buildMessages(conversationHistory, userMessage),
          'stream': true,
          'temperature': 0.7,
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {'accept': 'text/event-stream'},
        ),
      );

      final stream = response.data.stream;

      await for (final chunk in stream) {
        final lines = utf8.decode(chunk).split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data.trim().isEmpty) continue;

            final json = jsonDecode(data);

            if (json['type'] == 'content_block_delta') {
              final text = json['delta']['text'] as String?;
              if (text != null) {
                yield text;
              }
            }
          }
        }
      }
    } catch (e) {
      throw ClaudeApiException('Streaming failed: $e');
    }
  }

  /// Build system prompt with user context
  Future<String> _buildSystemPrompt(String userId) async {
    final context = await _contextBuilder.buildContext(userId);

    return '''
You are Claude, a health and fitness AI companion for a personalized Android app.

User Profile:
- Name: ${context.userName}
- Gender: ${context.gender}
- Age: ${context.age}
- Height: ${context.height} cm
- Current Weight: ${context.currentWeight} kg
- Goal Weight: ${context.goalWeight} kg
- Daily Calorie Target: ${context.dailyCalorieTarget} cal
- Activity Level: ${context.activityLevel}

Today's Progress:
- Calories Consumed: ${context.todayCalories} cal
- Remaining: ${context.remainingCalories} cal
- Meals: ${context.todayMeals.length}
- Workouts: ${context.todayWorkouts.length}

Recent Context:
${context.recentMeals.map((m) => '- ${m.name}: ${m.calories} cal (${m.time})').join('\n')}

Instructions:
1. Be conversational, friendly, and supportive
2. Provide specific, actionable advice
3. Reference their progress and goals
4. Use metric units (kg, cm, cal)
5. Keep responses concise (2-3 paragraphs max)
6. When recommending food portions, use practical measurements (cups, pieces)
7. Celebrate wins and encourage during setbacks
8. Never give medical advice - defer to healthcare professionals

Current time: ${DateTime.now().toIso8601String()}
''';
  }

  /// Build message history for API
  List<Map<String, String>> _buildMessages(
    List<Message> history,
    String newMessage,
  ) {
    final messages = history.map((msg) => {
      'role': msg.role, // 'user' or 'assistant'
      'content': msg.content,
    }).toList();

    messages.add({
      'role': 'user',
      'content': newMessage,
    });

    return messages;
  }
}
```

### 2.4 Use Cases with Examples

#### Use Case 1: Meal Portion Recommendation

**User Input:**
```
"I made chicken curry with rice, how much should I eat?"
```

**System Prompt Context:**
```
Daily Target: 1200 cal
Consumed: 800 cal
Remaining: 400 cal
Last meal: Breakfast at 8:30 AM (350 cal)
```

**Claude Response:**
```
Perfect timing for lunch! Based on your remaining 400 calories today,
I recommend:

• Chicken curry: 1 cup (250ml) - about 200 calories
• Rice: 1/2 cup cooked (90g) - about 110 calories
• Side salad with light dressing - about 50 calories

Total: ~360 calories

This leaves you 40 calories for an evening snack (maybe an apple?).
The protein from chicken will keep you full, and this portion aligns
perfectly with your 55kg goal. How does that sound?
```

**Request:**
```dart
final response = await claudeApi.sendMessageStream(
  userId: 'user123',
  conversationHistory: previousMessages,
  userMessage: 'I made chicken curry with rice, how much should I eat?',
);

// Handle streaming
await for (final chunk in response) {
  // Update UI with each text chunk
  _messageController.addChunk(chunk);
}
```

#### Use Case 2: Workout Suggestion

**User Input:**
```
"Suggest a workout for today"
```

**System Prompt Context:**
```
Activity Level: Lightly Active
Last Workout: Yesterday (30 min walk)
Goal: Weight loss
Available Time: Not specified
```

**Claude Response:**
```
Great to see you staying active! For today, I suggest a
30-minute HIIT workout:

**Warm-up (5 min):**
- Arm circles, leg swings, light jogging in place

**Circuit (20 min) - Repeat 4 times:**
1. Jumping jacks - 30 seconds
2. Bodyweight squats - 30 seconds
3. Push-ups (modified if needed) - 30 seconds
4. Rest - 30 seconds

**Cool down (5 min):**
- Stretching, deep breathing

This burns ~200-250 calories and complements your calorie deficit
perfectly. It's also equipment-free! Ready to try it?
```

#### Use Case 3: Progress Check Conversation

**User Input:**
```
"How am I doing this week?"
```

**System Prompt Context:**
```
Starting Weight: 81 kg
Current Weight: 78.5 kg
Weight Lost: 2.5 kg
Target: 55 kg
Weeks Active: 4
Average Daily Calories: 1180 cal
Compliance: 85%
```

**Claude Response:**
```
You're doing AMAZING! 🎉

**Your Progress:**
✓ Lost 2.5 kg in 4 weeks (healthy rate!)
✓ Averaging 1180 cal/day (right on target)
✓ 85% compliance (that's discipline!)

**What's Working:**
Your consistency is paying off. The gradual weight loss (0.6 kg/week)
is sustainable and healthy.

**Next Week Goal:**
Let's aim for 90% compliance and add one more workout session.
You're 23.5 kg away from your goal - at this pace, you'll reach
55 kg in about 9-10 months. Stay focused, you've got this! 💪

Any challenges you'd like to discuss?
```

#### Use Case 4: Motivational Message

**User Input:**
```
"I overate today, feeling bad"
```

**System Prompt Context:**
```
Today's Calories: 1850 cal (650 over target)
Recent Streak: 12 days under target
Overall Progress: -2.5 kg in 4 weeks
```

**Claude Response:**
```
Hey, don't be too hard on yourself! Here's the reality:

**The Big Picture:**
- You've been under target for 12 straight days (incredible!)
- One day over doesn't erase your 2.5 kg loss
- You're still at a weekly deficit overall

**What Matters:**
It's not about perfection - it's about consistency. Tomorrow is a
fresh start. One day of overeating is normal and human.

**Action Plan:**
1. Don't restrict tomorrow (that leads to cycles)
2. Stick to your normal 1200 cal plan
3. Maybe add a 20-min walk if you feel up to it
4. Drink extra water

You're doing great. This is a tiny bump in a long, successful journey.
Ready to bounce back tomorrow?
```

### 2.5 Token Usage Tracking

```dart
// lib/features/chat/domain/entities/token_usage.dart

class TokenUsage {
  final int inputTokens;
  final int outputTokens;
  final int totalTokens;
  final double estimatedCost;

  TokenUsage({
    required this.inputTokens,
    required this.outputTokens,
  })  : totalTokens = inputTokens + outputTokens,
        estimatedCost = _calculateCost(inputTokens, outputTokens);

  // Claude 3.5 Sonnet pricing (as of 2024)
  static double _calculateCost(int input, int output) {
    const inputCostPer1M = 3.0; // $3 per 1M input tokens
    const outputCostPer1M = 15.0; // $15 per 1M output tokens

    return (input / 1000000 * inputCostPer1M) +
           (output / 1000000 * outputCostPer1M);
  }
}

// Track usage per user per month
class TokenUsageTracker {
  final Database _db;

  Future<void> recordUsage(String userId, TokenUsage usage) async {
    await _db.insert('token_usage', {
      'user_id': userId,
      'input_tokens': usage.inputTokens,
      'output_tokens': usage.outputTokens,
      'cost': usage.estimatedCost,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<MonthlyUsage> getMonthlyUsage(String userId) async {
    final result = await _db.rawQuery('''
      SELECT
        SUM(input_tokens) as total_input,
        SUM(output_tokens) as total_output,
        SUM(cost) as total_cost,
        COUNT(*) as request_count
      FROM token_usage
      WHERE user_id = ?
        AND strftime('%Y-%m', timestamp) = strftime('%Y-%m', 'now')
    ''', [userId]);

    return MonthlyUsage.fromJson(result.first);
  }
}
```

### 2.6 Rate Limits

| Tier | Requests/Minute | Tokens/Minute | Daily Limit |
|------|----------------|---------------|-------------|
| Free | 5 | 100,000 | 500 requests |
| Pro | 50 | 400,000 | Unlimited |

**Client-Side Rate Limiting:**

```dart
// lib/core/network/rate_limiter.dart

class RateLimiter {
  final int maxRequestsPerMinute;
  final Queue<DateTime> _requestTimestamps = Queue();

  RateLimiter({this.maxRequestsPerMinute = 5});

  Future<void> checkLimit() async {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

    // Remove old timestamps
    while (_requestTimestamps.isNotEmpty &&
           _requestTimestamps.first.isBefore(oneMinuteAgo)) {
      _requestTimestamps.removeFirst();
    }

    // Check if limit reached
    if (_requestTimestamps.length >= maxRequestsPerMinute) {
      final oldestRequest = _requestTimestamps.first;
      final waitTime = oldestRequest
          .add(const Duration(minutes: 1))
          .difference(now);

      if (waitTime.isNegative) {
        _requestTimestamps.removeFirst();
      } else {
        throw RateLimitException(
          'Rate limit exceeded. Wait ${waitTime.inSeconds}s',
          waitTime: waitTime,
        );
      }
    }

    _requestTimestamps.add(now);
  }
}
```

### 2.7 Error Handling

**Error Response Format:**

```json
{
  "type": "error",
  "error": {
    "type": "rate_limit_error",
    "message": "Rate limit exceeded"
  }
}
```

**Error Types:**

| Error Type | HTTP Code | Description | Retry Strategy |
|-----------|-----------|-------------|----------------|
| `invalid_request_error` | 400 | Invalid request format | Don't retry |
| `authentication_error` | 401 | Invalid API key | Refresh key |
| `permission_error` | 403 | Insufficient permissions | Don't retry |
| `not_found_error` | 404 | Resource not found | Don't retry |
| `rate_limit_error` | 429 | Rate limit exceeded | Exponential backoff |
| `api_error` | 500 | Server error | Retry with backoff |
| `overloaded_error` | 529 | Service overloaded | Retry with longer backoff |

**Error Handling Implementation:**

```dart
// lib/core/network/claude_error_handler.dart

class ClaudeErrorHandler {
  static Exception handleError(DioException error) {
    if (error.response == null) {
      return NetworkException('No internet connection');
    }

    final statusCode = error.response!.statusCode;
    final data = error.response!.data;

    switch (statusCode) {
      case 400:
        return InvalidRequestException(data['error']['message']);

      case 401:
        return AuthenticationException('Invalid API key');

      case 429:
        final retryAfter = error.response!.headers['retry-after']?.first;
        return RateLimitException(
          'Rate limit exceeded',
          retryAfter: retryAfter != null ? int.parse(retryAfter) : null,
        );

      case 500:
      case 529:
        return ServerException(data['error']['message']);

      default:
        return UnknownException('Unexpected error: $statusCode');
    }
  }
}
```

### 2.8 Retry Logic with Exponential Backoff

```dart
// lib/core/network/retry_interceptor.dart

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    var retryCount = 0;
    var delay = initialDelay;

    while (retryCount < maxRetries) {
      retryCount++;

      // Wait with exponential backoff + jitter
      final jitter = Random().nextInt(1000);
      await Future.delayed(delay + Duration(milliseconds: jitter));

      try {
        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        if (retryCount >= maxRetries) {
          return handler.next(err);
        }

        // Exponential backoff
        delay *= 2;
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException error) {
    final statusCode = error.response?.statusCode;

    // Retry on network errors and specific status codes
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           statusCode == 429 || // Rate limit
           statusCode == 500 || // Server error
           statusCode == 502 || // Bad gateway
           statusCode == 503 || // Service unavailable
           statusCode == 529;   // Overloaded
  }
}
```

### 2.9 Circuit Breaker Pattern

```dart
// lib/core/network/circuit_breaker.dart

enum CircuitState { closed, open, halfOpen }

class CircuitBreaker {
  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;

  final int failureThreshold;
  final Duration timeout;
  final Duration resetTimeout;

  CircuitBreaker({
    this.failureThreshold = 5,
    this.timeout = const Duration(seconds: 10),
    this.resetTimeout = const Duration(minutes: 1),
  });

  Future<T> execute<T>(Future<T> Function() operation) async {
    // Check if circuit should reset to half-open
    if (_state == CircuitState.open && _shouldAttemptReset()) {
      _state = CircuitState.halfOpen;
    }

    // If circuit is open, fail fast
    if (_state == CircuitState.open) {
      throw CircuitBreakerOpenException(
        'Circuit breaker is open. Service unavailable.',
      );
    }

    try {
      final result = await operation().timeout(timeout);
      _onSuccess();
      return result;
    } catch (e) {
      _onFailure();
      rethrow;
    }
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

  bool _shouldAttemptReset() {
    if (_lastFailureTime == null) return false;

    return DateTime.now().difference(_lastFailureTime!) > resetTimeout;
  }
}

// Usage in datasource
class ClaudeRemoteDataSource {
  final CircuitBreaker _circuitBreaker;

  Future<MessageResponse> sendMessage(String message) async {
    return _circuitBreaker.execute(() async {
      final response = await _client.dio.post('/v1/messages', data: {
        'model': 'claude-3-5-sonnet-20241022',
        'messages': [{'role': 'user', 'content': message}],
      });

      return MessageResponse.fromJson(response.data);
    });
  }
}
```

---

## 3. Firebase APIs

### 3.1 Firebase Authentication

#### 3.1.1 Sign In with Email (OTP)

**Endpoint:** `POST https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode`

**Request:**
```json
{
  "requestType": "EMAIL_SIGNIN",
  "email": "user@example.com",
  "continueUrl": "https://aihealth.companion/finishSignIn",
  "canHandleCodeInApp": true
}
```

**Response:**
```json
{
  "kind": "identitytoolkit#GetOobConfirmationCodeResponse",
  "email": "user@example.com"
}
```

**Dart Implementation:**

```dart
// lib/features/auth/data/datasources/auth_remote_datasource.dart

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  Future<String> signInWithEmail(String email) async {
    try {
      await _firebaseAuth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://aihealth.companion/finishSignIn?email=$email',
          handleCodeInApp: true,
          androidPackageName: 'com.aihealth.companion',
          androidInstallApp: true,
          androidMinimumVersion: '1',
        ),
      );

      // Save email locally to complete sign-in
      await Hive.box('auth').put('pending_email', email);

      return 'OTP_SENT';
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserModel> verifyEmailLink(String emailLink) async {
    try {
      final email = Hive.box('auth').get('pending_email') as String;

      final userCredential = await _firebaseAuth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );

      final userId = userCredential.user!.uid;

      // Check if profile exists
      final profileDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!profileDoc.exists) {
        throw OnboardingRequiredException();
      }

      return UserModel.fromFirestore(profileDoc);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
}
```

#### 3.1.2 Sign In with Phone (OTP)

**Endpoint:** Firebase SDK handles internally

**Request Flow:**
```
1. verifyPhoneNumber() → Send OTP
2. User enters OTP code
3. signInWithCredential() → Verify & sign in
```

**Dart Implementation:**

```dart
Future<String> signInWithPhone(String phoneNumber) async {
  final completer = Completer<String>();

  await _firebaseAuth.verifyPhoneNumber(
    phoneNumber: phoneNumber, // Format: +91XXXXXXXXXX
    timeout: const Duration(seconds: 60),

    verificationCompleted: (PhoneAuthCredential credential) async {
      // Auto-verification (rare on Android)
      await _firebaseAuth.signInWithCredential(credential);
      completer.complete('AUTO_VERIFIED');
    },

    verificationFailed: (FirebaseAuthException e) {
      completer.completeError(_handleAuthException(e));
    },

    codeSent: (String verificationId, int? resendToken) {
      // Save verification ID for later use
      Hive.box('auth').put('verification_id', verificationId);
      completer.complete(verificationId);
    },

    codeAutoRetrievalTimeout: (String verificationId) {
      // Timeout - user must enter code manually
    },
  );

  return completer.future;
}

Future<UserModel> verifyOTP(String verificationId, String otpCode) async {
  try {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);

    final userId = userCredential.user!.uid;
    final profileDoc = await _firestore.collection('users').doc(userId).get();

    if (!profileDoc.exists) {
      throw OnboardingRequiredException();
    }

    return UserModel.fromFirestore(profileDoc);
  } on FirebaseAuthException catch (e) {
    throw _handleAuthException(e);
  }
}
```

#### 3.1.3 Token Refresh

**Firebase automatically refreshes tokens**, but you can force refresh:

```dart
Future<String> refreshToken() async {
  final user = _firebaseAuth.currentUser;
  if (user == null) throw UnauthorizedException('No user logged in');

  final idToken = await user.getIdToken(true); // Force refresh

  return idToken!;
}
```

#### 3.1.4 Sign Out

```dart
Future<void> signOut() async {
  await _firebaseAuth.signOut();
  await Hive.box('auth').clear();
  await _secureStorage.delete(key: 'auth_tokens');
}
```

### 3.2 Cloud Firestore

#### 3.2.1 Collections Structure

```
users/
  {userId}/
    - profile data
    - settings

meals/
  {mealId}/
    - user_id
    - meal data
    - sync metadata

workouts/
  {workoutId}/
    - user_id
    - workout data
    - sync metadata

chat_messages/
  {messageId}/
    - user_id
    - conversation_id
    - message data
    - sync metadata
```

#### 3.2.2 Query Patterns

**Get User Profile:**

```dart
Future<UserModel> getUserProfile(String userId) async {
  final doc = await _firestore.collection('users').doc(userId).get();

  if (!doc.exists) {
    throw NotFoundException('User profile not found');
  }

  return UserModel.fromFirestore(doc);
}
```

**Get Today's Meals (with pagination):**

```dart
Future<List<MealModel>> getTodayMeals({
  required String userId,
  DocumentSnapshot? lastDocument,
  int limit = 20,
}) async {
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  var query = _firestore
      .collection('meals')
      .where('user_id', isEqualTo: userId)
      .where('consumed_at', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
      .where('consumed_at', isLessThan: endOfDay.toIso8601String())
      .where('is_deleted', isEqualTo: false)
      .orderBy('consumed_at', descending: true)
      .limit(limit);

  if (lastDocument != null) {
    query = query.startAfterDocument(lastDocument);
  }

  final snapshot = await query.get();

  return snapshot.docs
      .map((doc) => MealModel.fromFirestore(doc))
      .toList();
}
```

**Real-time Listener (Sync Updates):**

```dart
Stream<List<MealModel>> watchTodayMeals(String userId) {
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return _firestore
      .collection('meals')
      .where('user_id', isEqualTo: userId)
      .where('consumed_at', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
      .where('consumed_at', isLessThan: endOfDay.toIso8601String())
      .where('is_deleted', isEqualTo: false)
      .orderBy('consumed_at', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => MealModel.fromFirestore(doc))
          .toList());
}
```

#### 3.2.3 Batch Operations

```dart
Future<void> syncBatchMeals(List<MealModel> meals) async {
  final batch = _firestore.batch();

  for (final meal in meals) {
    final docRef = _firestore.collection('meals').doc(meal.id);
    batch.set(docRef, meal.toJson(), SetOptions(merge: true));
  }

  await batch.commit();
}
```

#### 3.2.4 Security Rules

```javascript
// firestore.rules

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Users collection
    match /users/{userId} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId);
    }

    // Meals collection
    match /meals/{mealId} {
      allow read: if isOwner(resource.data.user_id);
      allow create: if isAuthenticated() && isOwner(request.resource.data.user_id);
      allow update: if isOwner(resource.data.user_id);
      allow delete: if isOwner(resource.data.user_id);
    }

    // Workouts collection
    match /workouts/{workoutId} {
      allow read: if isOwner(resource.data.user_id);
      allow create: if isAuthenticated() && isOwner(request.resource.data.user_id);
      allow update: if isOwner(resource.data.user_id);
      allow delete: if isOwner(resource.data.user_id);
    }

    // Chat messages collection
    match /chat_messages/{messageId} {
      allow read: if isOwner(resource.data.user_id);
      allow create: if isAuthenticated() && isOwner(request.resource.data.user_id);
      allow update: if isOwner(resource.data.user_id);
      allow delete: if isOwner(resource.data.user_id);
    }
  }
}
```

### 3.3 Cloud Functions

#### 3.3.1 Scheduled Daily Summary

**Endpoint:** Triggered by Cloud Scheduler

```javascript
// functions/src/scheduled/dailySummary.ts

export const dailySummary = functions.pubsub
  .schedule('0 21 * * *') // 9 PM daily
  .timeZone('Asia/Kolkata')
  .onRun(async (context) => {
    const usersSnapshot = await admin.firestore()
      .collection('users')
      .where('notifications_enabled', '==', true)
      .get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;

      // Calculate daily stats
      const stats = await calculateDailyStats(userId);

      // Send notification
      await sendPushNotification(userId, {
        title: 'Daily Summary',
        body: `Today: ${stats.caloriesConsumed}/${stats.calorieTarget} cal. ${stats.workouts} workouts completed!`,
      });

      // Log summary to Firestore
      await admin.firestore()
        .collection('daily_summaries')
        .doc(`${userId}_${new Date().toISOString().split('T')[0]}`)
        .set(stats);
    }
  });
```

#### 3.3.2 HTTP Endpoint: Generate AI Context

**Endpoint:** `POST /generateContext`

```javascript
// functions/src/http/generateContext.ts

export const generateContext = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const userId = context.auth.uid;

  // Fetch user data
  const userDoc = await admin.firestore()
    .collection('users')
    .doc(userId)
    .get();

  const userData = userDoc.data();

  // Fetch recent meals
  const mealsSnapshot = await admin.firestore()
    .collection('meals')
    .where('user_id', '==', userId)
    .orderBy('consumed_at', 'desc')
    .limit(10)
    .get();

  const meals = mealsSnapshot.docs.map(doc => doc.data());

  // Fetch recent workouts
  const workoutsSnapshot = await admin.firestore()
    .collection('workouts')
    .where('user_id', '==', userId)
    .orderBy('completed_at', 'desc')
    .limit(5)
    .get();

  const workouts = workoutsSnapshot.docs.map(doc => doc.data());

  // Build context object
  return {
    user: userData,
    recentMeals: meals,
    recentWorkouts: workouts,
    todayStats: await calculateTodayStats(userId),
  };
});
```

**Dart Client:**

```dart
Future<AIContext> generateContext(String userId) async {
  final callable = FirebaseFunctions.instance.httpsCallable('generateContext');

  try {
    final result = await callable.call();
    return AIContext.fromJson(result.data);
  } catch (e) {
    throw CloudFunctionException('Failed to generate context: $e');
  }
}
```

---

## 4. Internal APIs/Services

### 4.1 AI Context Builder Service

**Purpose:** Build rich context for Claude API from local + cloud data

```dart
// lib/services/ai/ai_context_builder.dart

class AIContextBuilder {
  final MealRepository _mealRepository;
  final WorkoutRepository _workoutRepository;
  final UserRepository _userRepository;

  Future<AIContext> buildContext(String userId) async {
    final user = await _userRepository.getUserProfile(userId);

    // Today's data
    final todayMeals = await _mealRepository.getTodayMeals(userId);
    final todayWorkouts = await _workoutRepository.getTodayWorkouts(userId);

    // Recent history (last 7 days)
    final recentMeals = await _mealRepository.getRecentMeals(
      userId: userId,
      days: 7,
    );

    // Calculate aggregates
    final todayCalories = todayMeals.fold<double>(
      0,
      (sum, meal) => sum + meal.calories,
    );

    return AIContext(
      userName: user.name,
      gender: user.gender,
      age: user.age,
      height: user.height,
      currentWeight: user.currentWeight,
      goalWeight: user.goalWeight,
      dailyCalorieTarget: user.dailyCalorieTarget,
      activityLevel: user.activityLevel,
      todayCalories: todayCalories,
      remainingCalories: (user.dailyCalorieTarget - todayCalories).clamp(0, double.infinity),
      todayMeals: todayMeals,
      todayWorkouts: todayWorkouts,
      recentMeals: recentMeals,
      weeklyProgress: await _calculateWeeklyProgress(userId),
    );
  }

  Future<WeeklyProgress> _calculateWeeklyProgress(String userId) async {
    final meals = await _mealRepository.getRecentMeals(
      userId: userId,
      days: 7,
    );

    final workouts = await _workoutRepository.getRecentWorkouts(
      userId: userId,
      days: 7,
    );

    return WeeklyProgress(
      totalCalories: meals.fold(0.0, (sum, m) => sum + m.calories),
      avgDailyCalories: meals.fold(0.0, (sum, m) => sum + m.calories) / 7,
      totalWorkouts: workouts.length,
      complianceDays: _calculateComplianceDays(meals),
    );
  }
}
```

### 4.2 Sync Manager Service

**Purpose:** Handle bidirectional sync between local SQLite and Firestore

```dart
// lib/services/sync/sync_manager.dart

class SyncManager {
  final Database _localDb;
  final FirebaseFirestore _firestore;
  final ConnectivityService _connectivity;

  SyncStatus _status = SyncStatus.idle;
  DateTime? _lastSyncTime;

  /// Start continuous sync
  void startSync(String userId) {
    Timer.periodic(const Duration(minutes: 5), (_) async {
      if (await _connectivity.isConnected) {
        await syncAll(userId);
      }
    });
  }

  /// Sync all data types
  Future<void> syncAll(String userId) async {
    if (_status == SyncStatus.syncing) return;

    _status = SyncStatus.syncing;

    try {
      await Future.wait([
        _syncMeals(userId),
        _syncWorkouts(userId),
        _syncChatMessages(userId),
        _syncUserProfile(userId),
      ]);

      _lastSyncTime = DateTime.now();
      _status = SyncStatus.success;
    } catch (e) {
      _status = SyncStatus.error;
      rethrow;
    }
  }

  /// Sync meals (bidirectional)
  Future<void> _syncMeals(String userId) async {
    // 1. Push local changes to cloud
    final pendingMeals = await _localDb.query(
      'meals',
      where: 'user_id = ? AND sync_status = ?',
      whereArgs: [userId, 'pending'],
    );

    for (final mealJson in pendingMeals) {
      try {
        await _firestore
            .collection('meals')
            .doc(mealJson['id'] as String)
            .set(mealJson, SetOptions(merge: true));

        // Mark as synced
        await _localDb.update(
          'meals',
          {'sync_status': 'synced', 'synced_at': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [mealJson['id']],
        );
      } catch (e) {
        // Log error but continue
      }
    }

    // 2. Pull cloud changes to local
    final lastSync = _lastSyncTime ?? DateTime(2020);

    final snapshot = await _firestore
        .collection('meals')
        .where('user_id', isEqualTo: userId)
        .where('updated_at', isGreaterThan: lastSync.toIso8601String())
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      // Conflict resolution: server wins
      await _localDb.insert(
        'meals',
        {
          ...data,
          'sync_status': 'synced',
          'synced_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Similar methods for workouts, messages, profile...
}

enum SyncStatus { idle, syncing, success, error }
```

### 4.3 Offline Queue Manager

**Purpose:** Queue operations when offline, execute when online

```dart
// lib/services/offline/offline_queue_manager.dart

class OfflineQueueManager {
  final Box<QueuedOperation> _queue;
  final ConnectivityService _connectivity;

  /// Add operation to queue
  Future<void> enqueue(QueuedOperation operation) async {
    await _queue.add(operation);
  }

  /// Process queue when online
  Future<void> processQueue() async {
    if (!await _connectivity.isConnected) return;

    final operations = _queue.values.toList();

    for (final operation in operations) {
      try {
        await _executeOperation(operation);

        // Remove from queue on success
        await operation.delete();
      } catch (e) {
        // Keep in queue, will retry later
        operation.retryCount++;

        if (operation.retryCount > 5) {
          // Max retries reached, mark as failed
          operation.status = OperationStatus.failed;
        }

        await operation.save();
      }
    }
  }

  Future<void> _executeOperation(QueuedOperation operation) async {
    switch (operation.type) {
      case OperationType.createMeal:
        final meal = MealModel.fromJson(operation.payload);
        await _mealRepository.createMeal(meal);
        break;

      case OperationType.updateMeal:
        final meal = MealModel.fromJson(operation.payload);
        await _mealRepository.updateMeal(meal);
        break;

      case OperationType.deleteMeal:
        await _mealRepository.deleteMeal(operation.payload['id']);
        break;

      case OperationType.sendMessage:
        final message = Message.fromJson(operation.payload);
        await _chatRepository.sendMessage(message);
        break;
    }
  }
}

@HiveType(typeId: 10)
class QueuedOperation extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late OperationType type;

  @HiveField(2)
  late Map<String, dynamic> payload;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  int retryCount = 0;

  @HiveField(5)
  OperationStatus status = OperationStatus.pending;
}

enum OperationType {
  createMeal,
  updateMeal,
  deleteMeal,
  createWorkout,
  sendMessage,
}

enum OperationStatus { pending, processing, success, failed }
```

### 4.4 Notification Service

**Purpose:** Local and push notifications

```dart
// lib/services/notification/notification_service.dart

class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseMessaging _firebaseMessaging;

  Future<void> initialize() async {
    // Request permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    await _saveFCMToken(token!);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Schedule daily reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    await _localNotifications.zonedSchedule(
      0,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          channelDescription: 'Daily health reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Show instant notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notifications',
          'Instant Notifications',
          channelDescription: 'Instant app notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: payload,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  void _handleForegroundMessage(RemoteMessage message) {
    showNotification(
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigate based on notification type
    final type = message.data['type'];

    switch (type) {
      case 'meal_reminder':
        // Navigate to meal logging
        break;
      case 'workout_reminder':
        // Navigate to workout screen
        break;
      case 'daily_summary':
        // Navigate to progress screen
        break;
    }
  }
}
```

### 4.5 Biometric Authentication Service

```dart
// lib/services/auth/biometric_service.dart

class BiometricService {
  final LocalAuthentication _localAuth;
  final SecureStorageService _secureStorage;

  /// Check availability
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get available types (fingerprint, face)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _localAuth.getAvailableBiometrics();
  }

  /// Authenticate
  Future<bool> authenticate({
    String reason = 'Authenticate to access AI Health Companion',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          sensitiveTransaction: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        throw BiometricNotAvailableException();
      } else if (e.code == 'LockedOut') {
        throw BiometricLockedOutException();
      } else if (e.code == 'PermanentlyLockedOut') {
        throw BiometricPermanentlyLockedOutException();
      }
      return false;
    }
  }

  /// Enable for user
  Future<void> enableBiometric() async {
    final isAvailable = await isBiometricAvailable();
    if (!isAvailable) {
      throw BiometricNotAvailableException();
    }

    final authenticated = await authenticate(
      reason: 'Enable biometric login',
    );

    if (!authenticated) {
      throw BiometricAuthenticationFailedException();
    }

    await _secureStorage.write(
      key: 'biometric_enabled',
      value: 'true',
    );
  }

  /// Disable
  Future<void> disableBiometric() async {
    await _secureStorage.delete(key: 'biometric_enabled');
  }

  /// Check if enabled
  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: 'biometric_enabled');
    return value == 'true';
  }
}
```

---

## 5. Request/Response Formats

### 5.1 Standard Response Envelope

All API responses follow this format:

**Success Response:**
```json
{
  "success": true,
  "data": {
    // Response payload
  },
  "timestamp": "2026-07-03T10:30:00Z",
  "version": "v1"
}
```

**Error Response:**
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Try again in 60 seconds.",
    "details": {
      "retryAfter": 60,
      "limit": 5,
      "remaining": 0
    }
  },
  "timestamp": "2026-07-03T10:30:00Z",
  "version": "v1"
}
```

### 5.2 Entity Schemas

#### 5.2.1 User Profile

```json
{
  "id": "user123",
  "email": "user@example.com",
  "phone": "+919876543210",
  "name": "Priya Sharma",
  "gender": "female",
  "age": 32,
  "height": 153,
  "currentWeight": 78.5,
  "goalWeight": 55.0,
  "startingWeight": 81.0,
  "activityLevel": "lightly_active",
  "dailyCalorieTarget": 1200,
  "createdAt": "2026-06-01T08:00:00Z",
  "updatedAt": "2026-07-03T10:30:00Z",
  "preferences": {
    "theme": "light",
    "notificationsEnabled": true,
    "biometricEnabled": false,
    "language": "en"
  }
}
```

#### 5.2.2 Meal

```json
{
  "id": "meal_abc123",
  "userId": "user123",
  "name": "Chicken Curry with Rice",
  "calories": 350,
  "protein": 25.5,
  "carbs": 40.0,
  "fats": 8.5,
  "fiber": 3.0,
  "consumedAt": "2026-07-03T13:30:00Z",
  "mealType": "lunch",
  "portionSize": "1 cup curry + 0.5 cup rice",
  "imageUrl": "https://storage.googleapis.com/...",
  "notes": "Homemade, less oil",
  "isDeleted": false,
  "createdAt": "2026-07-03T13:35:00Z",
  "updatedAt": "2026-07-03T13:35:00Z",
  "syncStatus": "synced",
  "syncedAt": "2026-07-03T13:36:00Z"
}
```

#### 5.2.3 Workout

```json
{
  "id": "workout_xyz789",
  "userId": "user123",
  "type": "cardio",
  "name": "Morning Jog",
  "duration": 30,
  "caloriesBurned": 250,
  "intensity": "moderate",
  "completedAt": "2026-07-03T07:00:00Z",
  "notes": "Felt great!",
  "isDeleted": false,
  "createdAt": "2026-07-03T07:35:00Z",
  "updatedAt": "2026-07-03T07:35:00Z",
  "syncStatus": "synced",
  "syncedAt": "2026-07-03T07:36:00Z"
}
```

#### 5.2.4 Chat Message

```json
{
  "id": "msg_def456",
  "userId": "user123",
  "conversationId": "conv_123",
  "role": "assistant",
  "content": "Based on your progress, you're doing great! Keep it up.",
  "timestamp": "2026-07-03T14:20:00Z",
  "tokenUsage": {
    "inputTokens": 245,
    "outputTokens": 128,
    "totalTokens": 373
  },
  "isDeleted": false,
  "createdAt": "2026-07-03T14:20:00Z",
  "syncStatus": "synced",
  "syncedAt": "2026-07-03T14:21:00Z"
}
```

### 5.3 Pagination Format

**Request:**
```json
{
  "page": 1,
  "limit": 20,
  "sortBy": "consumed_at",
  "sortOrder": "desc"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "items": [...],
    "pagination": {
      "page": 1,
      "limit": 20,
      "totalItems": 156,
      "totalPages": 8,
      "hasNext": true,
      "hasPrevious": false
    }
  }
}
```

---

## 6. Error Handling

### 6.1 Standard Error Codes

| Code | HTTP Status | Description | Client Action |
|------|-------------|-------------|---------------|
| `AUTHENTICATION_FAILED` | 401 | Invalid credentials | Redirect to login |
| `UNAUTHORIZED` | 401 | Token expired/invalid | Refresh token, retry |
| `FORBIDDEN` | 403 | Insufficient permissions | Show error, no retry |
| `NOT_FOUND` | 404 | Resource not found | Show error, no retry |
| `VALIDATION_ERROR` | 400 | Invalid request data | Fix request, retry |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests | Wait & retry |
| `SERVER_ERROR` | 500 | Internal server error | Retry with backoff |
| `SERVICE_UNAVAILABLE` | 503 | Service down | Retry with backoff |
| `NETWORK_ERROR` | - | No internet | Queue offline, notify user |
| `TIMEOUT` | 408 | Request timeout | Retry with backoff |

### 6.2 Error Response Structure

```dart
// lib/core/errors/api_error.dart

class ApiError {
  final String code;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;
  final DateTime timestamp;

  ApiError({
    required this.code,
    required this.message,
    this.statusCode,
    this.details,
  }) : timestamp = DateTime.now();

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String,
      message: json['message'] as String,
      statusCode: json['statusCode'] as int?,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'statusCode': statusCode,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
```

### 6.3 Client-Side Error Handling

```dart
// lib/core/network/error_handler.dart

class ErrorHandler {
  static Exception handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is FirebaseException) {
      return _handleFirebaseError(error);
    } else {
      return UnknownException(error.toString());
    }
  }

  static Exception _handleDioError(DioException error) {
    if (error.response == null) {
      return NetworkException('No internet connection');
    }

    final statusCode = error.response!.statusCode;
    final data = error.response!.data;

    switch (statusCode) {
      case 400:
        return ValidationException(
          data['error']?['message'] ?? 'Invalid request',
        );

      case 401:
        return UnauthorizedException(
          data['error']?['message'] ?? 'Unauthorized',
        );

      case 403:
        return ForbiddenException(
          data['error']?['message'] ?? 'Forbidden',
        );

      case 404:
        return NotFoundException(
          data['error']?['message'] ?? 'Not found',
        );

      case 429:
        final retryAfter = data['error']?['details']?['retryAfter'] as int?;
        return RateLimitException(
          'Rate limit exceeded',
          retryAfter: retryAfter,
        );

      case 500:
      case 502:
      case 503:
        return ServerException(
          data['error']?['message'] ?? 'Server error',
        );

      default:
        return UnknownException('HTTP $statusCode');
    }
  }

  static Exception _handleFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return ForbiddenException('Permission denied');

      case 'not-found':
        return NotFoundException('Document not found');

      case 'already-exists':
        return ConflictException('Document already exists');

      case 'unauthenticated':
        return UnauthorizedException('Not authenticated');

      default:
        return ServerException('Firebase error: ${error.message}');
    }
  }
}
```

### 6.4 Retry Policies

```dart
// lib/core/network/retry_policy.dart

class RetryPolicy {
  static const defaultMaxRetries = 3;
  static const defaultInitialDelay = Duration(seconds: 1);

  static Future<T> execute<T>({
    required Future<T> Function() operation,
    int maxRetries = defaultMaxRetries,
    Duration initialDelay = defaultInitialDelay,
    bool Function(Exception)? shouldRetry,
  }) async {
    var attempt = 0;
    var delay = initialDelay;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;

        if (attempt >= maxRetries) {
          rethrow;
        }

        if (shouldRetry != null && e is Exception && !shouldRetry(e)) {
          rethrow;
        }

        // Exponential backoff with jitter
        final jitter = Random().nextInt(500);
        await Future.delayed(delay + Duration(milliseconds: jitter));

        delay *= 2;
      }
    }
  }

  static bool shouldRetryError(Exception error) {
    return error is NetworkException ||
           error is TimeoutException ||
           error is RateLimitException ||
           error is ServerException;
  }
}
```

---

## 7. Rate Limiting

### 7.1 Claude API Rate Limits

| Tier | Requests/Min | Tokens/Min | Daily Limit |
|------|-------------|------------|-------------|
| Free | 5 | 100,000 | 500 requests |
| Pro | 50 | 400,000 | Unlimited |
| Enterprise | Custom | Custom | Unlimited |

### 7.2 Firebase Rate Limits

| Service | Limit | Notes |
|---------|-------|-------|
| Firestore Reads | 50,000/day (free) | Per project |
| Firestore Writes | 20,000/day (free) | Per project |
| Auth Sign-ins | 10,000/day (free) | Per project |
| Cloud Functions | 2M invocations/month | Free tier |

### 7.3 Client-Side Throttling

```dart
// lib/core/network/throttler.dart

class Throttler {
  final Duration minimumInterval;
  DateTime? _lastCallTime;

  Throttler({this.minimumInterval = const Duration(milliseconds: 500)});

  Future<T> throttle<T>(Future<T> Function() operation) async {
    final now = DateTime.now();

    if (_lastCallTime != null) {
      final elapsed = now.difference(_lastCallTime!);

      if (elapsed < minimumInterval) {
        await Future.delayed(minimumInterval - elapsed);
      }
    }

    _lastCallTime = DateTime.now();
    return await operation();
  }
}

// Usage: Throttle chat input
class ChatInputThrottler {
  final _throttler = Throttler(minimumInterval: Duration(seconds: 2));

  Future<void> sendMessage(String message) async {
    await _throttler.throttle(() async {
      await _chatRepository.sendMessage(message);
    });
  }
}
```

### 7.4 Backoff Strategies

```dart
// lib/core/network/backoff_strategy.dart

abstract class BackoffStrategy {
  Duration getDelay(int attemptNumber);
}

class ExponentialBackoff implements BackoffStrategy {
  final Duration initialDelay;
  final double multiplier;
  final Duration maxDelay;

  ExponentialBackoff({
    this.initialDelay = const Duration(seconds: 1),
    this.multiplier = 2.0,
    this.maxDelay = const Duration(seconds: 60),
  });

  @override
  Duration getDelay(int attemptNumber) {
    var delay = initialDelay * pow(multiplier, attemptNumber - 1);

    if (delay > maxDelay) {
      delay = maxDelay;
    }

    // Add jitter (±25%)
    final jitterRange = delay ~/ 4;
    final jitter = Random().nextInt(jitterRange * 2) - jitterRange;

    return delay + Duration(milliseconds: jitter);
  }
}

class LinearBackoff implements BackoffStrategy {
  final Duration increment;
  final Duration maxDelay;

  LinearBackoff({
    this.increment = const Duration(seconds: 5),
    this.maxDelay = const Duration(seconds: 60),
  });

  @override
  Duration getDelay(int attemptNumber) {
    var delay = increment * attemptNumber;

    if (delay > maxDelay) {
      delay = maxDelay;
    }

    return delay;
  }
}
```

---

## 8. API Versioning

### 8.1 Current Version

**Version:** v1
**Release Date:** 2026-07-03
**Status:** Stable

### 8.2 Version Header

All API requests include version header:

```http
API-Version: v1
```

### 8.3 Future Versioning Strategy

**URL-Based Versioning:**
```
/v1/messages
/v2/messages
```

**Header-Based Versioning:**
```http
Accept: application/vnd.aihealth.v1+json
```

### 8.4 Backward Compatibility

**Breaking Changes Policy:**
- Major version bump (v1 → v2) for breaking changes
- Minimum 6 months deprecation period
- Clear migration guide provided
- Old version supported for 12 months

**Non-Breaking Changes:**
- Adding optional fields
- Adding new endpoints
- Performance improvements
- Bug fixes

### 8.5 Deprecation Process

```dart
// lib/core/api/deprecated_api.dart

@Deprecated('Use newMethod() instead. Will be removed in v2.0')
void oldMethod() {
  // Old implementation
}

void newMethod() {
  // New implementation
}
```

---

## 9. Security

### 9.1 API Key Storage

**Never store API keys in:**
- Source code
- Version control
- Shared preferences
- Local storage
- APK resources

**Secure storage location:**

```dart
// lib/core/security/api_key_manager.dart

class ApiKeyManager {
  final FlutterSecureStorage _secureStorage;

  Future<String?> getClaudeApiKey() async {
    return await _secureStorage.read(key: 'claude_api_key');
  }

  Future<void> saveClaudeApiKey(String apiKey) async {
    await _secureStorage.write(
      key: 'claude_api_key',
      value: apiKey,
    );
  }

  Future<void> deleteClaudeApiKey() async {
    await _secureStorage.delete(key: 'claude_api_key');
  }
}
```

**API key initialization:**

```dart
// Load from Firebase Remote Config or secure backend
Future<void> initializeApiKey() async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.fetchAndActivate();

  final encryptedKey = remoteConfig.getString('claude_api_key_encrypted');
  final apiKey = _decrypt(encryptedKey);

  await _apiKeyManager.saveClaudeApiKey(apiKey);
}
```

### 9.2 Request Signing (Future Enhancement)

```dart
// lib/core/security/request_signer.dart

class RequestSigner {
  final String _secretKey;

  String signRequest({
    required String method,
    required String path,
    required Map<String, dynamic> body,
    required DateTime timestamp,
  }) {
    final payload = '$method$path${jsonEncode(body)}${timestamp.millisecondsSinceEpoch}';

    final hmac = Hmac(sha256, utf8.encode(_secretKey));
    final digest = hmac.convert(utf8.encode(payload));

    return base64.encode(digest.bytes);
  }

  bool verifySignature({
    required String signature,
    required String method,
    required String path,
    required Map<String, dynamic> body,
    required DateTime timestamp,
  }) {
    final expectedSignature = signRequest(
      method: method,
      path: path,
      body: body,
      timestamp: timestamp,
    );

    return signature == expectedSignature;
  }
}
```

### 9.3 HTTPS Requirements

**All API calls must use HTTPS:**

```dart
// lib/core/network/http_client_factory.dart

class HttpClientFactory {
  static Dio create() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => status != null && status < 500,
    ));

    // Enforce HTTPS
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (!options.uri.scheme.startsWith('https')) {
          throw InsecureConnectionException(
            'Only HTTPS connections are allowed',
          );
        }
        handler.next(options);
      },
    ));

    // Add certificate pinning (production)
    if (kReleaseMode) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) => false;
          return client;
        },
      );
    }

    return dio;
  }
}
```

### 9.4 Token Expiration

**Firebase tokens expire after 1 hour:**

```dart
// lib/services/auth/token_manager.dart

class TokenManager {
  final FirebaseAuth _auth;

  Future<String> getValidToken() async {
    final user = _auth.currentUser;
    if (user == null) throw UnauthorizedException('No user');

    final idTokenResult = await user.getIdTokenResult();

    // Check expiration (refresh 5 minutes before expiry)
    final expiryTime = idTokenResult.expirationTime!;
    final now = DateTime.now();

    if (expiryTime.difference(now) < Duration(minutes: 5)) {
      // Force refresh
      await user.getIdToken(true);
    }

    return await user.getIdToken() ?? '';
  }
}
```

---

## 10. Performance Optimization

### 10.1 Caching Strategy

```dart
// lib/core/cache/cache_manager.dart

class CacheManager {
  final Box _cache;

  Future<T?> get<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? maxAge,
  }) async {
    final cached = _cache.get(key);
    if (cached == null) return null;

    final data = cached as Map<String, dynamic>;
    final timestamp = DateTime.parse(data['timestamp'] as String);

    // Check if expired
    if (maxAge != null && DateTime.now().difference(timestamp) > maxAge) {
      await _cache.delete(key);
      return null;
    }

    return fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> set({
    required String key,
    required Map<String, dynamic> data,
  }) async {
    await _cache.put(key, {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> clear() async {
    await _cache.clear();
  }
}

// Usage
final cachedProfile = await _cacheManager.get<UserModel>(
  key: 'user_profile_$userId',
  fromJson: UserModel.fromJson,
  maxAge: Duration(hours: 1),
);

if (cachedProfile != null) {
  return cachedProfile;
}

// Fetch from API
final profile = await _api.getUserProfile(userId);

// Cache for next time
await _cacheManager.set(
  key: 'user_profile_$userId',
  data: profile.toJson(),
);
```

### 10.2 Request Compression

```dart
// Enable gzip compression
dio.options.headers['Accept-Encoding'] = 'gzip, deflate';

// Interceptor to decompress
dio.interceptors.add(InterceptorsWrapper(
  onResponse: (response, handler) {
    if (response.headers['content-encoding']?.contains('gzip') ?? false) {
      response.data = gzip.decode(response.data as List<int>);
    }
    handler.next(response);
  },
));
```

### 10.3 Connection Pooling

```dart
// Reuse HTTP client
class ApiClientPool {
  static final Map<String, Dio> _clients = {};

  static Dio getClient(String baseUrl) {
    if (!_clients.containsKey(baseUrl)) {
      _clients[baseUrl] = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        persistentConnection: true, // Connection pooling
      ));
    }

    return _clients[baseUrl]!;
  }
}
```

### 10.4 Request Batching

```dart
// lib/core/network/batch_processor.dart

class BatchProcessor<T> {
  final Duration batchInterval;
  final int maxBatchSize;
  final Future<void> Function(List<T>) processor;

  final List<T> _buffer = [];
  Timer? _timer;

  BatchProcessor({
    required this.processor,
    this.batchInterval = const Duration(seconds: 5),
    this.maxBatchSize = 50,
  });

  void add(T item) {
    _buffer.add(item);

    if (_buffer.length >= maxBatchSize) {
      _flush();
    } else {
      _timer?.cancel();
      _timer = Timer(batchInterval, _flush);
    }
  }

  Future<void> _flush() async {
    if (_buffer.isEmpty) return;

    final batch = List<T>.from(_buffer);
    _buffer.clear();
    _timer?.cancel();

    await processor(batch);
  }
}

// Usage: Batch meal sync
final batchSync = BatchProcessor<MealModel>(
  processor: (meals) => _syncManager.syncMeals(meals),
  batchInterval: Duration(seconds: 10),
  maxBatchSize: 20,
);

// Add meals to batch
batchSync.add(meal1);
batchSync.add(meal2);
// Automatically syncs when batch is full or after 10 seconds
```

---

## 11. Testing & Monitoring

### 11.1 API Testing Approach

```dart
// test/features/chat/data/datasources/claude_remote_datasource_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late ClaudeRemoteDataSource dataSource;
  late Dio dio;
  late DioAdapter dioAdapter;

  setUp(() {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);
    dataSource = ClaudeRemoteDataSource(
      client: ClaudeApiClient(apiKey: 'test_key', dio: dio),
    );
  });

  group('sendMessage', () {
    test('returns MessageResponse on successful request', () async {
      // Arrange
      final mockResponse = {
        'id': 'msg_123',
        'type': 'message',
        'role': 'assistant',
        'content': [
          {'type': 'text', 'text': 'Hello!'}
        ],
        'model': 'claude-3-5-sonnet-20241022',
        'usage': {'input_tokens': 10, 'output_tokens': 5},
      };

      dioAdapter.onPost(
        '/v1/messages',
        (server) => server.reply(200, mockResponse),
      );

      // Act
      final result = await dataSource.sendMessage('Hello AI');

      // Assert
      expect(result.id, 'msg_123');
      expect(result.content.first.text, 'Hello!');
    });

    test('throws RateLimitException when rate limited', () async {
      // Arrange
      dioAdapter.onPost(
        '/v1/messages',
        (server) => server.reply(429, {
          'error': {
            'type': 'rate_limit_error',
            'message': 'Rate limit exceeded',
          }
        }),
      );

      // Act & Assert
      expect(
        () => dataSource.sendMessage('Test'),
        throwsA(isA<RateLimitException>()),
      );
    });
  });
}
```

### 11.2 Integration Testing

```bash
# Test against real APIs (use test account)
flutter test integration_test/api_integration_test.dart --dart-define=ENVIRONMENT=staging
```

### 11.3 Monitoring & Logging

```dart
// lib/core/monitoring/api_logger.dart

class ApiLogger extends Interceptor {
  final Logger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.info('API Request: ${options.method} ${options.path}');
    _logger.debug('Headers: ${options.headers}');
    _logger.debug('Body: ${options.data}');

    // Track request start time
    options.extra['request_start'] = DateTime.now();

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['request_start'] as DateTime;
    final duration = DateTime.now().difference(startTime);

    _logger.info(
      'API Response: ${response.statusCode} ${response.requestOptions.path} '
      '(${duration.inMilliseconds}ms)',
    );

    // Track metrics
    _analytics.logEvent(
      name: 'api_request',
      parameters: {
        'method': response.requestOptions.method,
        'path': response.requestOptions.path,
        'status_code': response.statusCode,
        'duration_ms': duration.inMilliseconds,
      },
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.error(
      'API Error: ${err.requestOptions.method} ${err.requestOptions.path}',
      error: err,
      stackTrace: err.stackTrace,
    );

    // Report to Firebase Crashlytics
    FirebaseCrashlytics.instance.recordError(
      err,
      err.stackTrace,
      reason: 'API Error',
      information: [
        'Method: ${err.requestOptions.method}',
        'Path: ${err.requestOptions.path}',
        'Status: ${err.response?.statusCode}',
      ],
    );

    handler.next(err);
  }
}
```

### 11.4 Alert Thresholds

**Monitoring Metrics:**

| Metric | Threshold | Action |
|--------|-----------|--------|
| Error Rate | > 5% | Alert team |
| Response Time | > 3s | Investigate |
| Rate Limit Hits | > 10/hour | Optimize usage |
| Token Usage | > 80% monthly quota | Notify admin |
| Auth Failures | > 20/hour | Check auth system |
| Sync Failures | > 50/hour | Check Firebase |

**Firebase Crashlytics Configuration:**

```dart
Future<void> initializeMonitoring() async {
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
    return true;
  };

  // Set user identifier for debugging
  final userId = await _authService.getCurrentUserId();
  if (userId != null) {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }
}
```

---

## Summary

This comprehensive API documentation covers:

1. **Claude API Integration** - Complete streaming implementation with context building
2. **Firebase APIs** - Authentication, Firestore queries, Cloud Functions
3. **Internal Services** - Context builder, sync manager, offline queue, notifications, biometric auth
4. **Request/Response Formats** - Standardized schemas for all entities
5. **Error Handling** - Comprehensive error codes and retry strategies
6. **Rate Limiting** - Client-side throttling and backoff strategies
7. **API Versioning** - Current v1 with future-proofing strategy
8. **Security** - API key management, HTTPS enforcement, token handling
9. **Performance** - Caching, compression, connection pooling, request batching
10. **Testing & Monitoring** - Testing strategies and alert thresholds

**Key Highlights:**
- Real-time AI streaming with Claude 3.5 Sonnet
- Offline-first with automatic sync
- Token usage tracking for cost management
- Circuit breaker pattern for resilience
- Comprehensive error handling with retry logic
- Secure API key storage in Android Keystore
- Firebase integration for auth and cloud storage

**Ready for implementation!**