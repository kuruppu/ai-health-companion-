import 'package:drift/drift.dart';

@DataClassName('WorkoutsTableData')
class WorkoutsTable extends Table {
  TextColumn get workoutId => text()();
  TextColumn get userId => text()();

  // Workout details
  TextColumn get workoutName => text()();
  TextColumn get workoutType =>
      text()(); // strength, cardio, yoga, stretching, mobility, recovery
  TextColumn get intensity => text()(); // low, medium, high
  IntColumn get durationMinutes => integer()();
  IntColumn get estimatedCaloriesBurn => integer().nullable()();

  // Description
  TextColumn get description => text().nullable()();
  TextColumn get instructions => text().nullable()();

  // AI generated
  BoolColumn get isAiGenerated =>
      boolean().withDefault(const Constant(false))();
  TextColumn get aiContext =>
      text().nullable()(); // Why this workout was recommended

  // Scheduling
  DateTimeColumn get scheduledFor => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {workoutId};
}
