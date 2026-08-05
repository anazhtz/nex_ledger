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
  }) =>
      _dao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          date: date,
          type: TransactionType.income,
          affectsPnl: const Value(true),
          amount: amount,
          paymentMode: Value(paymentMode),
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
  }) =>
      _dao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          date: date,
          type: TransactionType.expense,
          affectsPnl: const Value(true),
          amount: amount,
          paymentMode: Value(paymentMode),
          narration: Value(narration),
          referenceNo: Value(referenceNo),
          expenseCategoryId: Value(expenseCategoryId),
        ),
      );
}
