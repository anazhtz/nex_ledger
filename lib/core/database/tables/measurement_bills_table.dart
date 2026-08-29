import 'package:drift/drift.dart';
import 'transactions_table.dart';
import 'work_orders_table.dart';

/// MeasurementBills table — Running Account (RA) bills / Measurement entries certified on site.
class MeasurementBills extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId => integer().references(Transactions, #id)();
  IntColumn get workOrderId => integer().references(WorkOrders, #id)();
  TextColumn get billNumber => text().withLength(min: 1, max: 50)(); // e.g. "MB-01", "RA-01"
  DateTimeColumn get date => dateTime()();
  RealColumn get measuredQuantity => real()(); // e.g. 3500.0 Sq.ft
  RealColumn get unitRate => real()(); // ₹ per unit
  RealColumn get grossAmount => real()(); // measuredQuantity * unitRate
  RealColumn get retentionPercentage => real().withDefault(const Constant(5.0))();
  RealColumn get retentionAmount => real()(); // grossAmount * (retentionPercentage / 100)
  RealColumn get netAmount => real()(); // grossAmount - retentionAmount
  TextColumn get locationOrDescription => text().nullable()(); // e.g. "1st floor living room walls"
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
