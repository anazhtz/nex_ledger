import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/subcontract/data/subcontract_repository.dart';

final subcontractRepositoryProvider = Provider<SubcontractRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SubcontractRepository(db.subcontractDao, db.transactionDao, db);
});

// ─── Subcontractors Providers ─────────────────────────────────────────────────

final subcontractorListProvider = StreamProvider<List<Subcontractor>>((ref) {
  return ref.watch(subcontractRepositoryProvider).watchAllSubcontractors();
});

final subcontractorSummariesProvider =
    StreamProvider<List<SubcontractorSummary>>((ref) {
  return ref.watch(subcontractRepositoryProvider).watchAllSubcontractorSummaries();
});

final subcontractorByIdProvider =
    StreamProvider.family<Subcontractor?, int>((ref, id) {
  final db = ref.watch(appDatabaseProvider);
  return db.subcontractDao.watchAllSubcontractors().map((list) {
    for (final s in list) {
      if (s.id == id) return s;
    }
    return null;
  });
});

// ─── Work Orders Filters & Providers ──────────────────────────────────────────

final subcontractProjectFilterProvider = StateProvider<int?>((ref) => null);
final subcontractStatusFilterProvider =
    StateProvider<WorkOrderStatus?>((ref) => null);
final subcontractSearchQueryProvider = StateProvider<String>((ref) => '');

final workOrdersListProvider = StreamProvider<List<WorkOrderDetail>>((ref) {
  final explicitProject = ref.watch(subcontractProjectFilterProvider);
  final globalProject = ref.watch(selectedProjectIdProvider);
  final projectId = explicitProject ?? globalProject;
  final status = ref.watch(subcontractStatusFilterProvider);
  final repo = ref.watch(subcontractRepositoryProvider);

  return repo.watchWorkOrders(projectId: projectId, status: status);
});

final workOrderDetailProvider =
    StreamProvider.family<WorkOrderDetail?, int>((ref, workOrderId) {
  final repo = ref.watch(subcontractRepositoryProvider);
  return repo.watchWorkOrders().map((list) {
    for (final wo in list) {
      if (wo.workOrder.id == workOrderId) return wo;
    }
    return null;
  });
});

final workOrderFinancialSummaryProvider =
    StreamProvider.family<WorkOrderFinancialSummary?, int>((ref, workOrderId) {
  final repo = ref.watch(subcontractRepositoryProvider);
  return repo.watchWorkOrderFinancialSummary(workOrderId);
});

// ─── Measurement Bills & Payments Providers ───────────────────────────────────

final measurementBillsListProvider =
    StreamProvider.family<List<MeasurementBillDetail>, int?>((ref, workOrderId) {
  final explicitProject = ref.watch(subcontractProjectFilterProvider);
  final globalProject = ref.watch(selectedProjectIdProvider);
  final projectId = workOrderId == null ? (explicitProject ?? globalProject) : null;
  final repo = ref.watch(subcontractRepositoryProvider);

  return repo.watchMeasurementBills(
    workOrderId: workOrderId,
    projectId: projectId,
  );
});

final subcontractPaymentsListProvider =
    StreamProvider.family<List<SubcontractPaymentDetail>, int?>((ref, subcontractorId) {
  final repo = ref.watch(subcontractRepositoryProvider);
  return repo.watchSubcontractPayments(subcontractorId: subcontractorId);
});

// ─── Subcontract Totals KPI Provider ──────────────────────────────────────────

class SubcontractOverviewMetrics {
  final double totalContractValue;
  final double totalGrossCertified;
  final double totalRetentionHeld;
  final double totalPaid;
  final double totalNetDue;
  final int activeContractsCount;

  const SubcontractOverviewMetrics({
    required this.totalContractValue,
    required this.totalGrossCertified,
    required this.totalRetentionHeld,
    required this.totalPaid,
    required this.totalNetDue,
    required this.activeContractsCount,
  });
}

final subcontractOverviewMetricsProvider =
    StreamProvider<SubcontractOverviewMetrics>((ref) {
  return ref.watch(subcontractorSummariesProvider.stream).map((summaries) {
    double totalContract = 0.0;
    double totalGross = 0.0;
    double totalRetention = 0.0;
    double totalPaid = 0.0;
    double totalDue = 0.0;
    int activeCount = 0;

    for (final s in summaries) {
      totalContract += s.totalContractValue;
      totalGross += s.totalGrossCertified;
      totalRetention += s.totalRetentionHeld;
      totalPaid += s.totalPaid;
      totalDue += s.currentNetDue;
      activeCount += s.activeWorkOrdersCount;
    }

    return SubcontractOverviewMetrics(
      totalContractValue: totalContract,
      totalGrossCertified: totalGross,
      totalRetentionHeld: totalRetention,
      totalPaid: totalPaid,
      totalNetDue: totalDue,
      activeContractsCount: activeCount,
    );
  });
});
