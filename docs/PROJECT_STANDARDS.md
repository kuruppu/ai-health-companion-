# AI Health Companion - Project Standards

**Version:** 1.0
**Last Updated:** 2026-07-03
**Status:** Active
**Applies To:** All code, documentation, and processes

---

## Table of Contents

1. [Naming Conventions](#naming-conventions)
2. [Folder Structure](#folder-structure)
3. [Architecture Patterns](#architecture-patterns)
4. [Dependency Injection](#dependency-injection)
5. [Error Handling](#error-handling)
6. [Logging](#logging)
7. [Testing Standards](#testing-standards)
8. [Code Documentation](#code-documentation)
9. [Git Workflow](#git-workflow)
10. [CI/CD Pipeline](#cicd-pipeline)
11. [Versioning Strategy](#versioning-strategy)
12. [Flutter Best Practices](#flutter-best-practices)

---

## 1. Naming Conventions

### 1.1 Folder Naming

**Rule:** Use `snake_case` for all folder names.

```
✅ Good
lib/features/auth/
lib/core/network/
lib/data/models/

❌ Bad
lib/Features/Auth/
lib/core/Network/
lib/Data/Models/
```

### 1.2 File Naming

**Rule:** Use `snake_case` for all Dart files.

```
✅ Good
user_repository.dart
auth_provider.dart
workout_log_model.dart

❌ Bad
UserRepository.dart
authProvider.dart
WorkoutLogModel.dart
```

**Special Suffixes:**
- Models: `*_model.dart` (e.g., `user_model.dart`)
- Providers: `*_provider.dart` (e.g., `auth_provider.dart`)
- Repositories: `*_repository.dart` (e.g., `workout_repository.dart`)
- Services: `*_service.dart` (e.g., `api_service.dart`)
- Extensions: `*_extension.dart` (e.g., `string_extension.dart`)
- Tests: `*_test.dart` (e.g., `user_repository_test.dart`)

### 1.3 Class Naming

**Rule:** Use `PascalCase` for class names.

```dart
✅ Good
class UserRepository { }
class AuthProvider { }
class WorkoutLogModel { }

❌ Bad
class userRepository { }
class auth_provider { }
class workout_log_model { }
```

**Naming Patterns:**
- Entities: `{Name}` (e.g., `User`, `WorkoutLog`)
- Models: `{Name}Model` (e.g., `UserModel`, `WorkoutLogModel`)
- Providers: `{Name}Provider` (e.g., `AuthProvider`, `ChatProvider`)
- Repositories: `{Name}Repository` (e.g., `UserRepository`, `MealRepository`)
- Services: `{Name}Service` (e.g., `ApiService`, `NotificationService`)
- Use Cases: `{Verb}{Noun}UseCase` (e.g., `GetUserUseCase`, `SaveMealUseCase`)

### 1.4 Variable Naming

```dart
✅ Good
// camelCase for variables and function names
final String userName = 'John';
void fetchUserData() { }

// _ prefix for private members
final String _privateField = 'secret';
void _privateMethod() { }

// UPPER_SNAKE_CASE for constants
const String API_BASE_URL = 'https://api.example.com';
const int MAX_RETRY_ATTEMPTS = 3;

❌ Bad
final String UserName = 'John';  // Should be camelCase
void FetchUserData() { }         // Should be camelCase
const String apiBaseUrl = '...'; // Should be UPPER_SNAKE_CASE
```

### 1.5 Boolean Naming

**Rule:** Use `is`, `has`, `can`, `should` prefixes.

```dart
✅ Good
bool isLoading = false;
bool hasInternet = true;
bool canEdit = false;
bool shouldRetry = true;

❌ Bad
bool loading = false;     // Unclear
bool internet = true;     // Ambiguous
bool edit = false;        // Not descriptive
```

---

## 2. Folder Structure

### 2.1 Clean Architecture Structure

```
lib/
├── main.dart                      # App entry point
├── app.dart                       # MaterialApp configuration
│
├── core/                          # Shared utilities (no business logic)
│   ├── constants/
│   │   ├── api_constants.dart     # API URLs, endpoints
│   │   ├── app_constants.dart     # App-wide constants
│   │   ├── storage_constants.dart # Database keys, Hive box names
│   │   └── theme_constants.dart   # Colors, sizes, fonts
│   │
│   ├── errors/
│   │   ├── exceptions.dart        # Custom exceptions
│   │   ├── failures.dart          # Failure types (Either pattern)
│   │   └── error_handler.dart     # Global error handling
│   │
│   ├── network/
│   │   ├── network_info.dart      # Connectivity checker
│   │   └── dio_client.dart        # HTTP client wrapper
│   │
│   ├── utils/
│   │   ├── date_utils.dart        # Date formatting, parsing
│   │   ├── validators.dart        # Input validators
│   │   ├── formatters.dart        # Number, text formatters
│   │   └── extensions.dart        # Dart extensions
│   │
│   ├── themes/
│   │   ├── app_theme.dart         # ThemeData configuration
│   │   ├── app_colors.dart        # Color palette
│   │   └── app_text_styles.dart   # Typography
│   │
│   └── di/
│       └── injection_container.dart  # Dependency injection setup
│
├── features/                      # Feature modules (domain-driven)
│   │
│   ├── auth/                      # Authentication feature
│   │   ├── data/                  # Data layer
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   │
│   │   ├── domain/                # Domain layer
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_with_email.dart
│   │   │       └── verify_otp.dart
│   │   │
│   │   └── presentation/          # Presentation layer
│   │       ├── providers/
│   │       │   ├── auth_provider.dart
│   │       │   └── auth_state.dart
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   └── otp_screen.dart
│   │       └── widgets/
│   │           ├── email_input_field.dart
│   │           └── otp_input_field.dart
│   │
│   ├── nutrition/                 # Nutrition feature
│   ├── workout/                   # Workout feature
│   ├── chat/                      # Chat feature
│   └── ...                        # Other features
│
└── shared/                        # Shared widgets/components
    ├── widgets/
    │   ├── custom_button.dart
    │   ├── custom_text_field.dart
    │   └── loading_indicator.dart
    └── components/
        ├── bottom_nav_bar.dart
        └── app_bar.dart
```

### 2.2 Folder Organization Rules

1. **One feature = One folder** under `features/`
2. **Three layers per feature:** `data/`, `domain/`, `presentation/`
3. **No circular dependencies** between features
4. **Core is shared** across all features (no feature-specific code)
5. **Shared is UI-only** (reusable widgets, no business logic)

---

## 3. Architecture Patterns

### 3.1 Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │  ← UI, State Management (Riverpod)
├─────────────────────────────────────────┤
│         Domain Layer                    │  ← Business Logic, Entities, Use Cases
├─────────────────────────────────────────┤
│         Data Layer                      │  ← Repositories, Data Sources, Models
└─────────────────────────────────────────┘
```

**Dependency Rule:** Inner layers know nothing about outer layers.
- Domain depends on: Nothing
- Data depends on: Domain
- Presentation depends on: Domain (not Data)

### 3.2 Repository Pattern

**Interface (Domain Layer):**

```dart
// lib/features/auth/domain/repositories/auth_repository.dart

abstract class AuthRepository {
  Future<Either<Failure, User>> loginWithEmail(String email);
  Future<Either<Failure, User>> verifyOtp(String otp);
  Future<Either<Failure, void>> logout();
}
```

**Implementation (Data Layer):**

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> loginWithEmail(String email) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.loginWithEmail(email);
        await localDataSource.cacheUser(userModel);
        return Right(userModel.toEntity());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
```

**Key Principles:**
- Repository interface in `domain/repositories/`
- Repository implementation in `data/repositories/`
- Use `Either<Failure, Success>` pattern (from `dartz` package)
- Repository coordinates between data sources
- Converts models to entities

### 3.3 Use Case Pattern

**Rule:** One use case = One action

```dart
// lib/features/auth/domain/usecases/login_with_email.dart

class LoginWithEmailUseCase {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  Future<Either<Failure, User>> call(String email) async {
    // Input validation
    if (!_isValidEmail(email)) {
      return Left(InvalidInputFailure('Invalid email format'));
    }

    // Delegate to repository
    return await repository.loginWithEmail(email);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
```

**Key Principles:**
- Use cases contain business logic
- One use case = One public method (`call`)
- Validate inputs before calling repository
- Use cases in `domain/usecases/`

### 3.4 Entity vs Model Pattern

**Entity (Domain Layer):** Pure business object, no JSON.

```dart
// lib/features/auth/domain/entities/user.dart

class User extends Equatable {
  final String id;
  final String email;
  final String name;

  const User({
    required this.id,
    required this.email,
    required this.name,
  });

  @override
  List<Object?> get props => [id, email, name];
}
```

**Model (Data Layer):** Extends entity, adds JSON serialization.

```dart
// lib/features/auth/data/models/user_model.dart

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }

  User toEntity() => User(id: id, email: email, name: name);
}
```

**Key Differences:**
- Entity: Business logic layer, immutable, no serialization
- Model: Data layer, adds fromJson/toJson, extends entity

---

## 4. Dependency Injection

### 4.1 Using GetIt + Injectable

**Setup (lib/core/di/injection_container.dart):**

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
```

**Registering Dependencies:**

```dart
// Singleton (created once, lives for app lifetime)
@singleton
class ApiService {
  // ...
}

// Lazy Singleton (created on first use)
@lazySingleton
class UserRepository implements AuthRepository {
  // ...
}

// Factory (new instance every time)
@injectable
class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);
}
```

**Consuming Dependencies (Riverpod Provider):**

```dart
// lib/features/auth/presentation/providers/auth_provider.dart

@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final LoginWithEmailUseCase _loginUseCase;

  @override
  FutureOr<User?> build() {
    _loginUseCase = getIt<LoginWithEmailUseCase>();
    return null;
  }

  Future<void> login(String email) async {
    state = const AsyncLoading();
    final result = await _loginUseCase(email);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (user) => state = AsyncData(user),
    );
  }
}
```

### 4.2 Dependency Rules

1. **Register in injection_container.dart** (not in main.dart)
2. **Use constructor injection** (not getIt directly in classes)
3. **Interfaces in domain, implementations in data**
4. **Singleton for services, Factory for use cases**
5. **Test with mocks** (inject fake dependencies)

---

## 5. Error Handling

### 5.1 Exception Hierarchy

```dart
// lib/core/errors/exceptions.dart

/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);
}

/// Server-related exceptions
class ServerException extends AppException {
  ServerException([String message = 'Server error occurred', String? code])
      : super(message, code);
}

/// Network-related exceptions
class NetworkException extends AppException {
  NetworkException([String message = 'No internet connection'])
      : super(message);
}

/// Cache-related exceptions
class CacheException extends AppException {
  CacheException([String message = 'Cache error occurred']) : super(message);
}

/// Authentication exceptions
class AuthException extends AppException {
  AuthException(String message, [String? code]) : super(message, code);
}
```

### 5.2 Failure Types

```dart
// lib/core/errors/failures.dart

import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Server failure (API errors)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

/// Network failure (no internet)
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection']) : super(message);
}

/// Cache failure (local storage errors)
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

/// Invalid input failure (validation errors)
class InvalidInputFailure extends Failure {
  const InvalidInputFailure(String message) : super(message);
}
```

### 5.3 Error Handling Pattern

**In Repository:**

```dart
Future<Either<Failure, User>> getUser(String id) async {
  try {
    final userModel = await remoteDataSource.getUser(id);
    return Right(userModel.toEntity());
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message));
  } catch (e) {
    return Left(ServerFailure('Unexpected error: $e'));
  }
}
```

**In Use Case:**

```dart
Future<Either<Failure, User>> call(String id) async {
  if (id.isEmpty) {
    return Left(InvalidInputFailure('User ID cannot be empty'));
  }
  return await repository.getUser(id);
}
```

**In Presentation (Riverpod):**

```dart
Future<void> loadUser(String id) async {
  state = const AsyncLoading();

  final result = await getUserUseCase(id);

  result.fold(
    (failure) {
      state = AsyncError(failure, StackTrace.current);
      // Show error to user
      _showErrorSnackbar(failure.message);
    },
    (user) {
      state = AsyncData(user);
    },
  );
}
```

### 5.4 User-Facing Error Messages

```dart
// lib/core/errors/error_handler.dart

class ErrorHandler {
  static String getErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'No internet connection. Please check your network.';
    } else if (failure is ServerFailure) {
      return 'Something went wrong. Please try again.';
    } else if (failure is CacheFailure) {
      return 'Failed to load data. Please restart the app.';
    } else if (failure is InvalidInputFailure) {
      return failure.message; // Show specific validation error
    } else {
      return 'An unexpected error occurred.';
    }
  }
}
```

---

## 6. Logging

### 6.1 Logger Setup

**Use flutter_logs package:**

```dart
// lib/core/utils/logger.dart

import 'package:flutter_logs/flutter_logs.dart';

class AppLogger {
  static const String _tag = 'AIHealthCompanion';

  static Future<void> initialize() async {
    await FlutterLogs.initLogs(
      logLevelsEnabled: [
        LogLevel.INFO,
        LogLevel.WARNING,
        LogLevel.ERROR,
      ],
      timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
      directoryStructure: DirectoryStructure.FOR_DATE,
      logTypesEnabled: ['device', 'network', 'errors'],
      logFileExtension: LogFileExtension.LOG,
      logsWriteDirectoryName: 'AIHealthCompanionLogs',
      logsExportDirectoryName: 'AIHealthCompanionLogs/Exported',
      debugFileOperations: false,
      isDebuggable: true,
    );
  }

  static void info(String message, {String? tag}) {
    FlutterLogs.logInfo(tag ?? _tag, 'Info', message);
  }

  static void warning(String message, {String? tag}) {
    FlutterLogs.logWarn(tag ?? _tag, 'Warning', message);
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    FlutterLogs.logError(
      tag ?? _tag,
      'Error',
      '$message${error != null ? '\nError: $error' : ''}${stackTrace != null ? '\nStackTrace: $stackTrace' : ''}',
    );
  }
}
```

### 6.2 Logging Rules

**What to Log:**
- ✅ API requests/responses (sanitize sensitive data)
- ✅ User actions (login, logout, meal logged)
- ✅ Errors and exceptions
- ✅ Navigation events (screen changes)
- ✅ Background task execution (reminders, sync)

**What NOT to Log:**
- ❌ Passwords, API keys, tokens
- ❌ User's personal health data in production logs
- ❌ PII (personally identifiable information)

**Example Usage:**

```dart
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, User>> loginWithEmail(String email) async {
    AppLogger.info('Attempting login with email: ${email.substring(0, 3)}***');

    try {
      final userModel = await remoteDataSource.loginWithEmail(email);
      AppLogger.info('Login successful for user: ${userModel.id}');
      return Right(userModel.toEntity());
    } on ServerException catch (e, stack) {
      AppLogger.error('Login failed', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message));
    }
  }
}
```

---

## 7. Testing Standards

### 7.1 Test File Structure

```
test/
├── unit/                          # Unit tests (business logic)
│   ├── domain/
│   │   └── usecases/
│   │       └── login_with_email_test.dart
│   └── data/
│       └── repositories/
│           └── auth_repository_impl_test.dart
│
├── widget/                        # Widget tests (UI components)
│   ├── screens/
│   │   └── login_screen_test.dart
│   └── widgets/
│       └── custom_button_test.dart
│
└── integration/                   # Integration tests (E2E flows)
    └── login_flow_test.dart
