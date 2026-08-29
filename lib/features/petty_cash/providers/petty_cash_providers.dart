import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/database/daos/petty_cash_dao.dart';
import 'package:nex_ledger/features/petty_cash/data/petty_cash_repository.dart';

/// Petty Cash Repository Provider
final pettyCashRepositoryProvider = Provider<PettyCashRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PettyCashRepository(
    db.pettyCashDao,
    db.transactionDao,
    db,
  );
});

// ─── Filter States ──────────────────────────────────────────────────────────

final pettyCashFilterSupervisorProvider = StateProvider<int?>((ref) => null);
final pettyCashFilterProjectProvider = StateProvider<int?>((ref) => null);
final pettyCashFilterTypeProvider = StateProvider<PettyCashTxnType?>((ref) => null);
final pettyCashSearchQueryProvider = StateProvider<String>((ref) => '');

// ─── Streams ────────────────────────────────────────────────────────────────

final allWalletsProvider =
    StreamProvider<List<PettyCashWalletSummary>>((ref) {
  final repo = ref.watch(pettyCashRepositoryProvider);
  return repo.watchAllWalletsWithBalances();
});

final singleWalletProvider =
    StreamProvider.family<PettyCashWalletSummary?, int>((ref, id) {
  final repo = ref.watch(pettyCashRepositoryProvider);
  return repo.watchWalletById(id);
});

final allPettyCashVouchersProvider =
    StreamProvider<List<PettyCashVoucherDetail>>((ref) {
  final repo = ref.watch(pettyCashRepositoryProvider);
  final supervisorId = ref.watch(pettyCashFilterSupervisorProvider);
  final projectId = ref.watch(pettyCashFilterProjectProvider);
  final type = ref.watch(pettyCashFilterTypeProvider);

  return repo.watchVouchers(
    walletId: supervisorId,
    projectId: projectId,
    type: type,
  );
});

final pettyCashPortfolioMetricsProvider =
    StreamProvider<PettyCashPortfolioMetrics>((ref) {
  final repo = ref.watch(pettyCashRepositoryProvider);
  return repo.watchPettyCashPortfolioMetrics();
});

// ─── Filtered Data Providers ────────────────────────────────────────────────

final filteredWalletsProvider =
    Provider<AsyncValue<List<PettyCashWalletSummary>>>((ref) {
  final allAsync = ref.watch(allWalletsProvider);
  final search = ref.watch(pettyCashSearchQueryProvider).trim().toLowerCase();

  return allAsync.whenData((list) {
    if (search.isEmpty) return list;
    return list.where((item) {
      final matchesName = item.wallet.supervisorName.toLowerCase().contains(search);
      final matchesPhone = item.wallet.phone.toLowerCase().contains(search);
      final matchesProj = (item.assignedProject?.name ?? '').toLowerCase().contains(search);
      return matchesName || matchesPhone || matchesProj;
    }).toList();
  });
});

final filteredPettyCashVouchersProvider =
    Provider<AsyncValue<List<PettyCashVoucherDetail>>>((ref) {
  final allAsync = ref.watch(allPettyCashVouchersProvider);
  final search = ref.watch(pettyCashSearchQueryProvider).trim().toLowerCase();

  return allAsync.whenData((list) {
    if (search.isEmpty) return list;
    return list.where((item) {
      final v = item.voucher;
      final matchesNarration = v.narration.toLowerCase().contains(search);
      final matchesVoucher = (v.voucherNumber ?? '').toLowerCase().contains(search);
      final matchesCat = v.category.toLowerCase().contains(search);
      final matchesSupervisor = item.wallet.supervisorName.toLowerCase().contains(search);
      final matchesProj = item.project.name.toLowerCase().contains(search);
      return matchesNarration || matchesVoucher || matchesCat || matchesSupervisor || matchesProj;
    }).toList();
  });
});
