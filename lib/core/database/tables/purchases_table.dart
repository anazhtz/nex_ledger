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
  TextColumn get paymentStatus => textEnum<PaymentStatus>()();
}
