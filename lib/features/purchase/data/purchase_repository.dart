import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';

class PurchaseRepository {
  final PurchaseDao _purchaseDao;
  final TransactionDao _transactionDao;
  final AppDatabase _db;

  PurchaseRepository(this._purchaseDao, this._transactionDao, this._db);

  Stream<List<PurchaseDetail>> watchAllPurchases() =>
      _purchaseDao.watchAllPurchases();

  Stream<List<PurchaseDetail>> watchPurchasesByProject(int projectId) =>
      _purchaseDao.watchPurchasesByProject(projectId);

  /// Watch only pending/partial purchases — used for Accounts Payable view.
  Stream<List<PurchaseDetail>> watchPendingPurchases({int? projectId}) =>
      _purchaseDao.watchPendingPurchases(projectId: projectId);

  Stream<List<Vendor>> watchAllVendors() => _purchaseDao.watchAllVendors();

  /// Create a purchase atomically: inserts a Transaction + a Purchase row.
  ///
  /// **Accrual logic:**
  /// - [PaymentStatus.paid] → `affectsPnl: true, affectsCash: true`
  ///   (expense recognized + cash moved immediately)
  /// - [PaymentStatus.pending] / [PaymentStatus.partial] →
  ///   `affectsPnl: true, affectsCash: false`
  ///   (expense recognized as a liability; cash moves separately when [markPurchasePaid] is called)
  Future<void> addPurchase({
    required int projectId,
    required int vendorId,
    required DateTime date,
    required String itemDescription,
    required double amount,
    required PaymentStatus paymentStatus,
    PaymentMode? paymentMode,
    String? narration,
    String? referenceNo,
  }) async {
    // Pending/partial → does NOT move cash yet (accrued expense / liability).
    final affectsCash = paymentStatus == PaymentStatus.paid;

    await _db.transaction(() async {
      final txnId = await _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          date: date,
          type: TransactionType.purchase,
          affectsPnl: const Value(true),
          affectsCash: Value(affectsCash),
          amount: amount,
          paymentMode: Value(paymentMode),
          narration: Value(narration),
          referenceNo: Value(referenceNo),
        ),
      );
      await _db.into(_db.purchases).insert(
            PurchasesCompanion.insert(
              transactionId: txnId,
              vendorId: vendorId,
              itemDescription: itemDescription,
              paymentStatus: paymentStatus,
            ),
          );
    });
  }

  /// Settle a previously pending/partial purchase bill.
  ///
  /// This inserts a new [TransactionType.purchasePayment] row with
  /// `affectsPnl: false, affectsCash: true` — so only cash moves;
  /// P&L is NOT hit again (it was already hit when the purchase was recorded).
  ///
  /// The original purchase transaction is never mutated (audit trail preserved).
  Future<void> markPurchasePaid({
    required int purchaseId,
    required DateTime paymentDate,
    required double amountPaid,
    PaymentMode? paymentMode,
    String? referenceNo,
  }) async {
    final detail = await _purchaseDao.getPurchaseById(purchaseId);
    if (detail == null) {
      throw StateError('Purchase $purchaseId not found');
    }

    await _db.transaction(() async {
      // Insert the cash-outflow transaction (P&L unaffected — already booked).
      await _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: detail.transaction.projectId,
          date: paymentDate,
          type: TransactionType.purchasePayment,
          affectsPnl: const Value(false), // P&L already hit at bill entry
          affectsCash: const Value(true), // cash moves NOW
          amount: amountPaid,
          paymentMode: Value(paymentMode),
          narration: Value(
            'Payment for: ${detail.purchase.itemDescription}',
          ),
          referenceNo: Value(referenceNo),
        ),
      );

      // Determine new payment status based on amount paid vs original bill.
      final original = detail.transaction.amount;
      final alreadyPaid = original - _outstandingAmount(detail);
      final totalNowPaid = alreadyPaid + amountPaid;
      final newStatus = totalNowPaid >= original - 0.01
          ? PaymentStatus.paid
          : PaymentStatus.partial;

      // Mark the purchase record as paid/partial.
      await _purchaseDao.updatePaymentStatus(purchaseId, newStatus);
    });
  }

  /// Outstanding (unpaid) amount for a purchase detail.
  double _outstandingAmount(PurchaseDetail detail) {
    // For pending: the full amount is outstanding.
    // For partial: ideally tracked, but conservatively return full amount.
    // The purchase transaction amount = original bill amount.
    return detail.transaction.amount;
  }

  // --- Vendor ---
  Future<int> addVendor(String name, {String? contact}) =>
      _purchaseDao.insertVendor(
        VendorsCompanion.insert(name: name, contact: Value(contact)),
      );

  Future<void> updateVendor(int id, String name, {String? contact}) =>
      _purchaseDao.updateVendor(
        VendorsCompanion(
          id: Value(id),
          name: Value(name),
          contact: Value(contact),
        ),
      );
}
