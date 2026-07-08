import 'package:drift/drift.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../local/database/app_database.dart';
import '../models/meal_model.dart';

/// Local data source for meal persistence (SQLite + Hive)
@injectable
class MealLocalDataSource {
  final AppDatabase _database;
  final Box<Map<dynamic, dynamic>> _mealCache;

  const MealLocalDataSource(
    this._database,
    @Named('mealCache') this._mealCache,
  );

  /// Save meal to SQLite
  Future<void> saveMeal(MealModel meal) async {
    await _database.into(_database.meals).insert(
          MealsCompanion(
            mealId: Value(meal.mealId),
            userId: Value(meal.userId),
            mealType: Value(meal.mealType.name),
            photoUrl: Value(meal.photoUrl),
            userNotes: Value(meal.userNotes),
            analysisJson: Value(meal.analysis.toString()),
            timestamp: Value(meal.timestamp),
            eatenAt: Value(meal.eatenAt),
          ),
          mode: InsertMode.insertOrReplace,
        );

    // Also cache in Hive for faster access
    await _cacheMeal(meal);
  }

  /// Get meals from SQLite
  Future<List<MealModel>> getMeals({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    // Try cache first
    final cachedMeals = await _getCachedMeals(userId);
    if (cachedMeals.isNotEmpty && startDate == null && endDate == null) {
      return cachedMeals.take(limit).toList();
    }

    // Fallback to database
    var query = _database.select(_database.meals)
      ..where((tbl) => tbl.userId.equals(userId))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.eatenAt, mode: OrderingMode.desc)
      ])
      ..limit(limit);

    if (startDate != null) {
      query = query
        ..where((tbl) => tbl.eatenAt.isBiggerOrEqualValue(startDate));
    }

    if (endDate != null) {
      query = query..where((tbl) => tbl.eatenAt.isSmallerOrEqualValue(endDate));
    }

    final rows = await query.get();
    return rows.map((row) => _mealFromDriftRow(row)).toList();
  }

  /// Get today's meals
  Future<List<MealModel>> getTodaysMeals({required String userId}) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await getMeals(
      userId: userId,
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// Get meal by ID
  Future<MealModel?> getMealById({required String mealId}) async {
    final query = _database.select(_database.meals)
      ..where((tbl) => tbl.mealId.equals(mealId));

    final row = await query.getSingleOrNull();
    return row != null ? _mealFromDriftRow(row) : null;
  }

  /// Delete meal from SQLite
  Future<void> deleteMeal({required String mealId}) async {
    await (_database.delete(_database.meals)
          ..where((tbl) => tbl.mealId.equals(mealId)))
        .go();

    // Remove from cache
    await _removeCachedMeal(mealId);
  }

  /// Update meal notes
  Future<void> updateMealNotes({
    required String mealId,
    required String userNotes,
  }) async {
    await (_database.update(_database.meals)
          ..where((tbl) => tbl.mealId.equals(mealId)))
        .write(MealsCompanion(userNotes: Value(userNotes)));

    // Update cache
    final meal = await getMealById(mealId: mealId);
    if (meal != null) {
      await _cacheMeal(meal);
    }
  }

  /// Cache meal in Hive
  Future<void> _cacheMeal(MealModel meal) async {
    final cacheKey = '${meal.userId}_meals';
    final cached = _mealCache.get(cacheKey, defaultValue: <dynamic, dynamic>{})
        as Map<dynamic, dynamic>;

    cached[meal.mealId] = meal.toJson();

    // Keep only last 50 meals per user
    if (cached.length > 50) {
      final sortedKeys = cached.keys.toList()
        ..sort((a, b) {
          final mealA = MealModel.fromJson(cached[a] as Map<String, dynamic>);
          final mealB = MealModel.fromJson(cached[b] as Map<String, dynamic>);
          return mealB.eatenAt.compareTo(mealA.eatenAt);
        });

      final keysToRemove = sortedKeys.skip(50);
      for (final key in keysToRemove) {
        cached.remove(key);
      }
    }

    await _mealCache.put(cacheKey, cached);
  }

  /// Get cached meals
  Future<List<MealModel>> _getCachedMeals(String userId) async {
    final cacheKey = '${userId}_meals';
    final cached = _mealCache.get(cacheKey, defaultValue: <dynamic, dynamic>{})
        as Map<dynamic, dynamic>;

    final meals = cached.values
        .map((json) => MealModel.fromJson(json as Map<String, dynamic>))
        .toList();

    meals.sort((a, b) => b.eatenAt.compareTo(a.eatenAt));
    return meals;
  }

  /// Remove cached meal
  Future<void> _removeCachedMeal(String mealId) async {
    for (final key in _mealCache.keys) {
      final cached =
          _mealCache.get(key, defaultValue: <dynamic, dynamic>{}) as Map;
      if (cached.containsKey(mealId)) {
        cached.remove(mealId);
        await _mealCache.put(key, cached);
        break;
      }
    }
  }

  /// Convert Drift row to MealModel
  MealModel _mealFromDriftRow(Meal row) {
    return MealModel.fromDrift({
      'meal_id': row.mealId,
      'user_id': row.userId,
      'meal_type': row.mealType,
      'photo_url': row.photoUrl,
      'user_notes': row.userNotes,
      'analysis': row.analysisJson,
      'timestamp': row.timestamp.millisecondsSinceEpoch,
      'eaten_at': row.eatenAt.millisecondsSinceEpoch,
    });
  }
}