```

### 7.2 Testing Pyramid

```
        ┌─────────┐
        │   E2E   │  ← 10% (Slow, expensive)
        └─────────┘
      ┌─────────────┐
      │   Widget    │  ← 30% (Medium speed)
      └─────────────┘
    ┌─────────────────┐
    │      Unit       │  ← 60% (Fast, cheap)
    └─────────────────┘
```

**Target Coverage:** 80% overall, 90% for business logic (use cases, repositories)

### 7.3 Unit Test Template

```dart
// test/domain/usecases/login_with_email_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

@GenerateMocks([AuthRepository])
import 'login_with_email_test.mocks.dart';

void main() {
  late LoginWithEmailUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginWithEmailUseCase(mockRepository);
  });

  group('LoginWithEmailUseCase', () {
    const tEmail = 'test@example.com';
    const tUser = User(id: '1', email: tEmail, name: 'Test User');

    test('should return User when login is successful', () async {
      // arrange
      when(mockRepository.loginWithEmail(any))
          .thenAnswer((_) async => Right(tUser));

      // act
      final result = await useCase(tEmail);

      // assert
      expect(result, Right(tUser));
      verify(mockRepository.loginWithEmail(tEmail));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return InvalidInputFailure when email is empty', () async {
      // act
      final result = await useCase('');

      // assert
      expect(result, Left(InvalidInputFailure('Invalid email format')));
      verifyZeroInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      when(mockRepository.loginWithEmail(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      // act
      final result = await useCase(tEmail);

      // assert
      expect(result, Left(ServerFailure()));
      verify(mockRepository.loginWithEmail(tEmail));
    });
  });
}
```

### 7.4 Widget Test Template

```dart
// test/widget/screens/login_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('LoginScreen displays email input field', (tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify that email input field is present
    expect(find.byKey(const Key('email_input_field')), findsOneWidget);

    // Verify that continue button is present
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('LoginScreen shows error when email is invalid', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Enter invalid email
    await tester.enterText(find.byKey(const Key('email_input_field')), 'invalid-email');

    // Tap continue button
    await tester.tap(find.text('Continue'));
    await tester.pump();

    // Verify error message is shown
    expect(find.text('Invalid email format'), findsOneWidget);
  });
}
```

### 7.5 Integration Test Template

```dart
// integration_test/login_flow_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ai_health_companion/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Integration Test', () {
    testWidgets('complete login flow from email to dashboard', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Enter email
      await tester.enterText(find.byKey(const Key('email_input')), 'test@example.com');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify OTP screen appears
      expect(find.text('Enter OTP'), findsOneWidget);

      // Enter OTP
      await tester.enterText(find.byKey(const Key('otp_input')), '123456');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();

      // Verify dashboard appears
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}
```

### 7.6 Testing Rules

1. **Write tests BEFORE implementation** (TDD where possible)
2. **AAA pattern:** Arrange, Act, Assert
3. **One assertion per test** (or closely related assertions)
4. **Mock external dependencies** (API, database, etc.)
5. **Test behavior, not implementation**
6. **Run tests on every commit** (CI/CD)

---

## 8. Code Documentation

### 8.1 When to Add Comments

**DO Comment:**
- ✅ Complex algorithms (explain WHY, not WHAT)
- ✅ Public APIs (classes, methods exposed to other features)
- ✅ Non-obvious business rules
- ✅ Workarounds or hacks (with TODO to fix later)

**DON'T Comment:**
- ❌ Obvious code (e.g., `// Set loading to true`)
- ❌ Code that should be self-explanatory (rename instead)
- ❌ Commented-out code (delete it, Git has history)

