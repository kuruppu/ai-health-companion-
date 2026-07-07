import 'package:drift/drift.dart';

@DataClassName('WorkoutLogsTableData')
class WorkoutLogsTable extends Table {
  TextColumn get logId => text()();
  TextColumn get userId => text()();
  TextColumn get workoutId => text()();

  // Workout completion details
  IntColumn get actualDurationMinutes => integer()();
  IntColumn get completedExercises => integer()();
  IntColumn get totalExercises => integer()();
  RealColumn get completionPercentage => real()();

  // Performance metrics
  TextColumn get intensity =>
      text()(); // how_did_it_feel: easy, moderate, challenging, very_hard
  IntColumn get energyBefore => integer().nullable()(); // 1-5 stars
  IntColumn get energyAfter => integer().nullable()(); // 1-5 stars

  // User feedback
  TextColumn get userNotes => text().nullable()();
  TextColumn get painOrDiscomfort => text().nullable()();
  BoolColumn get enjoyedWorkout => boolean().nullable()();

  // AI feedback
  TextColumn get aiFeedback => text().nullable()();
  TextColumn get aiNextSteps => text().nullable()();

  // Timestamps
  DateTimeColumn get completedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {logId};
}
