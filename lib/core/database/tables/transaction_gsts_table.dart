import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'transactions_table.dart';

/// Optional GST detail for a bill entered as a plain expense: a Cash Book
/// expense or a machinery rental settlement. The transaction's amount is the
/// total (taxable value + GST); this row records how it splits, so the Input
/// GST report can add it up. Purchase invoices and subcontract bills keep
/// their GST in their own tables.
class TransactionGsts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// One GST detail per transaction.
  IntColumn get transactionId =>
      integer().references(Transactions, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => textEnum<TxnGstKind>()();

  RealColumn get taxableAmount => real().withDefault(const Constant(0.0))();

  /// Total GST rate in % (CGST + SGST, or IGST).
  RealColumn get gstRate => real().withDefault(const Constant(0.0))();
  RealColumn get cgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get sgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get igstAmount => real().withDefault(const Constant(0.0))();
  BoolColumn get isInterState => boolean().withDefault(const Constant(false))();

  /// Who charged the GST (optional).
  TextColumn get partyName => text().nullable()();
  TextColumn get partyGstin => text().nullable()();
  TextColumn get billNo => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {transactionId},
      ];
}