### 8.2 Documentation Style

**Class Documentation:**

```dart
/// Repository for user authentication operations.
///
/// Handles login, OTP verification, and session management.
/// Coordinates between remote API and local cache.
///
/// Example:
/// ```dart
/// final authRepo = getIt<AuthRepository>();
/// final result = await authRepo.loginWithEmail('user@example.com');
/// ```
class AuthRepositoryImpl implements AuthRepository {
  // ...
}
```

**Method Documentation:**

```dart
/// Logs in user with email and sends OTP to their phone.
///
/// [email] must be a valid email format.
///
/// Returns [Right(User)] on success, [Left(Failure)] on error.
///
/// Throws [NetworkException] if no internet connection.
Future<Either<Failure, User>> loginWithEmail(String email) async {
  // Implementation
}
```

**Complex Logic Documentation:**

```dart
// Calculate BMR using Mifflin-St Jeor equation
// BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age) + s
// where s = +5 for males, -161 for females
final bmr = (10 * weight) + (6.25 * height) - (5 * age) + (gender == 'male' ? 5 : -161);
```

### 8.3 TODO Comments

```dart
// TODO(username): Implement retry logic with exponential backoff
// Priority: High, Deadline: Sprint 3
Future<void> fetchData() async {
  // Current implementation
}

