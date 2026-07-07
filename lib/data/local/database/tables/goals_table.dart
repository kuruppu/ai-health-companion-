import 'package:drift/drift.dart';

@DataClassName('GoalsTableData')
class GoalsTable extends Table {
  TextColumn get goalId => text()();
  TextColumn get userId => text()();

  // Goal details
  TextColumn get goalType => text()(); // weight_loss, muscle_gain, maintenance, energy, fitness
  TextColumn get emotionalGoal => text()(); // "Play with baby without getting tired"
  RealColumn get targetValue => real().nullable()(); // Target weight or metric
  RealColumn get currentValue => real().nullable()(); // Current progress
  TextColumn get unit => text().nullable()(); // kg, %, minutes, etc

  // Timeline
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get targetDate => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  // Progress tracking
  RealColumn get progressPercentage => real().withDefault(const Constant(0.0))();
  TextColumn get status => text().withDefault(const Constant('active'))(); // active, completed, abandoned

  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {goalId};
}
