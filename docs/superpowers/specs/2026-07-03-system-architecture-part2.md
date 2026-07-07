# AI Health Companion - System Architecture (Part 2)

**Continued from Part 1**

---

## 7. Security & Authentication

### 7.1 Firebase Authentication Flow

```dart
// lib/features/auth/data/datasources/auth_remote_datasource.dart

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  /// Sign in with email and OTP
  Future<String> signInWithEmail(String email) async {
    try {
      // Send OTP via email link
      await _firebaseAuth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://aihealth.companion/finishSignIn?cartId=1234',
          handleCodeInApp: true,
          androidPackageName: 'com.aihealth.companion',
          androidInstallApp: true,
          androidMinimumVersion: '1',
        ),
      );

      return 'OTP_SENT';
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with phone and OTP
  Future<String> signInWithPhone(String phoneNumber) async {
    final completer = Completer<String>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification (rare)
        await _firebaseAuth.signInWithCredential(credential);
        completer.complete('AUTO_VERIFIED');
      },
      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(_handleAuthException(e));
      },
      codeSent: (String verificationId, int? resendToken) {
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Timeout
      },
      timeout: const Duration(seconds: 60),
    );

    return completer.future;
  }

  /// Verify OTP code
  Future<UserModel> verifyOTP(String verificationId, String otpCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // Check if user profile exists
      final userId = userCredential.user!.uid;
      final profileDoc = await _firestore.collection('users').doc(userId).get();

      if (!profileDoc.exists) {
        // New user - needs onboarding
        throw OnboardingRequiredException();
      }

      return UserModel.fromFirestore(profileDoc);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Create user profile (after onboarding)
  Future<UserModel> createUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
      return user;
    } catch (e) {
      throw ServerException('Failed to create profile');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final doc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromFirestore(doc);
  }

  AuthenticationException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return AuthenticationException('Invalid phone number');
      case 'invalid-verification-code':
        return AuthenticationException('Invalid OTP code');
      case 'too-many-requests':
        return AuthenticationException('Too many attempts. Try again later.');
      case 'user-disabled':
        return AuthenticationException('Account disabled');
      default:
        return AuthenticationException('Authentication failed: ${e.message}');
    }
  }
}
```

### 7.2 Biometric Authentication

```dart
// lib/services/auth/biometric_service.dart

import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth;

  BiometricService({required LocalAuthentication localAuth})
      : _localAuth = localAuth;

  /// Check if biometric is available
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate with biometric
  Future<bool> authenticate({
    String reason = 'Please authenticate to access the app',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  /// Enable biometric for user
  Future<void> enableBiometric() async {
    final isAvailable = await isBiometricAvailable();
    if (!isAvailable) {
      throw BiometricNotAvailableException();
    }

    // Authenticate once to confirm
    final authenticated = await authenticate(
      reason: 'Authenticate to enable biometric login',
    );

    if (!authenticated) {
      throw BiometricAuthenticationFailedException();
    }

    // Save preference
    await Hive.box('preferences').put('biometric_enabled', true);
  }

  /// Disable biometric
  Future<void> disableBiometric() async {
    await Hive.box('preferences').put('biometric_enabled', false);
  }

  /// Check if biometric is enabled by user
  Future<bool> isBiometricEnabled() async {
    return Hive.box('preferences').get('biometric_enabled', defaultValue: false);
  }
}
```

### 7.3 Session Management