// FIXME: This causes memory leak when user logs out
// Bug ticket: #123
void subscribeToUpdates() {
  // Buggy implementation
}
```

---

## 9. Git Workflow

### 9.1 Branch Strategy

**Main Branches:**
- `main` - Production-ready code (always deployable)
- `develop` - Integration branch for features

**Feature Branches:**
- `feature/auth-login` - New feature
- `feature/nutrition-tracking` - New feature
- `bugfix/fix-otp-validation` - Bug fix
- `hotfix/critical-crash` - Critical production fix

**Branch Naming:**
```
feature/<feature-name>     # New feature
bugfix/<bug-name>          # Bug fix
hotfix/<issue-name>        # Critical production fix
chore/<task-name>          # Non-code changes (docs, CI/CD)
refactor/<refactor-name>   # Code refactoring
```

### 9.2 Commit Message Format

**Pattern:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Build process, dependencies, tooling

**Examples:**

```
feat(auth): add email login with OTP verification

- Implement login screen with email input
- Integrate Firebase Phone Auth for OTP
- Add OTP verification screen with 6-digit input
- Store user session in Hive

Closes #42
```

```
fix(nutrition): correct calorie calculation for rice

Previous calculation used raw rice calories instead of cooked.
Updated to use 130 cal/100g for cooked white rice.

