import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'purchase_invoices_table.dart';
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
  RealColumn get allocatedAmount => real().withDefault(const Constant(0.0))();
  TextColumn get materialCategory => text().nullable()();

  // ─── GST invoice fields (null / 0 on purchases entered the old way) ───────

  /// The invoice this row belongs to. Null for single purchases entered
  /// without an invoice.
  IntColumn get invoiceId => integer()
      .nullable()
      .references(PurchaseInvoices, #id, onDelete: KeyAction.setNull)();
  TextColumn get hsn => text().nullable()();
  TextColumn get specification => text().nullable()();
  RealColumn get discountPercent => real().withDefault(const Constant(0.0))();

  /// Total GST rate in % (CGST + SGST, or IGST).
  RealColumn get gstRate => real().withDefault(const Constant(0.0))();

  /// Taxable value after discount, and the GST on it (rupees).
  RealColumn get taxableAmount => real().withDefault(const Constant(0.0))();
  RealColumn get cgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get sgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get igstAmount => real().withDefault(const Constant(0.0))();

  /// True for freight / loading / other charge rows (not a material).
  BoolColumn get isOtherCharge =>
      boolean().withDefault(const Constant(false))();
}
