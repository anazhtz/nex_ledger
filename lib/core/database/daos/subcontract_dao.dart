import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';

part 'subcontract_dao.g.dart';

class WorkOrderDetail {
  final WorkOrder workOrder;
  final Project project;
  final Subcontractor subcontractor;

  WorkOrderDetail({
    required this.workOrder,
    required this.project,
    required this.subcontractor,
  });
}

class MeasurementBillDetail {
  final MeasurementBill bill;
  final WorkOrder workOrder;
  final Transaction transaction;
  final Subcontractor subcontractor;
  final Project project;

  MeasurementBillDetail({
    required this.bill,
    required this.workOrder,
    required this.transaction,
    required this.subcontractor,
    required this.project,
  });
}

class SubcontractPaymentDetail {
  final SubcontractPayment payment;
  final Transaction transaction;
  final Subcontractor subcontractor;
  final WorkOrder? workOrder;
  final BankAccount? bankAccount;

  SubcontractPaymentDetail({
    required this.payment,
    required this.transaction,
    required this.subcontractor,
    this.workOrder,
    this.bankAccount,
  });
}

class WorkOrderFinancialSummary {
  final WorkOrder workOrder;
  final double totalMeasuredQuantity;
  final double progressPercentage;
  final double totalGrossCertified;
  final double totalRetentionHeld;
  final double totalNetBillable;
  final double totalPaid;
  final double currentNetDue;
  final int billCount;

  WorkOrderFinancialSummary({
    required this.workOrder,
    required this.totalMeasuredQuantity,
    required this.progressPercentage,
    required this.totalGrossCertified,
    required this.totalRetentionHeld,
    required this.totalNetBillable,
    required this.totalPaid,
    required this.currentNetDue,
    required this.billCount,
  });
}

class SubcontractorSummary {
  final Subcontractor subcontractor;
  final int activeWorkOrdersCount;
  final double totalContractValue;
  final double totalGrossCertified;
  final double totalRetentionHeld;
  final double totalNetBillable;
  final double totalPaid;
  final double currentNetDue;

  SubcontractorSummary({
    required this.subcontractor,
    required this.activeWorkOrdersCount,
    required this.totalContractValue,
    required this.totalGrossCertified,
    required this.totalRetentionHeld,
    required this.totalNetBillable,
    required this.totalPaid,
    required this.currentNetDue,
  });
}

