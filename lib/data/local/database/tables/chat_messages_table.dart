import 'package:drift/drift.dart';

@DataClassName('ChatMessagesTableData')
class ChatMessagesTable extends Table {
  TextColumn get messageId => text()();
  TextColumn get userId => text()();

  // Message content
  TextColumn get role => text()(); // user, assistant
  TextColumn get content => text()();
  TextColumn get messageType => text().withDefault(const Constant('text'))(); // text, image, voice

  // Metadata
  TextColumn get imageUrl => text().nullable()(); // For meal photos
  TextColumn get audioUrl => text().nullable()(); // For voice messages
  IntColumn get tokenCount => integer().nullable()();

  // Context tracking
  TextColumn get context => text().nullable()(); // JSON string for conversation context
  BoolColumn get isImportant => boolean().withDefault(const Constant(false))();

  // Timestamp
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {messageId};
}
