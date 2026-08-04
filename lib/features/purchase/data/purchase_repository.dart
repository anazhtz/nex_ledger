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

  Stream<List<Vendor>> watchAllVendors() => _purchaseDao.watchAllVendors();

  /// Create a purchase atomically: inserts a Transaction + a Purchase row.
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
    await _db.transaction(() async {
      final txnId = await _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          date: date,
          type: TransactionType.purchase,
          affectsPnl: const Value(true),
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

  Future<void> updatePaymentStatus(int purchaseId, PaymentStatus status) =>
      _purchaseDao.updatePaymentStatus(purchaseId, status);

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
