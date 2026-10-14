import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/simple_gst.dart';

/// GST on a Cash Book expense. When given, the expense `amount` is the value
/// BEFORE GST; the amount posted is that plus the GST.
class ExpenseGstInput {
  final double rate;
  final bool interState;
  final String? partyName;
  final String? partyGstin;
  final String? billNo;
  const ExpenseGstInput({
    required this.rate,
    this.interState = false,
    this.partyName,
    this.partyGstin,
    this.billNo,
  });
}

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
  ///
  /// With [gst] (rate above zero), [amount] is the value before GST and the
  /// posted amount is [amount] + GST. Without it, [amount] is posted as is.
  Future<void> addExpense({
    required int projectId,
    required DateTime date,
    required double amount,
    PaymentMode? paymentMode,
    String? narration,
    String? referenceNo,
    int? expenseCategoryId,
    int? bankAccountId,
    ExpenseGstInput? gst,
  }) {
    final split = _split(amount, gst);
    return _dao.insertTransactionWithGst(
      TransactionsCompanion.insert(
        projectId: projectId,
        date: date,
        type: TransactionType.expense,
        affectsPnl: const Value(true),
        amount: split?.total ?? amount,
        paymentMode: Value(paymentMode),
        bankAccountId: Value(bankAccountId),
        narration: Value(narration),
        referenceNo: Value(referenceNo),
        expenseCategoryId: Value(expenseCategoryId),
      ),
      _detail(split, gst),
    );
  }

  SimpleGst? _split(double amount, ExpenseGstInput? gst) {
    if (gst == null || gst.rate <= 0) return null;
    final s = calcSimpleGst(
        taxable: amount, rate: gst.rate, interState: gst.interState);
    return s.hasGst ? s : null;
  }

  TxnGstDetail? _detail(SimpleGst? split, ExpenseGstInput? gst) => split == null
      ? null
      : TxnGstDetail(
          kind: TxnGstKind.expense,
          gst: split,
          partyName: gst?.partyName,
          partyGstin: gst?.partyGstin,
          billNo: gst?.billNo,
        );

  /// The GST detail saved with an expense, if any.
  Future<TransactionGst?> getGstDetail(int transactionId) =>
      _dao.getGstDetail(transactionId);

  /// Get transaction by id.
  Future<Transaction?> getTransactionById(int id) =>
      _dao.getTransactionById(id);

  /// Update an existing transaction.
  ///
  /// For expenses, [gst] works as in [addExpense]: with it, [amount] is the
  /// value before GST; passing null removes any GST detail the entry had.
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
    ExpenseGstInput? gst,
  }) {
    final split = type == TransactionType.expense ? _split(amount, gst) : null;
    return _dao.updateTransactionWithGst(
      TransactionsCompanion(
        id: Value(id),
        projectId: Value(projectId),
        date: Value(date),
        type: Value(type),
        affectsPnl: const Value(true),
        affectsCash: const Value(true),
        amount: Value(split?.total ?? amount),
        paymentMode: Value(paymentMode),
        bankAccountId: Value(bankAccountId),
        narration: Value(narration),
        referenceNo: Value(referenceNo),
        expenseCategoryId: Value(expenseCategoryId),
      ),
      _detail(split, gst),
    );
  }

  /// Delete a transaction.
  Future<void> deleteTransaction(int id) => _dao.deleteTransaction(id);
}
