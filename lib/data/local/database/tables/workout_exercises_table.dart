import 'package:drift/drift.dart';

@DataClassName('WorkoutExercisesTableData')
class WorkoutExercisesTable extends Table {
  TextColumn get exerciseId => text()();
  TextColumn get workoutId => text()();

  // Exercise details
  TextColumn get exerciseName => text()();
  TextColumn get exerciseType =>
      text()(); // strength, cardio, stretching, yoga_pose
  TextColumn get muscleGroup =>
      text().nullable()(); // core, upper_body, lower_body, full_body

  // Sets and reps
  IntColumn get sets => integer().withDefault(const Constant(1))();
  IntColumn get reps => integer().nullable()(); // For strength exercises
  IntColumn get durationSeconds =>
      integer().nullable()(); // For holds, planks, cardio

  // Instructions
  TextColumn get instructions => text().nullable()();
  TextColumn get videoUrl => text().nullable()();
  TextColumn get imageUrl => text().nullable()();

  // Progression
  RealColumn get difficultyLevel =>
      real().withDefault(const Constant(1.0))(); // 1.0 to 5.0
  TextColumn get progressionNotes => text().nullable()();

  // Order in workout
  IntColumn get orderIndex => integer()();

  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {exerciseId};
}