```dart
// lib/services/auth/session_manager.dart

class SessionManager {
  final SecureStorageService _secureStorage;
  final FirebaseAuth _firebaseAuth;

  SessionManager({
    required SecureStorageService secureStorage,
    required FirebaseAuth firebaseAuth,
  })  : _secureStorage = secureStorage,
        _firebaseAuth = firebaseAuth;

  /// Save session
  Future<void> saveSession(AuthTokens tokens) async {
    await _secureStorage.write(
      key: 'auth_tokens',
      value: jsonEncode(tokens.toJson()),
    );

    // Set session expiry timer
    _scheduleSessionRefresh(tokens.expiresAt);
  }

  /// Get session
  Future<AuthTokens?> getSession() async {
    final tokensJson = await _secureStorage.read(key: 'auth_tokens');
    if (tokensJson == null) return null;

    final tokens = AuthTokens.fromJson(jsonDecode(tokensJson));

    // Check if expired
    if (DateTime.now().isAfter(tokens.expiresAt)) {
      await refreshSession();
      return await getSession();
    }

    return tokens;
  }

  /// Refresh session
  Future<void> refreshSession() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw UnauthorizedException('No user logged in');
      }

      final idToken = await user.getIdToken(true); // Force refresh
      final idTokenResult = await user.getIdTokenResult(true);

      final tokens = AuthTokens(
        accessToken: idToken!,
        refreshToken: user.refreshToken ?? '',
        expiresAt: idTokenResult.expirationTime!,
        userId: user.uid,
        firebaseIdToken: idToken,
      );

      await saveSession(tokens);
    } catch (e) {
      throw AuthenticationException('Failed to refresh session');
    }
  }

  /// Clear session
  Future<void> clearSession() async {
    await _secureStorage.delete(key: 'auth_tokens');
    await _firebaseAuth.signOut();
  }

  /// Auto-refresh before expiry
  void _scheduleSessionRefresh(DateTime expiresAt) {
    final now = DateTime.now();
    final timeUntilExpiry = expiresAt.difference(now);

    // Refresh 5 minutes before expiry
    final refreshTime = timeUntilExpiry - const Duration(minutes: 5);

    if (refreshTime.isNegative) {
      refreshSession();
    } else {
      Future.delayed(refreshTime, () => refreshSession());
    }
  }
}
```

### 7.4 API Request Interceptor (Add Auth Headers)

```dart
// lib/core/network/auth_interceptor.dart

class AuthInterceptor extends Interceptor {
  final SessionManager _sessionManager;

  AuthInterceptor({required SessionManager sessionManager})
      : _sessionManager = sessionManager;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth token to headers
    final session = await _sessionManager.getSession();

    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
      options.headers['X-User-Id'] = session.userId;
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401) {
      try {
        // Try to refresh token
        await _sessionManager.refreshSession();

        // Retry original request
        final options = err.requestOptions;
        final session = await _sessionManager.getSession();
        options.headers['Authorization'] = 'Bearer ${session!.accessToken}';

        final response = await Dio().fetch(options);
        return handler.resolve(response);
      } catch (e) {
        // Refresh failed - user needs to login again
        await _sessionManager.clearSession();
        return handler.reject(err);
      }
    }

    handler.next(err);
  }
}
```

---

## 8. Performance Optimization

### 8.1 Lazy Loading & Pagination

```dart
// lib/core/widgets/infinite_scroll_list.dart

class InfiniteScrollList<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int limit) fetchItems;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final int pageSize;

  const InfiniteScrollList({
    required this.fetchItems,
    required this.itemBuilder,
    this.pageSize = 20,
  });

  @override
  State<InfiniteScrollList<T>> createState() => _InfiniteScrollListState<T>();
}

class _InfiniteScrollListState<T> extends State<InfiniteScrollList<T>> {
  final List<T> _items = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newItems = await widget.fetchItems(_currentPage, widget.pageSize);

      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _hasMore = newItems.length == widget.pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Show error
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return widget.itemBuilder(context, _items[index]);
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// Usage: Meals History with pagination
class MealsHistoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal History')),
      body: InfiniteScrollList<Meal>(
        fetchItems: (page, limit) async {
          final repository = ref.read(mealRepositoryProvider);
          return repository.getMealsPage(page: page, limit: limit);
        },
        itemBuilder: (context, meal) => MealCard(meal: meal),
        pageSize: 20,
      ),
    );
  }
}
```

### 8.2 Image Optimization

```dart
// lib/core/widgets/optimized_image.dart

class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const OptimizedImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: width,
          height: height,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.error),
      ),
      memCacheWidth: width != null ? (width! * 2).toInt() : null,
      memCacheHeight: height != null ? (height! * 2).toInt() : null,
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
    );
  }
}
```

### 8.3 Database Query Optimization

