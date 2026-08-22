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

  /// Watch only advance stock purchases.
  Stream<List<PurchaseDetail>> watchAdvanceStockPurchases() =>
      _purchaseDao.watchAdvanceStockPurchases();

  Stream<List<Vendor>> watchAllVendors() => _purchaseDao.watchAllVendors();

  /// Create a purchase atomically: inserts a Transaction + a Purchase row.
  ///
  /// **Accrual & Asset logic:**
  /// - [isAdvanceStock] = true:
  ///   - `affectsPnl: false` (held as Asset/Stock; does not reduce project profit upon purchase)
  ///   - `affectsCash: true` if paid, `false` if pending
  /// - [isAdvanceStock] = false (Standard Direct Purchase):
  ///   - `affectsPnl: true` (expense recognized immediately for project)
  ///   - `affectsCash: true` if paid, `false` if pending / credit
  Future<void> addPurchase({
    required int projectId,
    required int vendorId,
    required DateTime date,
    required String itemDescription,
    required double amount,
    double quantity = 1.0,
    double unitRate = 0.0,
    String? unit,
    double paidAmount = 0.0,
    required PaymentStatus paymentStatus,
    PaymentMode? paymentMode,
    int? bankAccountId,
    String? narration,
    String? referenceNo,
    bool isAdvanceStock = false,
  }) async {
    final isFullPaid = paymentStatus == PaymentStatus.paid;
    final isPartial = paymentStatus == PaymentStatus.partial;
    final actualPaid = isFullPaid ? amount : (isPartial ? paidAmount : 0.0);

    // Primary bill transaction:
    // affectsCash is true ONLY when paid in full on the main bill.
    final affectsCash = isFullPaid;
    // If it's advance stock asset, P&L is NOT affected at purchase time.
    final affectsPnl = !isAdvanceStock;

    await _db.transaction(() async {
      final txnId = await _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          date: date,
          type: TransactionType.purchase,
          affectsPnl: Value(affectsPnl),
          affectsCash: Value(affectsCash),
          amount: amount,
          paymentMode: Value(paymentMode),
          bankAccountId: Value(bankAccountId),
          narration: Value(narration),
          referenceNo: Value(referenceNo),
        ),
      );

      // If partial advance was paid at time of credit purchase, insert a purchasePayment transaction for the cash out
      if (isPartial && actualPaid > 0) {
        await _transactionDao.insertTransaction(
          TransactionsCompanion.insert(
            projectId: projectId,
            date: date,
            type: TransactionType.purchasePayment,
            affectsPnl: const Value(false), // P&L already recognized by main purchase bill
            affectsCash: const Value(true), // moves cash
            amount: actualPaid,
            paymentMode: Value(paymentMode),
            bankAccountId: Value(bankAccountId),
            narration: Value('Advance payment for: $itemDescription'),
            referenceNo: Value(referenceNo),
          ),
        );
      }

      await _db.into(_db.purchases).insert(
            PurchasesCompanion.insert(
              transactionId: txnId,
              vendorId: vendorId,
              itemDescription: itemDescription,
              quantity: Value(quantity),
              unitRate: Value(unitRate),
              unit: Value(unit),
              paidAmount: Value(actualPaid),
              paymentStatus: paymentStatus,
              isAdvanceStock: Value(isAdvanceStock),
              allocatedAmount: const Value(0.0),
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
    int? bankAccountId,
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
          bankAccountId: Value(bankAccountId),
          narration: Value(
            'Payment for: ${detail.purchase.itemDescription}',
          ),
          referenceNo: Value(referenceNo),
        ),
      );

      // Determine new payment status based on total amount paid vs original bill.
      final original = detail.transaction.amount;
      final alreadyPaid = detail.purchase.paidAmount;
      final totalNowPaid = alreadyPaid + amountPaid;
      final newStatus = totalNowPaid >= original - 0.01
          ? PaymentStatus.paid
          : PaymentStatus.partial;

      // Update the purchase record with new paid amount and status.
      await _purchaseDao.updatePaymentDetails(purchaseId, totalNowPaid, newStatus);
    });
  }

  /// Allocate material/stock from an advance stock purchase to a specific target project.
  ///
  /// This inserts a [TransactionType.stockAllocation] row for [targetProjectId]:
  /// - `affectsPnl: true` (Project P&L recognizes the material cost)
  /// - `affectsCash: false` (Zero cash movement — cash was already paid at bulk purchase time)
  ///
  /// Updates [allocatedAmount] on the original advance stock purchase.
  Future<void> allocateStockToProject({
    required int purchaseId,
    required int targetProjectId,
    required DateTime date,
    required double amountToAllocate,
    String? narration,
    String? referenceNo,
  }) async {
    final detail = await _purchaseDao.getPurchaseById(purchaseId);
    if (detail == null) {
      throw StateError('Purchase $purchaseId not found');
    }
    if (!detail.purchase.isAdvanceStock) {
      throw StateError('Purchase $purchaseId is not marked as Advance Stock');
    }
    final unallocated =
        detail.transaction.amount - detail.purchase.allocatedAmount;
    if (amountToAllocate > unallocated + 0.01) {
      throw StateError(
          'Cannot allocate $amountToAllocate; only $unallocated remaining in stock');
    }

    await _db.transaction(() async {
      // 1. Insert allocation transaction for the target project
      await _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: targetProjectId,
          date: date,
          type: TransactionType.stockAllocation,
          affectsPnl: const Value(true), // hits target project P&L
          affectsCash: const Value(false), // zero cash movement
          amount: amountToAllocate,
          narration: Value(narration ??
              'Stock allocated: ${detail.purchase.itemDescription}'),
          referenceNo: Value(referenceNo),
        ),
      );

      // 2. Update allocated amount on the advance stock purchase record
      final newAllocated =
          detail.purchase.allocatedAmount + amountToAllocate;
      await _purchaseDao.updateAllocatedAmount(purchaseId, newAllocated);
    });
  }

  /// Outstanding (unpaid) amount for a purchase detail.
  double outstandingAmount(PurchaseDetail detail) {
    if (detail.purchase.paymentStatus == PaymentStatus.paid) return 0.0;
    final total = detail.transaction.amount;
    final paid = detail.purchase.paidAmount;
    final due = total - paid;
    return due > 0 ? due : 0.0;
  }

  /// Get purchase by id
  Future<PurchaseDetail?> getPurchaseById(int purchaseId) =>
      _purchaseDao.getPurchaseById(purchaseId);

  /// Delete a purchase and its linked transaction.
  Future<void> deletePurchase(int purchaseId) async {
    final detail = await _purchaseDao.getPurchaseById(purchaseId);
    if (detail == null) return;
    await _db.transaction(() async {
      await (_db.delete(_db.purchases)..where((p) => p.id.equals(purchaseId))).go();
      await (_db.delete(_db.transactions)..where((t) => t.id.equals(detail.transaction.id))).go();
    });
  }

  /// Update an existing purchase.
  Future<void> updatePurchase({
    required int purchaseId,
    required int projectId,
    required int vendorId,
    required DateTime date,
    required String itemDescription,
    required double amount,
    double quantity = 1.0,
    double unitRate = 0.0,
    String? unit,
    double paidAmount = 0.0,
    PaymentStatus paymentStatus = PaymentStatus.paid,
    PaymentMode? paymentMode,
    int? bankAccountId,
    String? referenceNo,
    String? narration,
    bool isAdvanceStock = false,
  }) async {
    final detail = await _purchaseDao.getPurchaseById(purchaseId);
    if (detail == null) throw StateError('Purchase $purchaseId not found');

    await _db.transaction(() async {
      final affectsCash = paymentStatus == PaymentStatus.paid;

      // Update primary transaction row
      await _transactionDao.updateTransaction(
        TransactionsCompanion(
          id: Value(detail.transaction.id),
          projectId: Value(projectId),
          date: Value(date),
          type: const Value(TransactionType.purchase),
          affectsPnl: Value(!isAdvanceStock),
          affectsCash: Value(affectsCash),
          amount: Value(amount),
          paymentMode: Value(paymentMode),
          bankAccountId: Value(bankAccountId),
          narration: Value(narration),
          referenceNo: Value(referenceNo),
        ),
      );

      // Update purchase row
      await (_db.update(_db.purchases)..where((p) => p.id.equals(purchaseId))).write(
        PurchasesCompanion(
          vendorId: Value(vendorId),
          itemDescription: Value(itemDescription.trim()),
          quantity: Value(quantity),
          unitRate: Value(unitRate),
          unit: Value(unit?.trim()),
          paidAmount: Value(paidAmount),
          paymentStatus: Value(paymentStatus),
          isAdvanceStock: Value(isAdvanceStock),
        ),
      );
    });
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
