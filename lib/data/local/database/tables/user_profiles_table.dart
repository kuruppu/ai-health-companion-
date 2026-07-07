import 'package:drift/drift.dart';

@DataClassName('UserProfilesTableData')
class UserProfilesTable extends Table {
  TextColumn get userId => text()();
  TextColumn get firebaseUid => text()();
  TextColumn get email => text()();
  TextColumn get displayName => text()();
  TextColumn get photoUrl => text().nullable()();

  // Physical attributes
  IntColumn get age => integer().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get currentWeightKg => real().nullable()();
  RealColumn get goalWeightKg => real().nullable()();
  TextColumn get gender => text().nullable()();

  // Health goals
  TextColumn get emotionalGoal => text().nullable()();
  TextColumn get activityLevel => text().nullable()();
  TextColumn get dietaryPreferences => text().nullable()();

  // Calculated fields
  RealColumn get dailyCaloricTarget => real().nullable()();
  RealColumn get proteinGrams => real().nullable()();
  RealColumn get carbsGrams => real().nullable()();
  RealColumn get fatsGrams => real().nullable()();
  RealColumn get waterIntakeMl => real().nullable()();

  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {userId};
}