```dart
// lib/features/meals/data/datasources/meal_local_datasource.dart

class MealLocalDataSource {
  final Database _database;

  MealLocalDataSource({required Database database}) : _database = database;

  /// Get today's meals (optimized with index)
  Future<List<MealModel>> getTodayMeals(String userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Uses idx_meals_user_date index
    final result = await _database.query(
      'meals',
      where: 'user_id = ? AND date(consumed_at) = ? AND is_deleted = 0',
      whereArgs: [userId, today],
      orderBy: 'consumed_at DESC',
    );

    return result.map((json) => MealModel.fromJson(json)).toList();
  }

  /// Get meals with pagination (cursor-based)
  Future<List<MealModel>> getMealsPage({
    required String userId,
    required int page,
    required int limit,
  }) async {
    final offset = page * limit;

    // Uses idx_meals_user_date index
    final result = await _database.query(
      'meals',
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'consumed_at DESC',
      limit: limit,
      offset: offset,
    );

    return result.map((json) => MealModel.fromJson(json)).toList();
  }

  /// Aggregate query (today's total calories)
  Future<double> getTodayTotalCalories(String userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    final result = await _database.rawQuery('''
      SELECT SUM(calories) as total
      FROM meals
      WHERE user_id = ? AND date(consumed_at) = ? AND is_deleted = 0
    ''', [userId, today]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
```

### 8.4 Memory Management

```dart
// lib/core/utils/memory_manager.dart

class MemoryManager {
  /// Clear image cache
  static Future<void> clearImageCache() async {
    await DefaultCacheManager().emptyCache();
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  /// Clear old data from SQLite
  static Future<void> cleanOldData(Database db) async {
    // Delete soft-deleted items older than 30 days
    final thirtyDaysAgo = DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String();

    await db.delete(
      'meals',
      where: 'is_deleted = 1 AND updated_at < ?',
      whereArgs: [thirtyDaysAgo],
    );

    await db.delete(
      'chat_messages',
      where: 'is_deleted = 1 AND updated_at < ?',
      whereArgs: [thirtyDaysAgo],
    );

    // Vacuum database to reclaim space
    await db.execute('VACUUM');
  }

  /// Monitor memory usage
  static Future<void> monitorMemory() async {
    // In debug mode only
    if (kDebugMode) {
      final info = await DeviceInfoPlugin().androidInfo;
      final memory = info.totalMem;
      print('Total device memory: ${memory / 1024 / 1024} MB');

      // Check image cache size
      final cacheSize = imageCache.currentSize;
      print('Image cache size: $cacheSize images');
    }
  }
}
```

---

## 9. Testing Strategy

### 9.1 Unit Tests

```dart
// test/features/meals/domain/usecases/get_remaining_calories_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

void main() {
  late GetRemainingCalories usecase;
  late MockMealRepository mockRepository;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockRepository = MockMealRepository();
    mockUserRepository = MockUserRepository();
    usecase = GetRemainingCalories(
      mealRepository: mockRepository,
      userRepository: mockUserRepository,
    );
  });

  group('GetRemainingCalories', () {
    const userId = 'user123';
    const dailyTarget = 1200.0;
    const consumedCalories = 800.0;

    test('should return remaining calories when data is available', () async {
      // Arrange
      when(mockUserRepository.getUserProfile(userId)).thenAnswer(
        (_) async => Right(UserProfile(dailyCalorieTarget: dailyTarget)),
      );

      when(mockRepository.getTodayTotalCalories(userId)).thenAnswer(
        (_) async => Right(consumedCalories),
      );

      // Act
      final result = await usecase(userId);

      // Assert
      expect(result, Right(dailyTarget - consumedCalories)); // 400.0
      verify(mockUserRepository.getUserProfile(userId));
      verify(mockRepository.getTodayTotalCalories(userId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when user profile fetch fails', () async {
      // Arrange
      when(mockUserRepository.getUserProfile(userId)).thenAnswer(
        (_) async => Left(CacheFailure('Profile not found')),
      );

      // Act
      final result = await usecase(userId);

      // Assert
      expect(result.isLeft(), true);
      verify(mockUserRepository.getUserProfile(userId));
      verifyZeroInteractions(mockRepository);
    });

    test('should return 0 when consumed exceeds target', () async {
      // Arrange
      when(mockUserRepository.getUserProfile(userId)).thenAnswer(
        (_) async => Right(UserProfile(dailyCalorieTarget: dailyTarget)),
      );

      when(mockRepository.getTodayTotalCalories(userId)).thenAnswer(
        (_) async => Right(1500.0), // Exceeded
      );

      // Act
      final result = await usecase(userId);

      // Assert
      expect(result, Right(0.0)); // Can't go negative
    });
  });
}
```

### 9.2 Widget Tests

