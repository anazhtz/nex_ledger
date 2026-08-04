import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'transactions_table.dart';
import 'projects_table.dart';

/// Deposit liability record — extends a Transaction of type `deposit`.
///
/// NEVER delete or mutate the linked transaction row once created.
/// Adjustments create a NEW income transaction and update [status] and [adjustedAmount] here.
class Deposits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId =>
      integer().references(Transactions, #id, onDelete: KeyAction.restrict)();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.restrict)();
  TextColumn get status => textEnum<DepositStatus>()();

  /// Total portion of this deposit adjusted to income so far.
  RealColumn get adjustedAmount => real().withDefault(const Constant(0.0))();

  /// Invoice / work-order reference the deposit was applied against.
  TextColumn get adjustmentReference => text().nullable()();
}
