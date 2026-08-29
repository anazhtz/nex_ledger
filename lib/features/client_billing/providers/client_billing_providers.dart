import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/client_billing/data/client_billing_repository.dart';
import 'package:nex_ledger/features/client_billing/data/client_billing_repository.dart'
    as cbr;
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

final clientBillingRepositoryProvider =
    Provider<ClientBillingRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ClientBillingRepository(
    db.clientBillingDao,
    db.transactionDao,
    db.projectDao,
    db,
  );
});

// ─── Filter Providers ─────────────────────────────────────────────────────────

final clientBillingProjectFilterProvider = StateProvider<int?>((ref) => null);

// ─── Revenue Progress Streams ─────────────────────────────────────────────────

final projectRevenueSummariesProvider =
    StreamProvider<List<ProjectRevenueProgress>>((ref) {
  return ref
      .watch(clientBillingRepositoryProvider)
      .watchAllProjectRevenueSummaries();
});

final projectRevenueProgressProvider =
    StreamProvider.family<ProjectRevenueProgress?, int>((ref, projectId) {
  return ref
      .watch(clientBillingRepositoryProvider)
      .watchProjectRevenueProgress(projectId);
});

final clientRaBillsListProvider =
    StreamProvider.family<List<ClientRaBillDetail>, int?>((ref, projectId) {
  final explicitProject = ref.watch(clientBillingProjectFilterProvider);
  final globalProject = ref.watch(selectedProjectIdProvider);
  final effProjectId = projectId ?? explicitProject ?? globalProject;

  return ref
      .watch(clientBillingRepositoryProvider)
      .watchClientRaBills(projectId: effProjectId);
});

final clientReceiptsListProvider =
    StreamProvider.family<List<ClientReceiptDetail>, int?>((ref, projectId) {
  final explicitProject = ref.watch(clientBillingProjectFilterProvider);
  final globalProject = ref.watch(selectedProjectIdProvider);
  final effProjectId = projectId ?? explicitProject ?? globalProject;

  return ref
      .watch(clientBillingRepositoryProvider)
      .watchClientReceipts(projectId: effProjectId);
});

// ─── High-Level Portfolio Overview Metrics ────────────────────────────────────

class ClientPortfolioMetrics {
  final double totalContractValue;
  final double totalGrossBilled;
  final double totalRetentionHeldByClient;
  final double totalCollected;
  final double totalPendingReceivables;
  final int activeProjectsCount;

  const ClientPortfolioMetrics({
    required this.totalContractValue,
    required this.totalGrossBilled,
    required this.totalRetentionHeldByClient,
    required this.totalCollected,
    required this.totalPendingReceivables,
    required this.activeProjectsCount,
  });
}

final clientPortfolioMetricsProvider =
    StreamProvider<ClientPortfolioMetrics>((ref) {
  return ref
      .watch(projectRevenueSummariesProvider.stream)
      .map((summaries) {
    double totalContract = 0.0;
    double totalGross = 0.0;
    double totalRetention = 0.0;
    double totalCollected = 0.0;
    double totalPending = 0.0;
    int activeCount = 0;

    for (final s in summaries) {
      totalContract += s.clientContractValue;
      totalGross += s.totalGrossBilled;
      totalRetention += s.clientRetentionHeldByClient;
      totalCollected += s.totalClientReceipts;
      totalPending += s.clientOutstandingReceivables;
      if (s.clientContractValue > 0 || s.totalGrossBilled > 0) {
        activeCount++;
      }
    }

    return ClientPortfolioMetrics(
      totalContractValue: totalContract,
      totalGrossBilled: totalGross,
      totalRetentionHeldByClient: totalRetention,
      totalCollected: totalCollected,
      totalPendingReceivables: totalPending,
      activeProjectsCount: activeCount,
    );
  });
});
