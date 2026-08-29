import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/daos/petty_cash_dao.dart';

class PettyCashRepository {
  final PettyCashDao _pettyCashDao;
  final TransactionDao _txnDao;
  final AppDatabase _db;

  PettyCashRepository(
    this._pettyCashDao,
    this._txnDao,
    this._db,
  );

  // ─── Supervisor Wallet Master ──────────────────────────────────────────────

  Future<int> createWallet({
    required String supervisorName,
    required String phone,
    int? assignedProjectId,
    double maxFloatLimit = 50000.0,
    bool isActive = true,
    String? notes,
  }) {
    return _pettyCashDao.insertWallet(
      PettyCashWalletsCompanion.insert(
        supervisorName: supervisorName,
        phone: phone,
        assignedProjectId: Value(assignedProjectId),
        maxFloatLimit: Value(maxFloatLimit),
        isActive: Value(isActive),
        notes: Value(notes),
      ),
    );
  }

  Future<bool> updateWallet({
    required int id,
    required String supervisorName,
    required String phone,
    int? assignedProjectId,
    required double maxFloatLimit,
    required bool isActive,
    String? notes,
  }) {
    return _pettyCashDao.updateWallet(
      PettyCashWalletsCompanion(
        id: Value(id),
        supervisorName: Value(supervisorName),
        phone: Value(phone),
        assignedProjectId: Value(assignedProjectId),
        maxFloatLimit: Value(maxFloatLimit),
        isActive: Value(isActive),
        notes: Value(notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteWallet(int id) {
    return _pettyCashDao.deleteWallet(id);
  }

  // ─── Cash Advance Disbursal (Office -> Supervisor) ─────────────────────────
  // CRITICAL: affectsCash: true (money moved from bank/office), affectsPnl: false (internal imprest holding)

  Future<int> disburseCashAdvance({
    required int walletId,
    required int projectId,
    required DateTime date,
    required double amount,
    required PaymentMode paymentMode,
    int? bankAccountId,
    required String narration,
    String? voucherNumber,
    String? verifiedBy,
  }) async {
    return _db.transaction(() async {
      final txnId = await _txnDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          type: TransactionType.expense,
          amount: amount,
          date: date,
          paymentMode: Value(paymentMode),
          bankAccountId: Value(bankAccountId),
          narration: Value(narration),
          referenceNo: Value(voucherNumber),
          affectsPnl: const Value(false),  // Float advance does NOT hit PnL!
          affectsCash: const Value(true),  // Physical cash left bank/office drawer
        ),
      );

      final voucherId = await _pettyCashDao.insertVoucher(
        PettyCashVouchersCompanion.insert(
          walletId: walletId,
          projectId: projectId,
          type: PettyCashTxnType.advanceDisbursed,
          date: date,
          amount: amount,
          category: const Value('Petty Cash Advance Float Disbursed'),
          voucherNumber: Value(voucherNumber),
          paymentMode: Value(paymentMode),
          bankAccountId: Value(bankAccountId),
          narration: narration,
          verifiedBy: Value(verifiedBy),
          transactionId: Value(txnId),
        ),
      );

      return voucherId;
    });
  }

  // ─── Site Expense Voucher Claim (Supervisor Spends Cash on Site) ───────────
  // CRITICAL: affectsPnl: true (hits Project P&L), affectsCash: false (already moved in advance step)

  Future<int> recordExpenseVoucher({
    required int walletId,
    required int projectId,
    required DateTime date,
    required double amount,
    required String category,
    BudgetCostHead costHead = BudgetCostHead.equipmentOverhead,
    String? voucherNumber,
    required String narration,
    String? verifiedBy,
  }) async {
    return _db.transaction(() async {
      final txnId = await _txnDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          type: TransactionType.expense,
          amount: amount,
          date: date,
          paymentMode: const Value(PaymentMode.cash),
          narration: Value('Petty Cash Voucher: $narration ($category)'),
          referenceNo: Value(voucherNumber),
          affectsPnl: const Value(true),   // Expense NOW recognized in Project P&L!
          affectsCash: const Value(false), // Cash was already deducted at advance time
        ),
      );

      final voucherId = await _pettyCashDao.insertVoucher(
        PettyCashVouchersCompanion.insert(
          walletId: walletId,
          projectId: projectId,
          type: PettyCashTxnType.voucherExpense,
          date: date,
          amount: amount,
          category: Value(category),
          costHead: Value(costHead),
          voucherNumber: Value(voucherNumber),
          paymentMode: const Value(PaymentMode.cash),
          narration: narration,
          verifiedBy: Value(verifiedBy),
          transactionId: Value(txnId),
        ),
      );

      return voucherId;
    });
  }

