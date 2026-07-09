import 'package:drift/drift.dart';

@DataClassName('RemindersTableData')
class RemindersTable extends Table {
  TextColumn get reminderId => text()();
  TextColumn get userId => text()();

  // Reminder details
  TextColumn get reminderType =>
      text()(); // water, standing, workout, meal, weight_log, custom
  TextColumn get title => text()();
  TextColumn get message => text().nullable()();

  // Scheduling
  DateTimeColumn get reminderTime => dateTime()();
  TextColumn get frequency => text()(); // once, daily, weekly, custom
  TextColumn get repeatPattern =>
      text().nullable()(); // JSON: days of week, interval

  // Settings
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isAdaptive => boolean()
      .withDefault(const Constant(false))(); // Learns from user behavior

  // Quiet hours
  DateTimeColumn get quietHoursStart => dateTime().nullable()();
  DateTimeColumn get quietHoursEnd => dateTime().nullable()();

  // Smart features
  BoolColumn get skipWeekends => boolean().withDefault(const Constant(false))();
  BoolColumn get contextAware => boolean().withDefault(
      const Constant(false),)(); // Adapt based on location, activity

  // Tracking
  IntColumn get totalSent => integer().withDefault(const Constant(0))();
  IntColumn get totalDismissed => integer().withDefault(const Constant(0))();
  IntColumn get totalActedUpon => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSentAt => dateTime().nullable()();
  DateTimeColumn get lastActedAt => dateTime().nullable()();

  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {reminderId};
}
