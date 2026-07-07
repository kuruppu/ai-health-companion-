import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/injection_container.dart';
import '../../domain/entities/meal.dart';
import '../../domain/usecases/get_meal_history_usecase.dart';
import '../../domain/usecases/log_meal_usecase.dart';
import '../../domain/usecases/upload_image_usecase.dart';
import 'auth_provider.dart';

part 'meal_provider.g.dart';

@riverpod
class MealHistory extends _$MealHistory {
  late final GetMealHistoryUseCase _getMealHistory;

  @override
  Future<List<Meal>> build() async {
    _getMealHistory = getIt<GetMealHistoryUseCase>();

    final authState = ref.watch(authProvider);
    final user = authState.value?.getCurrentUser();

    if (user == null) {
      return [];
    }

    final result = await _getMealHistory(userId: user.userId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (meals) => meals,
    );
  }

  /// Refresh meal history
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authProvider);
      final user = authState.value?.getCurrentUser();

      if (user == null) {
        return [];
      }

      final result = await _getMealHistory(userId: user.userId);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (meals) => meals,
      );
    });
  }

  /// Get meals for a specific date range
  Future<List<Meal>> getMealsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final authState = ref.read(authProvider);
    final user = authState.value?.getCurrentUser();

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final result = await _getMealHistory(
      userId: user.userId,
      startDate: startDate,
      endDate: endDate,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (meals) => meals,
    );
  }
}

@riverpod
class MealLogger extends _$MealLogger {
  late final LogMealUseCase _logMeal;
  late final UploadImageUseCase _uploadImage;

  @override
  FutureOr<void> build() {
    _logMeal = getIt<LogMealUseCase>();
    _uploadImage = getIt<UploadImageUseCase>();
  }

  /// Log a meal with photo
  Future<Meal> logMeal({
    required File photoFile,
    required MealType mealType,
    String? userNotes,
    DateTime? eatenAt,
  }) async {
    state = const AsyncValue.loading();

    try {
      final authState = ref.read(authProvider);
      final user = authState.value?.getCurrentUser();

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Upload photo to Firebase Storage
      final uploadResult = await _uploadImage(
        file: photoFile,
        userId: user.userId,
        path: 'meals',
      );

      final photoUrl = uploadResult.fold(
        (failure) => throw Exception(failure.message),
        (url) => url,
      );

      // Log meal with analysis
      final result = await _logMeal(
        userId: user.userId,
        photoUrl: photoUrl,
        mealType: mealType,
        userNotes: userNotes,
        eatenAt: eatenAt ?? DateTime.now(),
      );

      final meal = result.fold(
        (failure) => throw Exception(failure.message),
        (meal) => meal,
      );

      // Refresh meal history
      ref.invalidate(mealHistoryProvider);

      state = const AsyncValue.data(null);

      return meal;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

@riverpod
class TodaysMeals extends _$TodaysMeals {
  @override
  Future<List<Meal>> build() async {
    final authState = ref.watch(authProvider);
    final user = authState.value?.getCurrentUser();

    if (user == null) {
      return [];
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final getMealHistory = getIt<GetMealHistoryUseCase>();
    final result = await getMealHistory(
      userId: user.userId,
      startDate: startOfDay,
      endDate: endOfDay,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (meals) => meals,
    );
  }

  /// Refresh today's meals
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
