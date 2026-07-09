import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/meal.dart';

/// Repository interface for meal operations
abstract class MealRepository {
  /// Log a meal with photo and optional notes
  ///
  /// [userId] - User who is logging the meal
  /// [photoUrl] - Firebase Storage URL of the meal photo
  /// [mealType] - Type of meal (breakfast, lunch, dinner, snack)
  /// [userNotes] - Optional user description/context
  /// [eatenAt] - When the meal was actually eaten
  ///
  /// Returns the logged meal with AI analysis
  Future<Either<Failure, Meal>> logMeal({
    required String userId,
    required String photoUrl,
    required MealType mealType,
    required DateTime eatenAt, String? userNotes,
  });

  /// Get meal history for a user
  ///
  /// [userId] - User whose meals to fetch
  /// [startDate] - Start of date range (optional)
  /// [endDate] - End of date range (optional)
  /// [limit] - Maximum number of meals to return
  ///
  /// Returns list of meals ordered by eatenAt descending
  Future<Either<Failure, List<Meal>>> getMealHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  /// Get meals for today
  ///
  /// [userId] - User whose meals to fetch
  ///
  /// Returns list of today's meals
  Future<Either<Failure, List<Meal>>> getTodaysMeals({
    required String userId,
  });

  /// Get a specific meal by ID
  ///
  /// [mealId] - ID of the meal to fetch
  ///
  /// Returns the meal if found
  Future<Either<Failure, Meal>> getMealById({
    required String mealId,
  });

  /// Delete a meal
  ///
  /// [mealId] - ID of the meal to delete
  ///
  /// Returns unit on success
  Future<Either<Failure, Unit>> deleteMeal({
    required String mealId,
  });

  /// Update meal notes
  ///
  /// [mealId] - ID of the meal to update
  /// [userNotes] - New notes
  ///
  /// Returns updated meal
  Future<Either<Failure, Meal>> updateMealNotes({
    required String mealId,
    required String userNotes,
  });

  /// Stream of meal updates
  ///
  /// [userId] - User whose meals to watch
  ///
  /// Emits whenever a new meal is logged
  Stream<Meal> watchMeals({required String userId});
}