Fixes #78
```

```
refactor(chat): extract message bubble into separate widget

Moved message bubble logic from chat_screen.dart to
widgets/message_bubble.dart for better reusability.

No functional changes.
```

### 9.3 Pull Request Process

1. **Create feature branch** from `develop`
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/nutrition-tracking
   ```

2. **Make changes and commit** (follow commit message format)
   ```bash
   git add .
   git commit -m "feat(nutrition): add meal logging with calorie estimation"
   ```

3. **Push to remote**
   ```bash
   git push origin feature/nutrition-tracking
   ```

4. **Create Pull Request** on GitHub
   - Title: `feat(nutrition): Add meal logging with calorie estimation`
   - Description: What changed, why, testing done
   - Link related issues: `Closes #42`
   - Request review from team

5. **Code Review** (see checklist below)

6. **Merge** (after approval and CI passes)
   - Squash and merge (for clean history)
   - Delete feature branch after merge

### 9.4 Code Review Checklist

**Reviewer checks:**
- [ ] Code follows project standards (this document)
- [ ] Tests are included and passing
- [ ] No commented-out code
- [ ] No console.log or debug prints
- [ ] Error handling is present
- [ ] No hardcoded values (use constants)
- [ ] Performance considerations addressed
- [ ] UI matches design mockups
- [ ] Accessibility considerations
- [ ] Documentation updated (if API changed)

