import 'package:drift/drift.dart';

@DataClassName('MealsTableData')
class MealsTable extends Table {
  TextColumn get mealId => text()();
  TextColumn get userId => text()();

  // Meal details
  TextColumn get mealType => text()(); // breakfast, lunch, dinner, snack
  TextColumn get mealName => text()();
  TextColumn get description => text().nullable()();

  // Photo logging
  TextColumn get photoUrl => text().nullable()();
  BoolColumn get isPhotoLogged =>
      boolean().withDefault(const Constant(false))();

  // Nutritional info (aggregated from meal items)
  RealColumn get totalCalories => real()();
  RealColumn get totalProteinG => real().withDefault(const Constant(0))();
  RealColumn get totalCarbsG => real().withDefault(const Constant(0))();
  RealColumn get totalFatsG => real().withDefault(const Constant(0))();

  // AI analysis
  TextColumn get aiAnalysis => text().nullable()(); // JSON string from Claude
  TextColumn get aiSuggestions => text().nullable()();

  // Timing
  DateTimeColumn get loggedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {mealId};
}
