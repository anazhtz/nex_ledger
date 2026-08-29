import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'bank_accounts_table.dart';
import 'subcontractors_table.dart';
import 'transactions_table.dart';
import 'work_orders_table.dart';

/// SubcontractPayments table — payments, site running advances, and retention releases to subcontractors.
class SubcontractPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId => integer().references(Transactions, #id)();
  IntColumn get subcontractorId => integer().references(Subcontractors, #id)();
  IntColumn get workOrderId => integer().nullable().references(WorkOrders, #id)();
  RealColumn get amount => real()();
  DateTimeColumn get paymentDate => dateTime()();
  TextColumn get paymentMode => textEnum<PaymentMode>()();
  IntColumn get bankAccountId => integer().nullable().references(BankAccounts, #id)();
  BoolColumn get isRetentionRelease => boolean().withDefault(const Constant(false))();
  BoolColumn get isAdvance => boolean().withDefault(const Constant(false))();
  TextColumn get referenceNo => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
