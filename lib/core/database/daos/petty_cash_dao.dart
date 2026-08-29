import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import '../app_database.dart';
import '../tables/petty_cash_wallets_table.dart';
import '../tables/petty_cash_vouchers_table.dart';
import '../tables/projects_table.dart';
import '../tables/bank_accounts_table.dart';
import '../tables/transactions_table.dart';

part 'petty_cash_dao.g.dart';

/// Supervisor Petty Cash Wallet with Computed Running Balance
class PettyCashWalletSummary {
  final PettyCashWallet wallet;
  final Project? assignedProject;
  final double totalAdvancesReceived;
  final double totalExpensesClaimed;
  final double totalCashReturned;
  final double currentUnspentCashBalance;
  final int voucherCount;

  PettyCashWalletSummary({
    required this.wallet,
    this.assignedProject,
    required this.totalAdvancesReceived,
    required this.totalExpensesClaimed,
    required this.totalCashReturned,
    required this.currentUnspentCashBalance,
    required this.voucherCount,
  });
}

/// Detailed Voucher entry with linked models
class PettyCashVoucherDetail {
  final PettyCashVoucher voucher;
  final PettyCashWallet wallet;
  final Project project;
  final BankAccount? bankAccount;

  PettyCashVoucherDetail({
    required this.voucher,
    required this.wallet,
    required this.project,
    this.bankAccount,
  });
}

/// Portfolio-wide Petty Cash Float Metrics
class PettyCashPortfolioMetrics {
  final int activeSupervisorsCount;
  final double totalFloatDisbursed;
  final double totalSiteExpensesClaimed;
  final double totalCashReturned;
  final double totalCashInSupervisorsPockets;

  PettyCashPortfolioMetrics({
    required this.activeSupervisorsCount,
    required this.totalFloatDisbursed,
    required this.totalSiteExpensesClaimed,
    required this.totalCashReturned,
    required this.totalCashInSupervisorsPockets,
  });
}

@DriftAccessor(tables: [
  PettyCashWallets,
  PettyCashVouchers,
  Projects,
  BankAccounts,
  Transactions,
])
class PettyCashDao extends DatabaseAccessor<AppDatabase> with _$PettyCashDaoMixin {
  PettyCashDao(super.db);

  // ─── Wallet Operations ─────────────────────────────────────────────────────

  Future<int> insertWallet(PettyCashWalletsCompanion companion) =>
      into(pettyCashWallets).insert(companion);

  Future<bool> updateWallet(PettyCashWalletsCompanion companion) =>
      update(pettyCashWallets).replace(companion);

  Future<int> deleteWallet(int id) =>
      (delete(pettyCashWallets)..where((w) => w.id.equals(id))).go();

  // ─── Voucher Operations ────────────────────────────────────────────────────

  Future<int> insertVoucher(PettyCashVouchersCompanion companion) =>
      into(pettyCashVouchers).insert(companion);

  Future<bool> updateVoucher(PettyCashVouchersCompanion companion) =>
      update(pettyCashVouchers).replace(companion);

  Future<int> deleteVoucher(int id) =>
      (delete(pettyCashVouchers)..where((v) => v.id.equals(id))).go();

  // ─── Stream Queries ───────────────────────────────────────────────────────

  /// Watch all supervisor wallets with computed live balances
  Stream<List<PettyCashWalletSummary>> watchAllWalletsWithBalances() {
    return customSelect(
      'SELECT 1',
      readsFrom: {pettyCashWallets, pettyCashVouchers, projects},
    ).watch().asyncMap((_) async {
      final wallets = await (select(pettyCashWallets)
            ..orderBy([(w) => OrderingTerm.asc(w.supervisorName)]))
          .get();

      final allProjects = await select(projects).get();
      final projectMap = {for (final p in allProjects) p.id: p};

      final allVouchers = await select(pettyCashVouchers).get();
      final voucherMap = <int, List<PettyCashVoucher>>{};
      for (final v in allVouchers) {
        voucherMap.putIfAbsent(v.walletId, () => []).add(v);
      }

      return wallets.map((w) {
        final vList = voucherMap[w.id] ?? [];

        double advances = 0.0;
        double expenses = 0.0;
        double returned = 0.0;

        for (final v in vList) {
          switch (v.type) {
            case PettyCashTxnType.advanceDisbursed:
            case PettyCashTxnType.floatReplenished:
              advances += v.amount;
              break;
            case PettyCashTxnType.voucherExpense:
              expenses += v.amount;
              break;
            case PettyCashTxnType.cashReturned:
              returned += v.amount;
              break;
          }
        }

        final unspentBalance = advances - expenses - returned;

        return PettyCashWalletSummary(
          wallet: w,
          assignedProject: w.assignedProjectId != null ? projectMap[w.assignedProjectId] : null,
          totalAdvancesReceived: advances,
          totalExpensesClaimed: expenses,
          totalCashReturned: returned,
          currentUnspentCashBalance: unspentBalance,
          voucherCount: vList.length,
        );
      }).toList();
    });
  }

