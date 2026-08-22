import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';

class CashBookRepository {
  final TransactionDao _dao;
  CashBookRepository(this._dao);

  /// Stream of all transactions with project info.
  Stream<List<TransactionWithProject>> watchAllTransactions() =>
      _dao.watchAllTransactions();

  /// Filtered stream for cash book view.
  Stream<List<TransactionWithProject>> watchFiltered({
    int? projectId,
    List<TransactionType>? types,
    DateTime? from,
    DateTime? to,
  }) =>
      _dao.watchFilteredTransactions(
        projectId: projectId,
        types: types,
        from: from,
        to: to,
      );

  /// Watch live cash balance.
  Stream<double> watchCashBalance() => _dao.watchCashBalance();

  /// Add an income entry.
  Future<void> addIncome({
    required int projectId,
    required DateTime date,
    required double amount,
    PaymentMode? paymentMode,
    String? narration,
    String? referenceNo,
    int? bankAccountId,
  }) =>
      _dao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          date: date,
          type: TransactionType.income,
          affectsPnl: const Value(true),
          amount: amount,
          paymentMode: Value(paymentMode),
          bankAccountId: Value(bankAccountId),
          narration: Value(narration),
          referenceNo: Value(referenceNo),
        ),
      );

  /// Add an expense entry.
  Future<void> addExpense({
    required int projectId,
    required DateTime date,
    required double amount,
    PaymentMode? paymentMode,
    String? narration,
    String? referenceNo,
    int? expenseCategoryId,
    int? bankAccountId,
  }) =>
      _dao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          date: date,
          type: TransactionType.expense,
          affectsPnl: const Value(true),
          amount: amount,
          paymentMode: Value(paymentMode),
          bankAccountId: Value(bankAccountId),
          narration: Value(narration),
          referenceNo: Value(referenceNo),
          expenseCategoryId: Value(expenseCategoryId),
        ),
      );

  /// Get transaction by id.
  Future<Transaction?> getTransactionById(int id) =>
      _dao.getTransactionById(id);

  /// Update an existing transaction.
  Future<void> updateTransaction({
    required int id,
    required int projectId,
    required DateTime date,
    required TransactionType type,
    required double amount,
    PaymentMode? paymentMode,
    String? narration,
    String? referenceNo,
    int? expenseCategoryId,
    int? bankAccountId,
  }) =>
      _dao.updateTransaction(
        TransactionsCompanion(
          id: Value(id),
          projectId: Value(projectId),
          date: Value(date),
          type: Value(type),
          affectsPnl: const Value(true),
          affectsCash: const Value(true),
          amount: Value(amount),
          paymentMode: Value(paymentMode),
          bankAccountId: Value(bankAccountId),
          narration: Value(narration),
          referenceNo: Value(referenceNo),
          expenseCategoryId: Value(expenseCategoryId),
        ),
      );

  /// Delete a transaction.
  Future<void> deleteTransaction(int id) => _dao.deleteTransaction(id);
}