```dart
// test/features/chat/presentation/widgets/message_bubble_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessageBubble Widget', () {
    testWidgets('displays user message correctly', (tester) async {
      // Arrange
      const message = Message(
        id: '1',
        role: 'user',
        content: 'Hello AI',
        timestamp: '2026-07-03T10:00:00Z',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      // Assert
      expect(find.text('Hello AI'), findsOneWidget);
      expect(find.byType(MessageBubble), findsOneWidget);

      // Check alignment (user messages align right)
      final bubbleFinder = find.byType(Align);
      final align = tester.widget<Align>(bubbleFinder);
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('displays AI message with different styling', (tester) async {
      // Arrange
      const message = Message(
        id: '2',
        role: 'assistant',
        content: 'I can help you with that!',
        timestamp: '2026-07-03T10:01:00Z',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      // Assert
      expect(find.text('I can help you with that!'), findsOneWidget);

      // Check alignment (AI messages align left)
      final bubbleFinder = find.byType(Align);
      final align = tester.widget<Align>(bubbleFinder);
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('displays timestamp correctly', (tester) async {
      // Arrange
      const message = Message(
        id: '3',
        role: 'user',
        content: 'Test message',
        timestamp: '2026-07-03T15:30:00Z',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: message),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('3:30 PM'), findsOneWidget);
    });
  });
}
```

### 9.3 Integration Tests

```dart
// integration_test/chat_flow_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Chat Flow Integration Test', () {
    testWidgets('complete chat conversation flow', (tester) async {
      // Launch app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to chat
      final chatTab = find.byIcon(Icons.chat_bubble);
      await tester.tap(chatTab);
      await tester.pumpAndSettle();

      // Type message
      final messageInput = find.byType(TextField);
      await tester.enterText(
        messageInput,
        'I made chicken curry with rice, how much should I eat?',
      );
      await tester.pumpAndSettle();

      // Send message
      final sendButton = find.byIcon(Icons.send);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Wait for AI response (max 10 seconds)
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verify AI response appears
      expect(find.byType(MessageBubble), findsAtLeast(2));

      // Verify response contains portion recommendation
      expect(find.textContaining('cup'), findsOneWidget);
      expect(find.textContaining('calories'), findsOneWidget);
    });

    testWidgets('handles offline message queue', (tester) async {
      // Launch app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Disable network
      await NetworkSimulator.disable();

      // Send message while offline
      final chatTab = find.byIcon(Icons.chat_bubble);
      await tester.tap(chatTab);
      await tester.pumpAndSettle();

      final messageInput = find.byType(TextField);
      await tester.enterText(messageInput, 'Test offline message');
      await tester.pumpAndSettle();

      final sendButton = find.byIcon(Icons.send);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Verify offline indicator appears
      expect(find.text('Offline - Changes will sync later'), findsOneWidget);

      // Re-enable network
      await NetworkSimulator.enable();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify message synced
      expect(find.text('Offline - Changes will sync later'), findsNothing);
    });
  });
}
```

### 9.4 Test Coverage Goals

```yaml
# Target coverage: 80%+

Coverage Breakdown:
  - Domain Layer (Use Cases): 95%+ (critical business logic)
  - Data Layer (Repositories): 85%+ (data handling)
  - Presentation Layer (Providers): 70%+ (UI logic)
  - Widgets: 60%+ (UI components)

Priority Testing:
  1. Critical user flows (authentication, meal logging, chat)
  2. Offline functionality
  3. Data synchronization
  4. Error handling
  5. Edge cases (network failures, invalid inputs)
```

---

## 10. Deployment & CI/CD

### 10.1 CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/flutter-ci.yml

name: Flutter CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      - name: Run code generation
        run: flutter pub run build_runner build --delete-conflicting-outputs

      - name: Analyze code
        run: flutter analyze

      - name: Check formatting
        run: flutter format --set-exit-if-changed .

      - name: Run unit tests
        run: flutter test --coverage

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

      - name: Build APK
        run: flutter build apk --release

      - name: Upload APK artifact
        uses: actions/upload-artifact@v3
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk

  deploy-internal:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2

      - name: Build App Bundle
        run: flutter build appbundle --release

      - name: Deploy to Firebase App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_APP_ID }}
          serviceCredentialsFileContent: ${{ secrets.FIREBASE_CREDENTIALS }}
          groups: internal-testers
          file: build/app/outputs/bundle/release/app-release.aab

  deploy-production:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2

      - name: Build App Bundle
        run: flutter build appbundle --release

      - name: Deploy to Google Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_CREDENTIALS }}
          packageName: com.aihealth.companion
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
          status: completed
