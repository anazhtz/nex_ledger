import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/cash_book/providers/cash_book_providers.dart';
import 'package:nex_ledger/features/deposits/providers/deposit_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/reports/data/report_repository.dart';
import 'package:nex_ledger/features/reports/providers/report_providers.dart';

/// Dashboard summary combining multiple streams.
class DashboardSummary {
  final double cashBalance;
  final double totalDepositsHeld;
  final List<Project> activeProjects;
  final List<ProjectPnl> projectPnls;

  /// Physical cash received / paid out today (same rule as the cash balance).
  final double todayIn;
  final double todayOut;

  /// Unpaid vendor bills across all projects.
  final double accountsPayable;

  DashboardSummary({
    required this.cashBalance,
    required this.totalDepositsHeld,
    required this.activeProjects,
    required this.projectPnls,
    this.todayIn = 0.0,
    this.todayOut = 0.0,
    this.accountsPayable = 0.0,
  });
}

/// Types that bring cash in. Must match [TransactionDao.watchCashBalance].
const _cashInTypes = {
  TransactionType.income,
  TransactionType.deposit,
  TransactionType.depositRecovery,
  TransactionType.ownerCapital,
};

class TodayCashFlow {
  final double inflow;
  final double outflow;
  const TodayCashFlow(this.inflow, this.outflow);
}

/// Cash that physically moved today, across all projects.
final todayCashFlowProvider = StreamProvider<TodayCashFlow>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.transactionDao.watchAllRawTransactions().map((txns) {
    final now = DateTime.now();
    double inflow = 0, outflow = 0;
    for (final t in txns) {
      if (!t.affectsCash) continue;
      if (t.date.year != now.year ||
          t.date.month != now.month ||
          t.date.day != now.day) {
        continue;
      }
      if (_cashInTypes.contains(t.type)) {
        inflow += t.amount;
      } else {
        outflow += t.amount;
      }
    }
    return TodayCashFlow(inflow, outflow);
  });
});

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final cashBalance = await ref.watch(cashBalanceProvider.future);
  final depositsHeld = await ref.watch(totalDepositsHeldProvider.future);
  final activeProjects = await ref.watch(activeProjectsProvider.future);
  final allPnls = await ref.watch(consolidatedPnlProvider.future);
  final today = await ref.watch(todayCashFlowProvider.future);

  final activeIds = {for (final p in activeProjects) p.id};
  final activePnls =
      allPnls.where((p) => activeIds.contains(p.project.id)).toList();

  return DashboardSummary(
    cashBalance: cashBalance,
    totalDepositsHeld: depositsHeld,
    activeProjects: activeProjects,
    projectPnls: activePnls,
    todayIn: today.inflow,
    todayOut: today.outflow,
    accountsPayable: allPnls.fold<double>(0.0, (a, p) => a + p.accountsPayable),
  );
});
