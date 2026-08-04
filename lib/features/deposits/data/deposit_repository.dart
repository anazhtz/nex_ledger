import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';

/// CRITICAL BUSINESS RULE IMPLEMENTATION
///
/// Deposits are liabilities, never income at the moment received.
/// This repository is the ONLY place that creates deposit-related transactions.
/// All three operations are documented and auditable via the transaction table.
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

  /// OPERATION 1: Receive a deposit.
  ///
  /// Creates Transaction(type=deposit, affectsPnl=false) + Deposit row.
  /// Cash balance increases. P&L is UNAFFECTED.
  Future<void> receiveDeposit({
    required int projectId,
    required DateTime date,
    required double amount,
    PaymentMode? paymentMode,
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
          amount: amount,
          paymentMode: Value(paymentMode),
          narration: Value(narration),
          referenceNo: Value(referenceNo),
        ),
      );
      await _depositDao.insertDeposit(
        DepositsCompanion.insert(
          transactionId: txnId,
          projectId: projectId,
          status: DepositStatus.held,
        ),
      );
    });
  }

  /// OPERATION 2: Adjust deposit to income (partially or fully).
  ///
  /// Creates a NEW Transaction(type=income, affectsPnl=true) for the adjusted
  /// amount. Updates Deposit.status. Original transaction is NEVER mutated.
  /// P&L NOW reflects the adjusted amount as income.
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
          type: TransactionType.income,
          affectsPnl: const Value(true), // This IS income now
          affectsCash: const Value(false), // CRITICAL: money was received in step 1, adjusting does NOT move cash
          amount: adjustedAmount,
          narration: Value(
              narration ?? 'Deposit adjusted to income${adjustmentReference != null ? ' - $adjustmentReference' : ''}'),
          referenceNo: Value(adjustmentReference),
        ),
      );

      // Fetch current deposit to accumulate total adjusted amount
      final existing = await _depositDao.getDepositById(depositId);
      final prevAdjusted = existing?.adjustedAmount ?? 0.0;
      final newAdjusted = prevAdjusted + adjustedAmount;

      // Update the deposit liability status & adjusted amount
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

  /// OPERATION 3: Refund a deposit.
  ///
  /// Creates Transaction(type=depositRefund, affectsPnl=false).
  /// Cash decreases. Deposit liability decreases. P&L is UNAFFECTED.
  Future<void> refundDeposit({
    required int depositId,
    required int projectId,
    required double refundAmount,
    required DateTime date,
    PaymentMode? paymentMode,
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
          amount: refundAmount,
          paymentMode: Value(paymentMode),
          narration: Value(narration ?? 'Deposit refund'),
          referenceNo: Value(referenceNo),
        ),
      );
      await _depositDao.updateDepositStatus(depositId, DepositStatus.refunded);
    });
  }
}
