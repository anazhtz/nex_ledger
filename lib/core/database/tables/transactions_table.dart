import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'projects_table.dart';

/// Unified transaction ledger — every money movement goes here.
///
/// CRITICAL: [affectsPnl] MUST be false for deposit/depositRefund rows.
/// All P&L reports filter WHERE affectsPnl = true.
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.restrict)();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => textEnum<TransactionType>()();

  /// FALSE for deposit / depositRefund transactions — they are liabilities,
  /// not income. TRUE for income/expense/purchase/labourPayment.
  BoolColumn get affectsPnl => boolean().withDefault(const Constant(true))();

  /// FALSE for internal adjustments (e.g. deposit adjusted to income) that do NOT move physical cash.
  /// TRUE for physical cash inflows/outflows.
  BoolColumn get affectsCash => boolean().withDefault(const Constant(true))();

  RealColumn get amount => real()();
  TextColumn get paymentMode => textEnum<PaymentMode>().nullable()();
  TextColumn get narration => text().nullable()();
  TextColumn get referenceNo => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