  // ─── Return Unspent Cash (Supervisor -> Office) ────────────────────────────
  // CRITICAL: affectsCash: true (money received back in office/bank), affectsPnl: false

  Future<int> returnUnspentCash({
    required int walletId,
    required int projectId,
    required DateTime date,
    required double amount,
    required PaymentMode paymentMode,
    int? bankAccountId,
    required String narration,
    String? voucherNumber,
    String? verifiedBy,
  }) async {
    return _db.transaction(() async {
      final txnId = await _txnDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          type: TransactionType.income,
          amount: amount,
          date: date,
          paymentMode: Value(paymentMode),
          bankAccountId: Value(bankAccountId),
          narration: Value('Unspent Petty Cash Returned: $narration'),
          referenceNo: Value(voucherNumber),
          affectsPnl: const Value(false),  // Return of capital is NOT income!
          affectsCash: const Value(true),  // Physical cash re-enters office/bank
        ),
      );

      final voucherId = await _pettyCashDao.insertVoucher(
        PettyCashVouchersCompanion.insert(
          walletId: walletId,
          projectId: projectId,
          type: PettyCashTxnType.cashReturned,
          date: date,
          amount: amount,
          category: const Value('Unspent Float Returned to Office'),
          voucherNumber: Value(voucherNumber),
          paymentMode: Value(paymentMode),
          bankAccountId: Value(bankAccountId),
          narration: narration,
          verifiedBy: Value(verifiedBy),
          transactionId: Value(txnId),
        ),
      );

      return voucherId;
    });
  }

  // ─── Delete Voucher / Advance with Linked Transaction Clean up ─────────────

  Future<void> deleteVoucher(int voucherId) async {
    return _db.transaction(() async {
      final vList = await (_db.select(_db.pettyCashVouchers)..where((v) => v.id.equals(voucherId))).get();
      if (vList.isNotEmpty) {
        final v = vList.first;
        if (v.transactionId != null) {
          await (_db.delete(_db.transactions)..where((t) => t.id.equals(v.transactionId!))).go();
        }
      }
      await _pettyCashDao.deleteVoucher(voucherId);
    });
  }

  // ─── Streams ──────────────────────────────────────────────────────────────

  Stream<List<PettyCashWalletSummary>> watchAllWalletsWithBalances() =>
      _pettyCashDao.watchAllWalletsWithBalances();

  Stream<PettyCashWalletSummary?> watchWalletById(int id) =>
      _pettyCashDao.watchWalletById(id);

  Stream<List<PettyCashVoucherDetail>> watchVouchers({
    int? walletId,
    int? projectId,
    PettyCashTxnType? type,
    DateTime? fromDate,
    DateTime? toDate,
  }) =>
      _pettyCashDao.watchVouchers(
        walletId: walletId,
        projectId: projectId,
        type: type,
        fromDate: fromDate,
        toDate: toDate,
      );

  Stream<PettyCashPortfolioMetrics> watchPettyCashPortfolioMetrics() =>
      _pettyCashDao.watchPettyCashPortfolioMetrics();
}
