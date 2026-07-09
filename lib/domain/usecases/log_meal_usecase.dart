import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/meal.dart';
import '../repositories/meal_repository.dart';

/// Use case for logging a meal with photo
@injectable
class LogMealUseCase {

  const LogMealUseCase(this._repository);
  final MealRepository _repository;

  /// Execute the use case
  ///
  /// [userId] - User logging the meal
  /// [photoUrl] - Firebase Storage URL of meal photo
  /// [mealType] - Type of meal
  /// [userNotes] - Optional user notes
  /// [eatenAt] - When the meal was eaten
  Future<Either<Failure, Meal>> call({
    required String userId,
    required String photoUrl,
    required MealType mealType,
    required DateTime eatenAt, String? userNotes,
  }) async => _repository.logMeal(
      userId: userId,
      photoUrl: photoUrl,
      mealType: mealType,
      userNotes: userNotes,
      eatenAt: eatenAt,
    );
}
