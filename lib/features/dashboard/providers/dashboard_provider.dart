import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
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

  DashboardSummary({
    required this.cashBalance,
    required this.totalDepositsHeld,
    required this.activeProjects,
    required this.projectPnls,
  });
}

final dashboardSummaryProvider =
    FutureProvider<DashboardSummary>((ref) async {
  final cashBalance =
      await ref.watch(cashBalanceProvider.future);
  final depositsHeld =
      await ref.watch(totalDepositsHeldProvider.future);
  final activeProjects =
      await ref.watch(activeProjectsProvider.future);

  // Get P&L for each active project
  final repo = ref.watch(reportRepositoryProvider);
  final pnls = <ProjectPnl>[];
  for (final p in activeProjects) {
    try {
      pnls.add(await repo.getProjectPnl(p.id));
    } catch (_) {
      // Skip if project has no data yet
    }
  }

  return DashboardSummary(
    cashBalance: cashBalance,
    totalDepositsHeld: depositsHeld,
    activeProjects: activeProjects,
    projectPnls: pnls,
  );
});
