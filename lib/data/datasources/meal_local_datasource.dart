import 'package:drift/drift.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../local/database/app_database.dart';
import '../models/meal_model.dart';

/// Local data source for meal persistence (SQLite + Hive)
@injectable
class MealLocalDataSource {

  const MealLocalDataSource(
    this._database,
    @Named('mealCache') this._mealCache,
  );
  final AppDatabase _database;
  final Box<Map<dynamic, dynamic>> _mealCache;

  /// Save meal to SQLite
  /// TODO: Fix schema mismatch - table expects different fields
  Future<void> saveMeal(MealModel meal) async {
    await _database.into(_database.mealsTable).insert(
          MealsTableCompanion(
            mealId: Value(meal.mealId),
            userId: Value(meal.userId),
            mealType: Value(meal.mealType.name),
            mealName: const Value('Meal'), // TODO: Get from analysis or user input
            totalCalories: const Value(0), // TODO: Calculate from analysis
            photoUrl: Value(meal.photoUrl),
            description: Value(meal.userNotes), // Map userNotes to description
            aiAnalysis: Value(meal.analysis.toString()), // Changed from analysisJson
            loggedAt: Value(meal.loggedAt), // Removed timestamp
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
    var query = _database.select(_database.mealsTable)
      ..where((tbl) => tbl.userId.equals(userId))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.loggedAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    if (startDate != null) {
      query = query
        ..where((tbl) => tbl.loggedAt.isBiggerOrEqualValue(startDate));
    }

    if (endDate != null) {
      query = query..where((tbl) => tbl.loggedAt.isSmallerOrEqualValue(endDate));
    }

    final rows = await query.get();
    return rows.map(_mealFromDriftRow).toList();
  }

  /// Get today's meals
  Future<List<MealModel>> getTodaysMeals({required String userId}) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getMeals(
      userId: userId,
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// Get meal by ID
  Future<MealModel?> getMealById({required String mealId}) async {
    final query = _database.select(_database.mealsTable)
      ..where((tbl) => tbl.mealId.equals(mealId));

    final row = await query.getSingleOrNull();
    return row != null ? _mealFromDriftRow(row) : null;
  }

  /// Delete meal from SQLite
  Future<void> deleteMeal({required String mealId}) async {
    await (_database.delete(_database.mealsTable)
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
    await (_database.update(_database.mealsTable)
          ..where((tbl) => tbl.mealId.equals(mealId)))
        .write(MealsTableCompanion(description: Value(userNotes))); // Changed to description

    // Update cache
    final meal = await getMealById(mealId: mealId);
    if (meal != null) {
      await _cacheMeal(meal);
    }
  }

  /// Cache meal in Hive
  Future<void> _cacheMeal(MealModel meal) async {
    final cacheKey = '${meal.userId}_meals';
    final cached = _mealCache.get(cacheKey, defaultValue: <dynamic, dynamic>{})!;

    cached[meal.mealId] = meal.toJson();

    // Keep only last 50 meals per user
    if (cached.length > 50) {
      final sortedKeys = cached.keys.toList()
        ..sort((a, b) {
          final mealA = MealModel.fromJson(cached[a] as Map<String, dynamic>);
          final mealB = MealModel.fromJson(cached[b] as Map<String, dynamic>);
          return mealB.loggedAt.compareTo(mealA.loggedAt);
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
    final cached = _mealCache.get(cacheKey, defaultValue: <dynamic, dynamic>{})!;

    final meals = cached.values
        .map((json) => MealModel.fromJson(json as Map<String, dynamic>))
        .toList();

    meals.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    return meals;
  }

  /// Remove cached meal
  Future<void> _removeCachedMeal(String mealId) async {
    for (final key in _mealCache.keys) {
      final cached =
          _mealCache.get(key, defaultValue: <dynamic, dynamic>{})!;
      if (cached.containsKey(mealId)) {
        cached.remove(mealId);
        await _mealCache.put(key, cached);
        break;
      }
    }
  }

  /// Convert Drift row to MealModel
  MealModel _mealFromDriftRow(MealsTableData row) => // Changed from Meal
      MealModel.fromDrift({
        'meal_id': row.mealId,
        'user_id': row.userId,
        'meal_type': row.mealType,
        'photo_url': row.photoUrl,
        'user_notes': row.description, // Changed from row.userNotes
        'analysis': row.aiAnalysis, // Changed from row.analysisJson
        'timestamp': row.createdAt.millisecondsSinceEpoch, // Changed from row.timestamp
        'eaten_at': row.loggedAt.millisecondsSinceEpoch,
      });
}
