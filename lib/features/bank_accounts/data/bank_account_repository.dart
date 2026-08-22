import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';

class BankAccountRepository {
  final BankAccountDao _bankDao;
  final TransactionDao _transactionDao;
  final AppDatabase _db;

  BankAccountRepository(this._bankDao, this._transactionDao, this._db);

  Stream<List<BankAccount>> watchAllAccounts() => _bankDao.watchAllAccounts();

  Future<List<BankAccount>> getAllAccounts() => _bankDao.getAllAccounts();

  Stream<List<BankAccountWithBalance>> watchAccountsWithBalances() =>
      _bankDao.watchAccountsWithBalances();

  Stream<({double cashInHand, double inBanks, double totalLiquidity})>
      watchLiquiditySummary() => _bankDao.watchLiquiditySummary();

  Future<BankAccount?> getAccountById(int id) => _bankDao.getAccountById(id);

  Future<int> addAccount({
    required String accountName,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? branch,
    double openingBalance = 0.0,
    bool isCashAccount = false,
    bool isDefault = false,
  }) {
    return _bankDao.insertAccount(
      BankAccountsCompanion.insert(
        accountName: accountName.trim(),
        bankName: Value(bankName?.trim()),
        accountNumber: Value(accountNumber?.trim()),
        ifscCode: Value(ifscCode?.trim()),
        branch: Value(branch?.trim()),
        openingBalance: Value(openingBalance),
        isCashAccount: Value(isCashAccount),
        isDefault: Value(isDefault),
      ),
    );
  }

  Future<bool> updateAccount({
    required int id,
    required String accountName,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? branch,
    double openingBalance = 0.0,
    bool isCashAccount = false,
    bool isDefault = false,
  }) {
    return _bankDao.updateAccount(
      BankAccountsCompanion(
        id: Value(id),
        accountName: Value(accountName.trim()),
        bankName: Value(bankName?.trim()),
        accountNumber: Value(accountNumber?.trim()),
        ifscCode: Value(ifscCode?.trim()),
        branch: Value(branch?.trim()),
        openingBalance: Value(openingBalance),
        isCashAccount: Value(isCashAccount),
        isDefault: Value(isDefault),
      ),
    );
  }

  Future<int> deleteAccount(int id) => _bankDao.deleteAccount(id);

  /// Transfer funds between two accounts (Contra entry: Cash Deposit / Cash Withdrawal / Bank Transfer).
  ///
  /// P&L unaffected (affectsPnl = false).
  /// AffectsCash = true for both transactions so each individual account updates its running balance.
  Future<void> transferFunds({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    required DateTime date,
    String? narration,
    String? referenceNo,
  }) async {
    final fromAcc = await _bankDao.getAccountById(fromAccountId);
    final toAcc = await _bankDao.getAccountById(toAccountId);
    if (fromAcc == null || toAcc == null) {
      throw StateError('Source or target account not found.');
    }

    // Get Admin / Overhead project ID for contra transfer entries
    final adminProject = await _db.projectDao.getAdminOverheadProject();
    final projId = adminProject?.id ?? 1;

    await _db.transaction(() async {
      // 1. Debit outflow from source account
      await _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projId,
          date: date,
          type: TransactionType.expense,
          affectsPnl: const Value(false), // Contra transfer is NOT an operating expense
          affectsCash: const Value(true),
          amount: amount,
          bankAccountId: Value(fromAccountId),
          paymentMode: Value(fromAcc.isCashAccount ? PaymentMode.cash : PaymentMode.bank),
          narration: Value(narration ?? 'Fund Transfer to ${toAcc.accountName}'),
          referenceNo: Value(referenceNo),
        ),
      );

      // 2. Credit inflow into destination account
      await _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projId,
          date: date,
          type: TransactionType.income,
          affectsPnl: const Value(false), // Contra transfer is NOT operating income
          affectsCash: const Value(true),
          amount: amount,
          bankAccountId: Value(toAccountId),
          paymentMode: Value(toAcc.isCashAccount ? PaymentMode.cash : PaymentMode.bank),
          narration: Value(narration ?? 'Fund Transfer from ${fromAcc.accountName}'),
          referenceNo: Value(referenceNo),
        ),
      );
    });
  }
}
