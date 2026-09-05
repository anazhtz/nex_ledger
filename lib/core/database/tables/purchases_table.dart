import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'transactions_table.dart';
import 'vendors_table.dart';

/// Purchase detail — extends a Transaction of type `purchase`.
class Purchases extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId =>
      integer().references(Transactions, #id, onDelete: KeyAction.cascade)();
  IntColumn get vendorId =>
      integer().references(Vendors, #id, onDelete: KeyAction.restrict)();
  TextColumn get itemDescription => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  RealColumn get unitRate => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text().nullable()();
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();
  TextColumn get paymentStatus => textEnum<PaymentStatus>()();
  BoolColumn get isAdvanceStock =>
      boolean().withDefault(const Constant(false))();
  RealColumn get allocatedAmount =>
      real().withDefault(const Constant(0.0))();
  TextColumn get materialCategory => text().nullable()();
  TextColumn get hsnCode => text().nullable()();
  BoolColumn get taxApplicable =>
      boolean().withDefault(const Constant(false))();
  RealColumn get gstRate => real().withDefault(const Constant(0.0))();
  RealColumn get gstAmount => real().withDefault(const Constant(0.0))();
}
