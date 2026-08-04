import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';

/// Projects table — master list of projects & overhead entries.
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().withLength(min: 1, max: 50).unique()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get clientName => text().nullable()();

  /// ProjectType enum stored as text
  TextColumn get type => textEnum<ProjectType>()();

  /// ProjectStatus enum stored as text
  TextColumn get status => textEnum<ProjectStatus>()();

  DateTimeColumn get startDate => dateTime()();
  RealColumn get budget => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