@DriftAccessor(tables: [
  Subcontractors,
  WorkOrders,
  MeasurementBills,
  SubcontractPayments,
  Transactions,
  Projects,
  BankAccounts,
])
class SubcontractDao extends DatabaseAccessor<AppDatabase>
    with _$SubcontractDaoMixin {
  SubcontractDao(super.db);

  // ─── Subcontractors Master ──────────────────────────────────────────────────

  Stream<List<Subcontractor>> watchAllSubcontractors() {
    return (select(subcontractors)
          ..orderBy([(s) => OrderingTerm.asc(s.name)]))
        .watch();
  }

  Future<Subcontractor?> getSubcontractorById(int id) {
    return (select(subcontractors)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertSubcontractor(SubcontractorsCompanion entry) =>
      into(subcontractors).insert(entry);

  Future<bool> updateSubcontractor(SubcontractorsCompanion entry) =>
      update(subcontractors).replace(entry);

  Future<int> deleteSubcontractor(int id) =>
      (delete(subcontractors)..where((s) => s.id.equals(id))).go();

  // ─── Work Orders ────────────────────────────────────────────────────────────

  Stream<List<WorkOrderDetail>> watchWorkOrders({
    int? projectId,
    int? subcontractorId,
    WorkOrderStatus? status,
  }) {
    final query = select(workOrders).join([
      innerJoin(projects, projects.id.equalsExp(workOrders.projectId)),
      innerJoin(subcontractors,
          subcontractors.id.equalsExp(workOrders.subcontractorId)),
    ]);

    if (projectId != null) {
      query.where(workOrders.projectId.equals(projectId));
    }
    if (subcontractorId != null) {
      query.where(workOrders.subcontractorId.equals(subcontractorId));
    }
    if (status != null) {
      query.where(workOrders.status.equals(status.name));
    }

    query.orderBy([OrderingTerm.desc(workOrders.createdAt)]);

    return query.watch().map((rows) {
      return rows.map((r) {
        return WorkOrderDetail(
          workOrder: r.readTable(workOrders),
          project: r.readTable(projects),
          subcontractor: r.readTable(subcontractors),
        );
      }).toList();
    });
  }

  Future<WorkOrderDetail?> getWorkOrderDetailById(int id) async {
    final query = select(workOrders).join([
      innerJoin(projects, projects.id.equalsExp(workOrders.projectId)),
      innerJoin(subcontractors,
          subcontractors.id.equalsExp(workOrders.subcontractorId)),
    ])..where(workOrders.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return WorkOrderDetail(
      workOrder: row.readTable(workOrders),
      project: row.readTable(projects),
      subcontractor: row.readTable(subcontractors),
    );
  }

  Future<int> insertWorkOrder(WorkOrdersCompanion entry) =>
      into(workOrders).insert(entry);

  Future<bool> updateWorkOrder(WorkOrdersCompanion entry) =>
      update(workOrders).replace(entry);

  Future<int> deleteWorkOrder(int id) =>
      (delete(workOrders)..where((w) => w.id.equals(id))).go();

  // ─── Measurement Bills ──────────────────────────────────────────────────────

  Stream<List<MeasurementBillDetail>> watchMeasurementBills({
    int? workOrderId,
    int? projectId,
  }) {
    final query = select(measurementBills).join([
      innerJoin(workOrders, workOrders.id.equalsExp(measurementBills.workOrderId)),
      innerJoin(transactions,
          transactions.id.equalsExp(measurementBills.transactionId)),
      innerJoin(projects, projects.id.equalsExp(workOrders.projectId)),
      innerJoin(subcontractors,
          subcontractors.id.equalsExp(workOrders.subcontractorId)),
    ]);

    if (workOrderId != null) {
      query.where(measurementBills.workOrderId.equals(workOrderId));
    }
    if (projectId != null) {
      query.where(workOrders.projectId.equals(projectId));
    }

    query.orderBy([OrderingTerm.desc(measurementBills.date)]);

    return query.watch().map((rows) {
      return rows.map((r) {
        return MeasurementBillDetail(
          bill: r.readTable(measurementBills),
          workOrder: r.readTable(workOrders),
          transaction: r.readTable(transactions),
          subcontractor: r.readTable(subcontractors),
          project: r.readTable(projects),
        );
      }).toList();
    });
  }

  Future<MeasurementBillDetail?> getMeasurementBillById(int id) async {
    final query = select(measurementBills).join([
      innerJoin(workOrders, workOrders.id.equalsExp(measurementBills.workOrderId)),
      innerJoin(transactions,
          transactions.id.equalsExp(measurementBills.transactionId)),
      innerJoin(projects, projects.id.equalsExp(workOrders.projectId)),
      innerJoin(subcontractors,
          subcontractors.id.equalsExp(workOrders.subcontractorId)),
    ])..where(measurementBills.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return MeasurementBillDetail(
      bill: row.readTable(measurementBills),
      workOrder: row.readTable(workOrders),
      transaction: row.readTable(transactions),
      subcontractor: row.readTable(subcontractors),
      project: row.readTable(projects),
    );
  }

  // ─── Subcontract Payments ───────────────────────────────────────────────────

  Stream<List<SubcontractPaymentDetail>> watchSubcontractPayments({
    int? subcontractorId,
    int? workOrderId,
    int? projectId,
  }) {
    final query = select(subcontractPayments).join([
      innerJoin(transactions,
          transactions.id.equalsExp(subcontractPayments.transactionId)),
      innerJoin(subcontractors,
          subcontractors.id.equalsExp(subcontractPayments.subcontractorId)),
      leftOuterJoin(workOrders,
          workOrders.id.equalsExp(subcontractPayments.workOrderId)),
      leftOuterJoin(bankAccounts,
          bankAccounts.id.equalsExp(subcontractPayments.bankAccountId)),
    ]);

    if (subcontractorId != null) {
      query.where(subcontractPayments.subcontractorId.equals(subcontractorId));
    }
    if (workOrderId != null) {
      query.where(subcontractPayments.workOrderId.equals(workOrderId));
    }
    if (projectId != null) {
      query.where(transactions.projectId.equals(projectId));
    }

    query.orderBy([OrderingTerm.desc(subcontractPayments.paymentDate)]);

    return query.watch().map((rows) {
      return rows.map((r) {
        return SubcontractPaymentDetail(
          payment: r.readTable(subcontractPayments),
          transaction: r.readTable(transactions),
          subcontractor: r.readTable(subcontractors),
          workOrder: r.readTableOrNull(workOrders),
          bankAccount: r.readTableOrNull(bankAccounts),
        );
      }).toList();
    });
  }

  // ─── Work Order Financial Progress Stream ───────────────────────────────────

  Stream<WorkOrderFinancialSummary?> watchWorkOrderFinancialSummary(int workOrderId) {
    return customSelect(
      'SELECT 1',
      readsFrom: {workOrders, measurementBills, subcontractPayments},
    ).watch().asyncMap((_) async {
      final wo = await (select(workOrders)..where((w) => w.id.equals(workOrderId)))
          .getSingleOrNull();
      if (wo == null) return null;

      final bills = await (select(measurementBills)
            ..where((b) => b.workOrderId.equals(workOrderId)))
          .get();

      final payments = await (select(subcontractPayments)
            ..where((p) => p.workOrderId.equals(workOrderId)))
          .get();

      double totalQty = 0.0;
      double totalGross = 0.0;
      double totalRetention = 0.0;

      for (final b in bills) {
        totalQty += b.measuredQuantity;
        totalGross += b.grossAmount;
        totalRetention += b.retentionAmount;
      }

      final totalNet = totalGross - totalRetention;

      double totalPaid = 0.0;
      for (final p in payments) {
        totalPaid += p.amount;
      }

      final progress = wo.estimatedQuantity > 0
          ? ((totalQty / wo.estimatedQuantity) * 100).clamp(0.0, 999.0)
          : 0.0;

      final due = (totalNet - totalPaid).clamp(0.0, double.infinity);

      return WorkOrderFinancialSummary(
        workOrder: wo,
        totalMeasuredQuantity: totalQty,
        progressPercentage: progress,
        totalGrossCertified: totalGross,
        totalRetentionHeld: totalRetention,
        totalNetBillable: totalNet,
        totalPaid: totalPaid,
        currentNetDue: due,
        billCount: bills.length,
      );
    });
  }

  // ─── Subcontractor Comprehensive Summaries ──────────────────────────────────

  Stream<List<SubcontractorSummary>> watchAllSubcontractorSummaries() {
    return customSelect(
      'SELECT 1',
      readsFrom: {subcontractors, workOrders, measurementBills, subcontractPayments},
    ).watch().asyncMap((_) async {
      final subs = await (select(subcontractors)
            ..orderBy([(s) => OrderingTerm.asc(s.name)]))
          .get();
      final results = <SubcontractorSummary>[];

      for (final sub in subs) {
        final wos = await (select(workOrders)
              ..where((w) => w.subcontractorId.equals(sub.id)))
            .get();

        final activeWos = wos.where((w) => w.status == WorkOrderStatus.active).length;
        final totalContract = wos.fold<double>(0.0, (sum, w) => sum + w.contractAmount);

        final woIds = wos.map((w) => w.id).toList();

        double totalGross = 0.0;
        double totalRetention = 0.0;

        if (woIds.isNotEmpty) {
          final bills = await (select(measurementBills)
                ..where((b) => b.workOrderId.isIn(woIds)))
              .get();
          for (final b in bills) {
            totalGross += b.grossAmount;
            totalRetention += b.retentionAmount;
          }
        }

        final totalNet = totalGross - totalRetention;

        final payments = await (select(subcontractPayments)
              ..where((p) => p.subcontractorId.equals(sub.id)))
            .get();

        final totalPaid = payments.fold<double>(0.0, (sum, p) => sum + p.amount);
        final currentDue = (totalNet - totalPaid).clamp(0.0, double.infinity);

        results.add(SubcontractorSummary(
          subcontractor: sub,
          activeWorkOrdersCount: activeWos,
          totalContractValue: totalContract,
          totalGrossCertified: totalGross,
          totalRetentionHeld: totalRetention,
          totalNetBillable: totalNet,
          totalPaid: totalPaid,
          currentNetDue: currentDue,
        ));
      }

      return results;
    });
  }
}
