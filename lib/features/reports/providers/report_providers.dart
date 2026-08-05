import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/reports/data/report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReportRepository(
    db.transactionDao,
    db.projectDao,
    db.depositDao,
    db.expenseCategoryDao,
  );
});

/// Project P&L for a specific project (family provider).
final projectPnlProvider =
    FutureProvider.family<ProjectPnl, int>((ref, projectId) {
  return ref.watch(reportRepositoryProvider).getProjectPnl(projectId);
});

/// Consolidated P&L across all projects.
final consolidatedPnlProvider =
    FutureProvider<List<ProjectPnl>>((ref) {
  return ref.watch(reportRepositoryProvider).getConsolidatedPnl();
});

/// Selected project for P&L report screen.
final reportProjectFilterProvider = StateProvider<int?>((ref) => null);

/// Expense category breakdown — optionally scoped to a project.
final expenseCategoryBreakdownProvider =
    FutureProvider.family<ExpenseCategoryBreakdown, int?>((ref, projectId) {
  return ref
      .watch(reportRepositoryProvider)
      .getExpenseCategoryBreakdown(projectId: projectId);
});
