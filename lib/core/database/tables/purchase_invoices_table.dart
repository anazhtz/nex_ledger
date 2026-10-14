import 'package:drift/drift.dart';
import 'projects_table.dart';
import 'vendors_table.dart';

/// Header of a GST purchase invoice. Each item on the invoice is stored as an
/// ordinary purchase row (see `Purchases.invoiceId`), so every existing
/// report keeps working. The header holds what is shared by all items and a
/// snapshot of the totals.
class PurchaseInvoices extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Our own running number, e.g. PUR/26-27/00048 (restarts each financial year).
  TextColumn get purchaseNo => text()();
  DateTimeColumn get date => dateTime()();

  /// The supplier's invoice number and date.
  TextColumn get invoiceNo => text().nullable()();
  DateTimeColumn get invoiceDate => dateTime().nullable()();

  IntColumn get vendorId =>
      integer().references(Vendors, #id, onDelete: KeyAction.restrict)();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.restrict)();

  /// GSTIN and state as they were on this invoice.
  TextColumn get supplierGstin => text().nullable()();
  TextColumn get supplierState => text().nullable()();

  /// True = IGST, false = CGST + SGST.
  BoolColumn get isInterState => boolean().withDefault(const Constant(false))();

  /// Days of credit given by the supplier (0 = none). Due date = date + this.
  IntColumn get creditDays => integer().withDefault(const Constant(0))();

  TextColumn get transportBy => text().nullable()();
  TextColumn get vehicleNo => text().nullable()();
  TextColumn get remarks => text().nullable()();

  /// Hold the whole invoice as advance stock / asset (not a project cost yet).
  BoolColumn get isAdvanceStock =>
      boolean().withDefault(const Constant(false))();

  // Totals snapshot (all in rupees).
  RealColumn get taxableValue => real().withDefault(const Constant(0.0))();
  RealColumn get cgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get sgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get igstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get otherCharges => real().withDefault(const Constant(0.0))();
  RealColumn get roundOff => real().withDefault(const Constant(0.0))();
  RealColumn get grandTotal => real().withDefault(const Constant(0.0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {purchaseNo},
      ];
}
