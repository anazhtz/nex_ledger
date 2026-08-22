import 'package:drift/drift.dart';

/// Bank and Cash account master table.
class BankAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get accountName => text()(); // e.g. "Primary Current Account", "Petty Cash Drawer"
  TextColumn get bankName => text().nullable()(); // e.g. "HDFC Bank", "State Bank of India"
  TextColumn get accountNumber => text().nullable()(); // e.g. "50200012345678"
  TextColumn get ifscCode => text().nullable()(); // e.g. "HDFC0001234"
  TextColumn get branch => text().nullable()();
  RealColumn get openingBalance => real().withDefault(const Constant(0.0))();
  BoolColumn get isCashAccount => boolean().withDefault(const Constant(false))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