```

### 10.2 Environment Configuration

```dart
// lib/core/config/env_config.dart

class EnvConfig {
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static const String claudeApiKey = String.fromEnvironment(
    'CLAUDE_API_KEY',
    defaultValue: '',
  );

  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';

  static String get baseUrl {
    switch (environment) {
      case 'production':
        return 'https://api.aihealth.companion';
      case 'staging':
        return 'https://staging-api.aihealth.companion';
      default:
        return 'http://localhost:3000';
    }
  }
}

// Usage in build command:
// flutter build apk --dart-define=ENVIRONMENT=production --dart-define=CLAUDE_API_KEY=xxx
```

### 10.3 Release Checklist

```markdown
# Pre-Release Checklist

## Code Quality
- [ ] All tests passing (unit + widget + integration)
- [ ] Code coverage > 80%
- [ ] No critical analyzer warnings
- [ ] Code formatted (flutter format)
- [ ] No hardcoded secrets

## Feature Completeness
- [ ] All planned features implemented
- [ ] Edge cases handled
- [ ] Error messages user-friendly
- [ ] Offline mode tested
- [ ] Sync tested (create conflict scenarios)

## Performance
- [ ] App startup time < 3 seconds
- [ ] Chat response time < 2 seconds (with AI)
- [ ] Smooth scrolling (60 FPS)
- [ ] Memory usage < 200MB
- [ ] Battery drain acceptable

## Security
- [ ] API keys not in source code
- [ ] Biometric authentication working
- [ ] Session management tested
- [ ] Firestore security rules deployed
- [ ] HTTPS only

## User Experience
- [ ] Onboarding flow smooth
- [ ] All screens responsive
- [ ] Dark mode working
- [ ] Accessibility labels added
- [ ] Loading states proper

## Integration
- [ ] Firebase connected
- [ ] Claude API working
- [ ] Notifications delivered
- [ ] Deep links working

## Documentation
- [ ] README updated
- [ ] CHANGELOG created
- [ ] API docs current
- [ ] User guide written

## App Store
- [ ] Screenshots prepared (8 required)
- [ ] App description written
- [ ] Privacy policy published
- [ ] Terms of service published
- [ ] App icon finalized (512x512)
- [ ] Feature graphic created

## Testing
- [ ] Tested on Android 10+
- [ ] Tested on different screen sizes
- [ ] Tested with slow network
- [ ] Tested offline → online transition
- [ ] Tested with real Claude API (not mock)

## Deploy
- [ ] Version number bumped
- [ ] Release notes written
- [ ] APK signed with release key
- [ ] Uploaded to internal track
- [ ] Tested internal build
- [ ] Promoted to production
```

---

## Summary

### Architecture Highlights

✅ **Clean Architecture** - Separation of concerns, testability, maintainability
✅ **Riverpod State Management** - Type-safe, reactive, testable
✅ **Offline-First** - Works without internet, syncs seamlessly
✅ **Real-time AI** - Claude API integration with streaming responses
✅ **Biometric Auth** - Fingerprint/face unlock support
✅ **Secure** - Encrypted storage, session management, API key protection
✅ **Performance Optimized** - Lazy loading, pagination, caching
✅ **Thoroughly Tested** - Unit, widget, integration tests with 80%+ coverage
✅ **CI/CD Ready** - Automated testing, building, deployment
✅ **Production-Grade** - Error handling, logging, monitoring

### Tech Stack Summary

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter 3.19+ |
| **State Management** | Riverpod 2.x |
| **Navigation** | go_router |
| **Local DB** | SQLite (Drift) |
| **Cache** | Hive |
| **Cloud** | Firebase (Auth, Firestore, Functions) |
| **AI** | Claude API (Anthropic) |
| **HTTP Client** | Dio |
| **Code Generation** | freezed, json_serializable |
| **Testing** | flutter_test, mockito, integration_test |
| **CI/CD** | GitHub Actions |
| **Monitoring** | Firebase Crashlytics |

---

**This completes the System Architecture documentation. You now have:**
1. Complete database design (Part 1)
2. Folder structure (Clean Architecture)
3. API layer with Claude integration
4. State management with Riverpod
5. Navigation flow
6. Error handling strategy
7. Offline support
8. Security & authentication
9. Performance optimization
10. Testing strategy
11. CI/CD pipeline

**Ready for implementation!**
