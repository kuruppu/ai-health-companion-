import 'package:drift/drift.dart';

@DataClassName('MealItemsTableData')
class MealItemsTable extends Table {
  TextColumn get itemId => text()();
  TextColumn get mealId => text()();

  // Food details
  TextColumn get foodName => text()();
  TextColumn get foodNameSinhala => text().nullable()();
  TextColumn get category => text().nullable()(); // rice, curry, vegetable, protein, etc

  // Portion
  RealColumn get portionSize => real()(); // Standard serving size
  TextColumn get portionUnit => text()(); // cup, spoon, piece, plate
  RealColumn get quantity => real().withDefault(const Constant(1.0))();

  // Nutritional values (per portion)
  RealColumn get caloriesPerPortion => real()();
  RealColumn get proteinG => real().withDefault(const Constant(0.0))();
  RealColumn get carbsG => real().withDefault(const Constant(0.0))();
  RealColumn get fatsG => real().withDefault(const Constant(0.0))();

  // Total values (portion * quantity)
  RealColumn get totalCalories => real()();
  RealColumn get totalProteinG => real().withDefault(const Constant(0.0))();
  RealColumn get totalCarbsG => real().withDefault(const Constant(0.0))();
  RealColumn get totalFatsG => real().withDefault(const Constant(0.0))();

  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {itemId};
}
