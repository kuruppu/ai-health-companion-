import 'package:drift/drift.dart';

/// Meals table for photo-first meal logging (Milestone 4)
@DataClassName('Meal')
class MealsTable extends Table {
  /// Unique meal identifier
  TextColumn get mealId => text()();

  /// User who logged the meal
  TextColumn get userId => text()();

  /// Meal type (breakfast, lunch, dinner, snack)
  TextColumn get mealType => text()();

  /// Photo URL from Firebase Storage (REQUIRED for photo-first)
  TextColumn get photoUrl => text()();

  /// Optional user notes/context
  TextColumn get userNotes => text().nullable()();

  /// AI analysis from Claude (stored as JSON string)
  /// Contains: description, portionSize, foodCategories, healthScore,
  /// feedback, suggestions, nutritionalEstimate
  TextColumn get analysisJson => text()();

  /// When the meal was logged
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();

  /// When the meal was actually eaten (can differ from timestamp)
  DateTimeColumn get eatenAt => dateTime()();

  @override
  Set<Column> get primaryKey => {mealId};

  @override
  List<Set<Column>> get uniqueKeys => [];
}