---

## 10. CI/CD Pipeline

### 10.1 GitHub Actions Workflow

**File:** `.github/workflows/main.yml`

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ develop, main ]
  pull_request:
    branches: [ develop, main ]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter format --dry-run --set-exit-if-changed .

  test:
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

### 10.2 Pre-commit Hooks

**File:** `.githooks/pre-commit`

```bash
#!/bin/sh

# Run Flutter analyze
echo "Running Flutter analyze..."
flutter analyze
if [ $? -ne 0 ]; then
  echo "Flutter analyze failed. Please fix issues before committing."
  exit 1
fi

# Run Flutter format check
echo "Running Flutter format check..."
flutter format --dry-run --set-exit-if-changed .
if [ $? -ne 0 ]; then
  echo "Code is not formatted. Run 'flutter format .' before committing."
  exit 1
fi

# Run tests
echo "Running tests..."
flutter test
if [ $? -ne 0 ]; then
  echo "Tests failed. Please fix failing tests before committing."
  exit 1
fi

echo "All checks passed! ✅"
exit 0
```

**Setup:**
```bash
chmod +x .githooks/pre-commit
git config core.hooksPath .githooks
```

### 10.3 Release Process

**Versioning:** Follow Semantic Versioning (see next section)

**Steps:**
1. Create release branch: `release/v1.0.0`
2. Update version in `pubspec.yaml`
3. Update CHANGELOG.md
4. Run full test suite
5. Build release APK/AAB
6. Test on physical devices
7. Merge to `main`
8. Tag release: `git tag v1.0.0`
9. Deploy to Play Store (internal → beta → production)

---

## 11. Versioning Strategy

### 11.1 Semantic Versioning

**Format:** `MAJOR.MINOR.PATCH` (e.g., `1.2.3`)

- **MAJOR:** Breaking changes (incompatible API changes)
- **MINOR:** New features (backwards-compatible)
- **PATCH:** Bug fixes (backwards-compatible)

**Examples:**
- `1.0.0` → `1.0.1` : Bug fix (patch)
- `1.0.1` → `1.1.0` : New feature (minor)
- `1.1.0` → `2.0.0` : Breaking change (major)

### 11.2 Build Number

**Format:** `version: 1.2.3+45`

- `1.2.3` = Version name (shown to users)
- `45` = Build number (auto-increment for every build)

**In pubspec.yaml:**
```yaml
version: 1.0.0+1
```

**Auto-increment in CI/CD:**
```bash
# Get current version
CURRENT_VERSION=$(grep 'version:' pubspec.yaml | sed 's/version: //')
# Extract build number
BUILD_NUMBER=$(echo $CURRENT_VERSION | cut -d '+' -f 2)
# Increment
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
# Update pubspec.yaml
sed -i "s/version: .*/version: 1.0.0+$NEW_BUILD_NUMBER/" pubspec.yaml
```

