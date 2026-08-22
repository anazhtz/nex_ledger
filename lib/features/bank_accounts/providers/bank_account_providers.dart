import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/bank_accounts/data/bank_account_repository.dart';

final bankAccountRepositoryProvider = Provider<BankAccountRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BankAccountRepository(db.bankAccountDao, db.transactionDao, db);
});

final bankAccountsListProvider = StreamProvider<List<BankAccount>>((ref) {
  return ref.watch(bankAccountRepositoryProvider).watchAllAccounts();
});

final bankAccountsWithBalancesProvider =
    StreamProvider<List<BankAccountWithBalance>>((ref) {
  return ref.watch(bankAccountRepositoryProvider).watchAccountsWithBalances();
});

final liquiditySummaryProvider =
    StreamProvider<({double cashInHand, double inBanks, double totalLiquidity})>(
        (ref) {
  return ref.watch(bankAccountRepositoryProvider).watchLiquiditySummary();
});
