import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/tables/bank_accounts_table.dart';
import 'package:nex_ledger/core/database/tables/transactions_table.dart';

part 'bank_account_dao.g.dart';

/// Combined account with its computed live balance.
class BankAccountWithBalance {
  final BankAccount account;
  final double currentBalance;
  final double totalInflow;
  final double totalOutflow;

  BankAccountWithBalance({
    required this.account,
    required this.currentBalance,
    required this.totalInflow,
    required this.totalOutflow,
  });
}

@DriftAccessor(tables: [BankAccounts, Transactions])
class BankAccountDao extends DatabaseAccessor<AppDatabase>
    with _$BankAccountDaoMixin {
  BankAccountDao(super.db);

  /// Watch all accounts ordered by cash first, default first, then name.
  Stream<List<BankAccount>> watchAllAccounts() => (select(bankAccounts)
        ..orderBy([
          (b) => OrderingTerm.desc(b.isCashAccount),
          (b) => OrderingTerm.desc(b.isDefault),
          (b) => OrderingTerm.asc(b.accountName),
        ]))
      .watch();

  Future<List<BankAccount>> getAllAccounts() => select(bankAccounts).get();

  Future<BankAccount?> getAccountById(int id) =>
      (select(bankAccounts)..where((b) => b.id.equals(id))).getSingleOrNull();

  Future<int> insertAccount(BankAccountsCompanion entry) =>
      into(bankAccounts).insert(entry);

  Future<bool> updateAccount(BankAccountsCompanion entry) =>
      update(bankAccounts).replace(entry);

  Future<int> deleteAccount(int id) =>
      (delete(bankAccounts)..where((b) => b.id.equals(id))).go();

  /// Watch all accounts with their real-time calculated running balances.
  Stream<List<BankAccountWithBalance>> watchAccountsWithBalances() {
    return watchAllAccounts().asyncMap((accounts) async {
      final allTxns = await (select(transactions)
            ..where((t) => t.affectsCash.equals(true)))
          .get();

      return accounts.map((acc) {
        double inflow = 0.0;
        double outflow = 0.0;

        for (final t in allTxns) {
          // If transaction is explicitly tagged to this bank account
          // OR if account is cash drawer and transaction mode is cash and no other account assigned
          final matchesAccount = t.bankAccountId == acc.id ||
              (acc.isCashAccount &&
                  t.bankAccountId == null &&
                  (t.paymentMode == PaymentMode.cash || t.paymentMode == null)) ||
              (!acc.isCashAccount &&
                  acc.isDefault &&
                  t.bankAccountId == null &&
                  t.paymentMode != PaymentMode.cash &&
                  t.paymentMode != null);

          if (matchesAccount) {
            if (t.type.isDebit) {
              outflow += t.amount;
            } else {
              inflow += t.amount;
            }
          }
        }

        final current = acc.openingBalance + inflow - outflow;
        return BankAccountWithBalance(
          account: acc,
          currentBalance: current,
          totalInflow: inflow,
          totalOutflow: outflow,
        );
      }).toList();
    });
  }

  /// Watch total liquidity breakdown: (Cash in Hand, In Bank Accounts, Total Available).
  Stream<({double cashInHand, double inBanks, double totalLiquidity})>
      watchLiquiditySummary() {
    return watchAccountsWithBalances().map((list) {
      double cash = 0.0;
      double bank = 0.0;

      for (final item in list) {
        if (item.account.isCashAccount) {
          cash += item.currentBalance;
        } else {
          bank += item.currentBalance;
        }
      }

      return (
        cashInHand: cash,
        inBanks: bank,
        totalLiquidity: cash + bank,
      );
    });
  }
}
