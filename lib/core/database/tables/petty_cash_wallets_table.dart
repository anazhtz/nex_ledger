import 'package:drift/drift.dart';
import 'projects_table.dart';

@DataClassName('PettyCashWallet')
class PettyCashWallets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get supervisorName => text().withLength(min: 1, max: 120)();
  TextColumn get phone => text().withLength(min: 1, max: 40)();
  IntColumn get assignedProjectId => integer().nullable().references(Projects, #id, onDelete: KeyAction.setNull)();
  RealColumn get maxFloatLimit => real().withDefault(const Constant(50000.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
