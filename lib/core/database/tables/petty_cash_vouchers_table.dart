import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'bank_accounts_table.dart';
import 'petty_cash_wallets_table.dart';
import 'projects_table.dart';
import 'transactions_table.dart';

@DataClassName('PettyCashVoucher')
class PettyCashVouchers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get walletId => integer().references(PettyCashWallets, #id, onDelete: KeyAction.cascade)();
  IntColumn get projectId => integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => textEnum<PettyCashTxnType>()();
  DateTimeColumn get date => dateTime()();
  RealColumn get amount => real()();
  TextColumn get category => text().withDefault(const Constant('Worker Tea, Food & Refreshments'))();
  TextColumn get costHead => textEnum<BudgetCostHead>().withDefault(Constant(BudgetCostHead.equipmentOverhead.name))();
  TextColumn get voucherNumber => text().nullable()();
  TextColumn get paymentMode => textEnum<PaymentMode>().nullable()();
  IntColumn get bankAccountId => integer().nullable().references(BankAccounts, #id, onDelete: KeyAction.setNull)();
  TextColumn get narration => text().withLength(min: 1, max: 255)();
  TextColumn get verifiedBy => text().nullable()();
  IntColumn get transactionId => integer().nullable().references(Transactions, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
