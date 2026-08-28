import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'transactions_table.dart';
import 'projects_table.dart';

/// Deposit tracking record — extends a Transaction of type `depositPaid` or `deposit`.
///
/// Supports both:
/// 1. Deposit Paid to Govt / Client (Asset, Outflow -> Recovered back as Inflow, P&L = 0)
/// 2. Deposit Received from Client (Liability, Inflow -> Refunded or Adjusted to income)
///
/// NEVER delete or mutate the linked transaction row once created.
class Deposits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId =>
      integer().references(Transactions, #id, onDelete: KeyAction.restrict)();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.restrict)();
  TextColumn get depositType =>
      textEnum<DepositType>().withDefault(Constant(DepositType.paid.name))();
  TextColumn get status => textEnum<DepositStatus>()();

  /// Total portion of this deposit recovered (if paid) or adjusted to income (if received) so far.
  RealColumn get adjustedAmount => real().withDefault(const Constant(0.0))();

  /// FDR / EMD / Challan / Work-order / Invoice reference.
  TextColumn get adjustmentReference => text().nullable()();
}
