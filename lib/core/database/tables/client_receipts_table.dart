import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'bank_accounts_table.dart';
import 'client_ra_bills_table.dart';
import 'projects_table.dart';
import 'transactions_table.dart';

/// Client Receipts & Collections table — tracking payments received from clients.
class ClientReceipts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId =>
      integer().references(Transactions, #id, onDelete: KeyAction.cascade)();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  IntColumn get clientRaBillId =>
      integer().nullable().references(ClientRaBills, #id, onDelete: KeyAction.setNull)();

  DateTimeColumn get receiptDate => dateTime()();
  RealColumn get amount => real()();

  TextColumn get paymentMode => textEnum<PaymentMode>()();
  IntColumn get bankAccountId =>
      integer().nullable().references(BankAccounts, #id, onDelete: KeyAction.setNull)();

  BoolColumn get isAdvance => boolean().withDefault(const Constant(false))();
  BoolColumn get isRetentionRelease => boolean().withDefault(const Constant(false))();

  TextColumn get referenceNo => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
