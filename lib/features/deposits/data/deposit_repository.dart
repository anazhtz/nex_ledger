import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';

/// DUAL-DIRECTION DEPOSIT MANAGEMENT
///
/// 1. Deposit Paid to Govt / Client (Outflow / Asset):
///    - When paid: Cash decreases, Asset created, P&L = 0.
///    - When received back: Cash increases, Asset cleared, P&L = 0 (NEVER income!).
///
/// 2. Deposit Received from Client (Inflow / Liability):
///    - When received: Cash increases, Liability created, P&L = 0.
///    - When refunded: Cash decreases, Liability cleared, P&L = 0.
///    - When adjusted: No cash moves, P&L Income recognized.
class DepositRepository {
  final DepositDao _depositDao;
  final TransactionDao _transactionDao;
  final AppDatabase _db;

  DepositRepository(this._depositDao, this._transactionDao, this._db);

  Stream<List<DepositDetail>> watchAllDeposits() =>
      _depositDao.watchAllDeposits();

  Stream<List<DepositDetail>> watchDepositsByProject(int projectId) =>
      _depositDao.watchDepositsByProject(projectId);

  Stream<double> watchTotalDepositsHeld() =>
      _depositDao.watchTotalDepositsHeld();

  Stream<double> watchTotalDepositsPaidHeld() =>
      _depositDao.watchTotalDepositsPaidHeld();

  Stream<double> watchTotalDepositsReceivedHeld() =>
      _depositDao.watchTotalDepositsReceivedHeld();

