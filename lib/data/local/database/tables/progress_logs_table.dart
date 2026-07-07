import 'package:drift/drift.dart';

@DataClassName('ProgressLogsTableData')
class ProgressLogsTable extends Table {
  TextColumn get logId => text()();
  TextColumn get userId => text()();

  // Weight tracking
  RealColumn get weightKg => real().nullable()();
  RealColumn get bodyFatPercentage => real().nullable()();

  // Body measurements (optional)
  RealColumn get waistCm => real().nullable()();
  RealColumn get hipsCm => real().nullable()();
  RealColumn get chestCm => real().nullable()();
  RealColumn get armsCm => real().nullable()();
  RealColumn get thighsCm => real().nullable()();

  // Energy and wellness (outcome-focused metrics)
  IntColumn get energyLevel => integer().nullable()(); // 1-5 stars
  IntColumn get sleepQuality => integer().nullable()(); // 1-5 stars
  IntColumn get moodRating => integer().nullable()(); // 1-5 stars
  IntColumn get stressLevel => integer().nullable()(); // 1-5 stars

  // Functional milestones (emotional goal progress)
  TextColumn get functionalMilestones => text()
      .nullable()(); // JSON: ["Climbed 3 flights without breathlessness", "Played with baby for 30 min"]

  // Photos
  TextColumn get photoUrl => text().nullable()();

  // Notes
  TextColumn get notes => text().nullable()();
  TextColumn get aiInsights => text().nullable()(); // AI analysis of progress

  // Timestamps
  DateTimeColumn get loggedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {logId};
}
