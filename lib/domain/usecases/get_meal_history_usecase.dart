import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/meal.dart';
import '../repositories/meal_repository.dart';

/// Use case for fetching meal history
@injectable
class GetMealHistoryUseCase {
  final MealRepository _repository;

  const GetMealHistoryUseCase(this._repository);

  /// Execute the use case
  ///
  /// [userId] - User whose meals to fetch
  /// [startDate] - Start of date range (optional)
  /// [endDate] - End of date range (optional)
  /// [limit] - Maximum number of meals
  Future<Either<Failure, List<Meal>>> call({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    return await _repository.getMealHistory(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }
}