  /// Watch single wallet by ID
  Stream<PettyCashWalletSummary?> watchWalletById(int id) {
    return watchAllWalletsWithBalances().map((list) {
      final matches = list.where((item) => item.wallet.id == id);
      return matches.isNotEmpty ? matches.first : null;
    });
  }

  /// Watch filtered petty cash vouchers
  Stream<List<PettyCashVoucherDetail>> watchVouchers({
    int? walletId,
    int? projectId,
    PettyCashTxnType? type,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return customSelect(
      'SELECT 1',
      readsFrom: {pettyCashVouchers, pettyCashWallets, projects, bankAccounts},
    ).watch().asyncMap((_) async {
      final query = select(pettyCashVouchers)
        ..orderBy([(v) => OrderingTerm.desc(v.date), (v) => OrderingTerm.desc(v.id)]);

      if (walletId != null) query.where((v) => v.walletId.equals(walletId));
      if (projectId != null) query.where((v) => v.projectId.equals(projectId));
      if (type != null) query.where((v) => v.type.equalsValue(type));
      if (fromDate != null) query.where((v) => v.date.isBiggerOrEqualValue(fromDate));
      if (toDate != null) query.where((v) => v.date.isSmallerOrEqualValue(toDate));

      final vouchers = await query.get();

      final allWallets = await select(pettyCashWallets).get();
      final walletMap = {for (final w in allWallets) w.id: w};

      final allProjects = await select(projects).get();
      final projectMap = {for (final p in allProjects) p.id: p};

      final allAccounts = await select(bankAccounts).get();
      final accountMap = {for (final a in allAccounts) a.id: a};

      final results = <PettyCashVoucherDetail>[];
      for (final v in vouchers) {
        final w = walletMap[v.walletId];
        final p = projectMap[v.projectId];
        if (w != null && p != null) {
          results.add(PettyCashVoucherDetail(
            voucher: v,
            wallet: w,
            project: p,
            bankAccount: v.bankAccountId != null ? accountMap[v.bankAccountId] : null,
          ));
        }
      }
      return results;
    });
  }

  /// Watch Portfolio metrics
  Stream<PettyCashPortfolioMetrics> watchPettyCashPortfolioMetrics() {
    return customSelect(
      'SELECT 1',
      readsFrom: {pettyCashWallets, pettyCashVouchers},
    ).watch().asyncMap((_) async {
      final wallets = await select(pettyCashWallets).get();
      final vouchers = await select(pettyCashVouchers).get();

      final activeCount = wallets.where((w) => w.isActive).length;

      double totalAdvances = 0.0;
      double totalExpenses = 0.0;
      double totalReturned = 0.0;

      for (final v in vouchers) {
        switch (v.type) {
          case PettyCashTxnType.advanceDisbursed:
          case PettyCashTxnType.floatReplenished:
            totalAdvances += v.amount;
            break;
          case PettyCashTxnType.voucherExpense:
            totalExpenses += v.amount;
            break;
          case PettyCashTxnType.cashReturned:
            totalReturned += v.amount;
            break;
        }
      }

      final totalHeld = totalAdvances - totalExpenses - totalReturned;

      return PettyCashPortfolioMetrics(
        activeSupervisorsCount: activeCount,
        totalFloatDisbursed: totalAdvances,
        totalSiteExpensesClaimed: totalExpenses,
        totalCashReturned: totalReturned,
        totalCashInSupervisorsPockets: totalHeld,
      );
    });
  }
}
