import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Project P&L for a specific project (family stream provider).
final projectPnlProvider =
    StreamProvider.family<ProjectPnl, int>((ref, projectId) {
  return ref.watch(reportRepositoryProvider).watchProjectPnl(projectId);
});

/// Consolidated P&L across all projects (stream provider).
final consolidatedPnlProvider =
    StreamProvider<List<ProjectPnl>>((ref) {
  return ref.watch(reportRepositoryProvider).watchConsolidatedPnl();
});

/// Selected project for P&L report screen.
final reportProjectFilterProvider = StateProvider<int?>((ref) => null);

/// Expense category breakdown — optionally scoped to a project (stream provider).
final expenseCategoryBreakdownProvider =
    StreamProvider.family<ExpenseCategoryBreakdown, int?>((ref, projectId) {
  return ref
      .watch(reportRepositoryProvider)
      .watchExpenseCategoryBreakdown(projectId: projectId);
});
