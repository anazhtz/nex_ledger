import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';
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

/// Accounts Payable (vendor dues) — reactive stream of total unpaid purchase bills.
/// Pass projectId = null for company-wide total.
final accountsPayableProvider =
    StreamProvider.family<double, int?>((ref, projectId) {
  final pnlStream = projectId != null
      ? ref.watch(reportRepositoryProvider).watchProjectPnl(projectId)
      : ref
          .watch(reportRepositoryProvider)
          .watchConsolidatedPnl()
          .map((list) => list.fold<double>(0, (s, p) => s + p.accountsPayable));
  if (projectId != null) {
    return (pnlStream as Stream<ProjectPnl>)
        .map((pnl) => pnl.accountsPayable);
  }
  return pnlStream as Stream<double>;
});

/// Reactive stream of pending/partial purchases (Accounts Payable items).
/// Pass projectId = null for company-wide list.
final pendingPurchasesProvider =
    StreamProvider.family<List<PurchaseDetail>, int?>((ref, projectId) {
  final db = ref.watch(appDatabaseProvider);
  final repo = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
  return repo.watchPendingPurchases(projectId: projectId);
});
