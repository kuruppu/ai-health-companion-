import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/meal.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/meal_local_datasource.dart';
import '../datasources/meal_remote_datasource.dart';
import '../models/meal_model.dart';

@Injectable(as: MealRepository)
class MealRepositoryImpl implements MealRepository {

  const MealRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._uuid,
  );
  final MealRemoteDataSource _remoteDataSource;
  final MealLocalDataSource _localDataSource;
  final Uuid _uuid;

  @override
  Future<Either<Failure, Meal>> logMeal({
    required String userId,
    required String photoUrl,
    required MealType mealType,
    required DateTime eatenAt, String? userNotes,
  }) async {
    try {
      // Analyze meal photo using Claude Vision
      final analysis = await _remoteDataSource.analyzeMealPhoto(
        userId: userId,
        photoUrl: photoUrl,
        mealType: mealType,
        userNotes: userNotes,
      );

      // Create meal entity
      final meal = MealModel(
        mealId: _uuid.v4(),
        userId: userId,
        mealType: mealType,
        photoUrl: photoUrl,
        userNotes: userNotes,
        analysis: analysis,
        timestamp: DateTime.now(),
        eatenAt: eatenAt,
      );

      // Save to local database
      await _localDataSource.saveMeal(meal);

      // Save to Firestore (fire and forget)
      unawaited(
        _remoteDataSource.saveMealToFirestore(meal).catchError((error) {
          // Log error but don't fail the operation
          AppLogger.e('Failed to save meal to Firestore', error: error);
        }),
      );

      return Right(meal.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Meal>>> getMealHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      // Try local first
      final localMeals = await _localDataSource.getMeals(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      if (localMeals.isNotEmpty) {
        return Right(localMeals.map((m) => m.toEntity()).toList());
      }

      // Fallback to remote
      final remoteMeals = await _remoteDataSource.fetchMealsFromFirestore(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      // Cache locally
      for (final meal in remoteMeals) {
        await _localDataSource.saveMeal(meal);
      }

      return Right(remoteMeals.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Meal>>> getTodaysMeals({
    required String userId,
  }) async {
    try {
      final meals = await _localDataSource.getTodaysMeals(userId: userId);
      return Right(meals.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Meal>> getMealById({
    required String mealId,
  }) async {
    try {
      final meal = await _localDataSource.getMealById(mealId: mealId);

      if (meal == null) {
        return const Left(CacheFailure(message: 'Meal not found'));
      }

      return Right(meal.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMeal({
    required String mealId,
  }) async {
    try {
      // Delete from local
      await _localDataSource.deleteMeal(mealId: mealId);

      // Delete from remote (fire and forget)
      unawaited(_remoteDataSource.deleteMealFromFirestore(mealId).catchError((error) {
        AppLogger.e('Failed to delete meal from Firestore', error: error);
      }));

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Meal>> updateMealNotes({
    required String mealId,
    required String userNotes,
  }) async {
    try {
      await _localDataSource.updateMealNotes(
        mealId: mealId,
        userNotes: userNotes,
      );

      final meal = await _localDataSource.getMealById(mealId: mealId);

      if (meal == null) {
        return const Left(CacheFailure(message: 'Meal not found'));
      }

      return Right(meal.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Stream<Meal> watchMeals({required String userId}) {
    // TODO: Implement Firestore real-time listener
    throw UnimplementedError('Real-time meal watching not yet implemented');
  }
}
