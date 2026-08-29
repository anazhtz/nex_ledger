import 'package:drift/drift.dart';
import 'projects_table.dart';
import 'transactions_table.dart';

/// Client Running Account (RA) Bills table — progressive billing to the client.
class ClientRaBills extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId =>
      integer().references(Transactions, #id, onDelete: KeyAction.cascade)();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.cascade)();

  TextColumn get billNumber => text().withLength(min: 1, max: 50)();
  DateTimeColumn get billDate => dateTime()();
  TextColumn get stageOrDescription => text().withLength(min: 1, max: 500)();

  RealColumn get grossAmount => real()();
  RealColumn get retentionPercentage => real().withDefault(const Constant(5.0))();
  RealColumn get retentionAmount => real().withDefault(const Constant(0.0))();
  RealColumn get advanceDeduction => real().withDefault(const Constant(0.0))();
  RealColumn get taxOrTdsDeduction => real().withDefault(const Constant(0.0))();
  RealColumn get netCertifiedAmount => real()();

  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