  /// OPERATION 1A: Pay a security deposit TO Government / Client.
  ///
  /// Creates Transaction(type=depositPaid, affectsPnl=false, affectsCash=true).
  /// Cash decreases (Outflow). Asset created. P&L is UNAFFECTED (₹0).
  Future<void> paySecurityDeposit({
    required int projectId,
    required DateTime date,
    required double amount,
    PaymentMode? paymentMode,
    int? bankAccountId,
    String? narration,
    String? referenceNo,
  }) async {
    await _db.transaction(() async {
      final txnId = await _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          date: date,
          type: TransactionType.depositPaid,
          affectsPnl: const Value(false), // CRITICAL: never affects P&L
          affectsCash: const Value(true), // Physical cash out
          amount: amount,
          paymentMode: Value(paymentMode),
          bankAccountId: Value(bankAccountId),
          narration: Value(narration ?? 'Security deposit paid to Govt/Client'),
          referenceNo: Value(referenceNo),
        ),
      );
      await _depositDao.insertDeposit(
        DepositsCompanion.insert(
          transactionId: txnId,
          projectId: projectId,
          depositType: const Value(DepositType.paid),
          status: DepositStatus.held,
        ),
      );
    });
  }

  /// OPERATION 1B: Recover / Receive back deposit from Government / Client.
  ///
  /// Creates Transaction(type=depositRecovery, affectsPnl=false, affectsCash=true).
  /// Cash increases (Inflow). Asset cleared. P&L is UNAFFECTED (₹0 — NOT treated as income).
  Future<void> recoverDeposit({
    required int depositId,
    required int projectId,
    required double recoveredAmount,
    required DateTime date,
    PaymentMode? paymentMode,
    int? bankAccountId,
    String? narration,
    String? referenceNo,
  }) async {
    await _db.transaction(() async {
      final existing = await _depositDao.getDepositById(depositId);
      final prevAdjusted = existing?.adjustedAmount ?? 0.0;
      final newAdjusted = prevAdjusted + recoveredAmount;

      // Get original transaction amount to check if fully recovered
      final originalTxn = existing != null
          ? await _transactionDao.getTransactionById(existing.transactionId)
          : null;
      final originalAmount = originalTxn?.amount ?? recoveredAmount;
      final isFullyRecovered = newAdjusted >= (originalAmount - 0.01);

      await _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          date: date,
          type: TransactionType.depositRecovery,
          affectsPnl: const Value(false), // CRITICAL: NEVER income!
          affectsCash: const Value(true), // Cash comes back into account
          amount: recoveredAmount,
          paymentMode: Value(paymentMode),
          bankAccountId: Value(bankAccountId),
          narration: Value(narration ?? 'Security deposit recovered / received back from Govt/Client'),
          referenceNo: Value(referenceNo),
        ),
      );

      await _depositDao.updateDepositStatus(
        depositId,
        isFullyRecovered
            ? DepositStatus.recovered
            : DepositStatus.partiallyAdjusted,
        adjustedAmount: newAdjusted,
        adjustmentReference: referenceNo,
      );
    });
  }

  /// OPERATION 2A: Receive a deposit FROM a Client / Subcontractor.
  ///
  /// Creates Transaction(type=deposit, affectsPnl=false, affectsCash=true).
  /// Cash increases (Inflow). Liability created. P&L is UNAFFECTED.
  Future<void> receiveDeposit({
    required int projectId,
    required DateTime date,
    required double amount,
    PaymentMode? paymentMode,
    int? bankAccountId,
    String? narration,
    String? referenceNo,
  }) async {
    await _db.transaction(() async {
      final txnId = await _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          date: date,
          type: TransactionType.deposit,
          affectsPnl: const Value(false), // CRITICAL: never affects P&L
          affectsCash: const Value(true), // Physical cash in
          amount: amount,
          paymentMode: Value(paymentMode),
          bankAccountId: Value(bankAccountId),
          narration: Value(narration ?? 'Client deposit received'),
          referenceNo: Value(referenceNo),
        ),
      );
      await _depositDao.insertDeposit(
        DepositsCompanion.insert(
          transactionId: txnId,
          projectId: projectId,
          depositType: const Value(DepositType.received),
          status: DepositStatus.held,
        ),
      );
    });
  }

  /// OPERATION 2B: Adjust a received deposit to income (partially or fully).
  ///
  /// Creates a NEW Transaction(type=depositAdjustment, affectsPnl=true, affectsCash=false).
  /// Cash does NOT move (already received). P&L NOW reflects the adjusted amount as income.
  Future<void> adjustDepositToIncome({
    required int depositId,
    required int projectId,
    required double adjustedAmount,
    required DateTime date,
    required bool isFullyAdjusted,
    String? adjustmentReference,
    String? narration,
  }) async {
    await _db.transaction(() async {
      // Create a new income transaction (this is what hits P&L)
      await _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          date: date,
          type: TransactionType.depositAdjustment,
          affectsPnl: const Value(true), // This IS income now
          affectsCash: const Value(false), // CRITICAL: money was received earlier, adjusting does NOT move cash
          amount: adjustedAmount,
          narration: Value(
              narration ?? 'Deposit adjusted to income${adjustmentReference != null ? ' - $adjustmentReference' : ''}'),
          referenceNo: Value(adjustmentReference),
        ),
      );

      final existing = await _depositDao.getDepositById(depositId);
      final prevAdjusted = existing?.adjustedAmount ?? 0.0;
      final newAdjusted = prevAdjusted + adjustedAmount;

      await _depositDao.updateDepositStatus(
        depositId,
        isFullyAdjusted
            ? DepositStatus.adjusted
            : DepositStatus.partiallyAdjusted,
        adjustedAmount: newAdjusted,
        adjustmentReference: adjustmentReference,
      );
    });
  }

  /// OPERATION 2C: Refund a received deposit to Client.
  ///
  /// Creates Transaction(type=depositRefund, affectsPnl=false, affectsCash=true).
  /// Cash decreases. Deposit liability decreases. P&L is UNAFFECTED.
  Future<void> refundDeposit({
    required int depositId,
    required int projectId,
    required double refundAmount,
    required DateTime date,
    PaymentMode? paymentMode,
    int? bankAccountId,
    String? narration,
    String? referenceNo,
  }) async {
    await _db.transaction(() async {
      await _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          date: date,
          type: TransactionType.depositRefund,
          affectsPnl: const Value(false), // CRITICAL: never affects P&L
          affectsCash: const Value(true),
          amount: refundAmount,
          paymentMode: Value(paymentMode),
          bankAccountId: Value(bankAccountId),
          narration: Value(narration ?? 'Deposit refund to client'),
          referenceNo: Value(referenceNo),
        ),
      );
      await _depositDao.updateDepositStatus(depositId, DepositStatus.refunded);
    });
  }

  /// OPERATION 3: Delete a deposit record.
  ///
  /// Permanently removes the deposit row and its linked transaction.
  Future<void> deleteDeposit(int depositId) async {
    final deposit = await _depositDao.getDepositById(depositId);
    if (deposit == null) return;
    await _db.transaction(() async {
      await (_db.delete(_db.deposits)..where((d) => d.id.equals(depositId))).go();
      await (_db.delete(_db.transactions)..where((t) => t.id.equals(deposit.transactionId))).go();
    });
  }
}