### 11.3 CHANGELOG.md

**Format:**
```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2026-07-15

### Added
- Workout recommendation engine with progressive overload
- Weekly workout statistics dashboard
- Recovery day detection algorithm

### Fixed
- Calorie calculation for batch-cooked meals
- OTP resend cooldown timer issue

### Changed
- Improved AI response time by 40%
- Updated Material Design 3 theme colors

## [1.1.0] - 2026-07-01

### Added
- Nutrition engine with 50+ Sri Lankan foods
- Flex meal detection (2 per week)
- Meal history view

...
```

---

## 12. Flutter Best Practices

### 12.1 Widget Composition

**DO: Break down large widgets into smaller ones**

```dart
✅ Good
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _ProfileHeader(),
          _ProfileStats(),
          _ProfileSettings(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(title: Text('Profile'));
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Header UI
  }
}

❌ Bad
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Column(
        children: [
          Container(
            // 100 lines of nested widgets
            child: Row(
              children: [
                Column(
                  children: [
                    // More nesting...
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 12.2 Const Constructors

**DO: Use const constructors wherever possible**

```dart
✅ Good
const Text('Hello World')
const SizedBox(height: 16)
const EdgeInsets.all(8)

❌ Bad
Text('Hello World')  // Not const
SizedBox(height: 16)  // Not const
```

### 12.3 Keys

**DO: Use keys for list items**

```dart
✅ Good
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return ListTile(
      key: ValueKey(item.id),
      title: Text(item.name),
    );
  },
)

❌ Bad
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index].name),
    );  // No key
  },
)
```

### 12.4 Async/Await

**DO: Use async/await instead of .then()**

```dart
✅ Good
Future<User> getUser() async {
  try {
    final response = await apiService.fetchUser();
    return response.toEntity();
  } catch (e) {
    throw ServerException('Failed to fetch user');
  }
}

❌ Bad
Future<User> getUser() {
  return apiService.fetchUser().then((response) {
    return response.toEntity();
  }).catchError((e) {
    throw ServerException('Failed to fetch user');
  });
}
```

### 12.5 Build Method Performance

**DO: Minimize rebuilds**

```dart
✅ Good
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuild when user changes
    final user = ref.watch(userProvider);

    return Column(
      children: [
        Text(user.name),  // Rebuilds when user changes
        const _StaticWidget(),  // Never rebuilds (const)
      ],
    );
  }
}

❌ Bad
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches entire state, rebuilds on any change
    final state = ref.watch(appStateProvider);

    return Column(
      children: [
        Text(state.user.name),
        _StaticWidget(),  // Rebuilds unnecessarily
      ],
    );
  }
}
```

### 12.6 Null Safety

**DO: Use null safety features**

```dart
✅ Good
String? name;  // Nullable
String name = 'John';  // Non-nullable

// Null-aware operators
final length = name?.length ?? 0;
final upper = name?.toUpperCase();

// Null assertion (only when certain)
final nonNullName = name!;

❌ Bad
String name;  // Error: must be nullable or initialized
```

### 12.7 Immutability

**DO: Prefer immutable data structures**

```dart
✅ Good
class User {
  final String id;
  final String name;

  const User({required this.id, required this.name});

  User copyWith({String? id, String? name}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}

❌ Bad
class User {
  String id;
  String name;

  User({required this.id, required this.name});
}
```

---

## Standards Enforcement

### Automated Checks

1. **Flutter Analyze** (runs on every commit)
   - Checks code quality, potential bugs
   - Enforces linting rules (see `analysis_options.yaml`)

2. **Flutter Format** (runs on pre-commit hook)
   - Enforces consistent code formatting
   - 80-character line limit

3. **Test Coverage** (runs in CI/CD)
   - Requires 80% minimum coverage
   - Fails if coverage drops

4. **Code Review** (required before merge)
   - At least 1 approval required
   - Reviewer checks standards compliance

### Manual Reviews

- **Architecture Review:** Before starting each milestone
- **Code Review:** On every pull request
- **Standards Update:** Quarterly (or when needed)

---

## Conclusion

These standards are living documents. As the project evolves, update this document to reflect new patterns, tools, or best practices discovered along the way.

**Questions or Suggestions?** Open an issue or discuss in team meetings.

**Last Updated:** 2026-07-03 by Project Lead

