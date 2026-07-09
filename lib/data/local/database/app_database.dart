import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_constants.dart';
import 'tables/chat_messages_table.dart';
import 'tables/goals_table.dart';
import 'tables/meal_items_table.dart';
import 'tables/meals_table.dart';
import 'tables/progress_logs_table.dart';
import 'tables/reminders_table.dart';
import 'tables/user_profiles_table.dart';
import 'tables/workout_exercises_table.dart';
import 'tables/workout_logs_table.dart';
import 'tables/workouts_table.dart';

part 'app_database.g.dart';

@lazySingleton
@DriftDatabase(
  tables: [
    UserProfilesTable,
    GoalsTable,
    ChatMessagesTable,
    MealsTable,
    MealItemsTable,
    WorkoutsTable,
    WorkoutExercisesTable,
    WorkoutLogsTable,
    ProgressLogsTable,
    RemindersTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => AppConstants.databaseVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        // Add migration logic here when schema changes
      },
    );

  // User Profile queries
  Future<UserProfilesTableData?> getUserProfile(String userId) => (select(userProfilesTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .getSingleOrNull();

  Future<int> insertUserProfile(UserProfilesTableCompanion profile) => into(userProfilesTable).insert(profile);

  Future<bool> updateUserProfile(UserProfilesTableCompanion profile) => update(userProfilesTable).replace(profile);

  // Goals queries
  Stream<List<GoalsTableData>> watchGoalsByUserId(String userId) => (select(goalsTable)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();

  Future<int> insertGoal(GoalsTableCompanion goal) => into(goalsTable).insert(goal);

  Future<bool> updateGoal(GoalsTableCompanion goal) => update(goalsTable).replace(goal);

  // Chat messages queries
  Stream<List<ChatMessagesTableData>> watchChatMessages(String userId) => (select(chatMessagesTable)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)]))
        .watch();

  Future<int> insertChatMessage(ChatMessagesTableCompanion message) => into(chatMessagesTable).insert(message);

  // Meals queries
  Stream<List<MealsTableData>> watchMealsByDate(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) => (select(mealsTable)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.loggedAt.isBiggerOrEqualValue(startDate) &
              tbl.loggedAt.isSmallerOrEqualValue(endDate),)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.loggedAt)]))
        .watch();

  Future<int> insertMeal(MealsTableCompanion meal) => into(mealsTable).insert(meal);

  Future<MealsTableData?> getMeal(String mealId) => (select(mealsTable)..where((tbl) => tbl.mealId.equals(mealId)))
        .getSingleOrNull();

  // Meal items queries
  Stream<List<MealItemsTableData>> watchMealItems(String mealId) => (select(mealItemsTable)..where((tbl) => tbl.mealId.equals(mealId)))
        .watch();

  Future<int> insertMealItem(MealItemsTableCompanion mealItem) => into(mealItemsTable).insert(mealItem);

  // Workouts queries
  Stream<List<WorkoutsTableData>> watchWorkouts(String userId) => (select(workoutsTable)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();

  Future<int> insertWorkout(WorkoutsTableCompanion workout) => into(workoutsTable).insert(workout);

  Future<WorkoutsTableData?> getWorkout(String workoutId) => (select(workoutsTable)
          ..where((tbl) => tbl.workoutId.equals(workoutId)))
        .getSingleOrNull();

  // Workout exercises queries
  Stream<List<WorkoutExercisesTableData>> watchWorkoutExercises(
    String workoutId,
  ) => (select(workoutExercisesTable)
          ..where((tbl) => tbl.workoutId.equals(workoutId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
        .watch();

  Future<int> insertWorkoutExercise(
    WorkoutExercisesTableCompanion exercise,
  ) => into(workoutExercisesTable).insert(exercise);

  // Workout logs queries
  Stream<List<WorkoutLogsTableData>> watchWorkoutLogs(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) => (select(workoutLogsTable)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.completedAt.isBiggerOrEqualValue(startDate) &
              tbl.completedAt.isSmallerOrEqualValue(endDate),)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.completedAt)]))
        .watch();

  Future<int> insertWorkoutLog(WorkoutLogsTableCompanion log) => into(workoutLogsTable).insert(log);

  // Progress logs queries
  Stream<List<ProgressLogsTableData>> watchProgressLogs(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) => (select(progressLogsTable)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.loggedAt.isBiggerOrEqualValue(startDate) &
              tbl.loggedAt.isSmallerOrEqualValue(endDate),)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.loggedAt)]))
        .watch();

  Future<int> insertProgressLog(ProgressLogsTableCompanion log) => into(progressLogsTable).insert(log);

  // Reminders queries
  Stream<List<RemindersTableData>> watchReminders(String userId) => (select(remindersTable)
          ..where(
              (tbl) => tbl.userId.equals(userId) & tbl.isActive.equals(true),)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.reminderTime)]))
        .watch();

  Future<int> insertReminder(RemindersTableCompanion reminder) => into(remindersTable).insert(reminder);

  Future<bool> updateReminder(RemindersTableCompanion reminder) => update(remindersTable).replace(reminder);

  Future<int> deleteReminder(String reminderId) => (delete(remindersTable)
          ..where((tbl) => tbl.reminderId.equals(reminderId)))
        .go();
}

LazyDatabase _openConnection() => LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.databaseName));
    return NativeDatabase(file);
  });
