import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/tables/project_budgets_table.dart';
import 'package:nex_ledger/core/database/tables/projects_table.dart';
import 'package:nex_ledger/core/database/tables/transactions_table.dart';

part 'project_budget_dao.g.dart';

/// Variance details for an individual cost head
class CostHeadVariance {
  final BudgetCostHead costHead;
  final double allocatedBudget;
  final double actualSpent;
  final double variance; // allocatedBudget - actualSpent (positive = savings, negative = overrun)
  final double utilizationPercentage; // (actualSpent / allocatedBudget) * 100
  final double alertThresholdPercentage;
  final BudgetHealthStatus status;

  const CostHeadVariance({
    required this.costHead,
    required this.allocatedBudget,
    required this.actualSpent,
    required this.variance,
    required this.utilizationPercentage,
    required this.alertThresholdPercentage,
    required this.status,
  });

  bool get isOverBudget => status == BudgetHealthStatus.overBudget;
  bool get isWarning => status == BudgetHealthStatus.warning;
  bool get isConfigured => allocatedBudget > 0;
  double get overrunAmount => actualSpent > allocatedBudget ? actualSpent - allocatedBudget : 0.0;
  double get remainingBudget => allocatedBudget > actualSpent ? allocatedBudget - actualSpent : 0.0;
}

/// Consolidated Budget vs Actual summary for a project
class ProjectBudgetSummary {
  final Project project;
  final double totalAllocatedBudget;
  final double totalActualCost;
  final double netVariance; // totalAllocatedBudget - totalActualCost
  final double overallUtilizationPercentage;
  final BudgetHealthStatus overallStatus;
  final List<CostHeadVariance> costHeads;
  final int overBudgetCategoriesCount;
  final int warningCategoriesCount;

  const ProjectBudgetSummary({
    required this.project,
    required this.totalAllocatedBudget,
    required this.totalActualCost,
    required this.netVariance,
    required this.overallUtilizationPercentage,
    required this.overallStatus,
    required this.costHeads,
    required this.overBudgetCategoriesCount,
    required this.warningCategoriesCount,
  });

  bool get isOverBudget => overallStatus == BudgetHealthStatus.overBudget || overBudgetCategoriesCount > 0;
  bool get isWarning => overallStatus == BudgetHealthStatus.warning || warningCategoriesCount > 0;
}

/// Portfolio-wide Budget Metrics across all active projects
class BudgetPortfolioMetrics {
  final double totalPortfolioBudget;
  final double totalPortfolioActualSpent;
  final double netPortfolioVariance;
  final double portfolioUtilizationPercentage;
  final int totalProjectsCount;
  final int budgetedProjectsCount;
  final int healthyProjectsCount;
  final int warningProjectsCount;
  final int overBudgetProjectsCount;

  const BudgetPortfolioMetrics({
    required this.totalPortfolioBudget,
    required this.totalPortfolioActualSpent,
    required this.netPortfolioVariance,
    required this.portfolioUtilizationPercentage,
    required this.totalProjectsCount,
    required this.budgetedProjectsCount,
    required this.healthyProjectsCount,
    required this.warningProjectsCount,
    required this.overBudgetProjectsCount,
  });
}

/// Result of evaluating real-time budget impact when entering a new expense/purchase
class BudgetAlertResult {
  final bool hasBudget;
  final BudgetCostHead costHead;
  final double allocatedBudget;
  final double currentSpent;
  final double addedAmount;
  final double projectedSpent;
  final double currentUtilizationPct;
  final double projectedUtilizationPct;
  final double alertThresholdPct;
  final BudgetHealthStatus status;
  final double overrunAmount;
  final String? warningMessage;

  const BudgetAlertResult({
    required this.hasBudget,
    required this.costHead,
    required this.allocatedBudget,
    required this.currentSpent,
    required this.addedAmount,
    required this.projectedSpent,
    required this.currentUtilizationPct,
    required this.projectedUtilizationPct,
    required this.alertThresholdPct,
    required this.status,
    required this.overrunAmount,
    this.warningMessage,
  });

  bool get isCriticalOverrun => status == BudgetHealthStatus.overBudget;
  bool get isCautionWarning => status == BudgetHealthStatus.warning;
  bool get requiresAlert => isCriticalOverrun || isCautionWarning;
}

@DriftAccessor(tables: [ProjectBudgets, Projects, Transactions])
class ProjectBudgetDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectBudgetDaoMixin {
  ProjectBudgetDao(super.db);

  /// Upsert a budget allocation for a project and cost head
  Future<int> upsertBudget({
    required int projectId,
    required BudgetCostHead costHead,
    required double allocatedAmount,
    double alertThresholdPercentage = 85.0,
    String? notes,
  }) async {
    final existing = await (select(projectBudgets)
          ..where((b) => b.projectId.equals(projectId) & b.costHead.equalsValue(costHead)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(projectBudgets)..where((b) => b.id.equals(existing.id))).write(
        ProjectBudgetsCompanion(
          allocatedAmount: Value(allocatedAmount),
          alertThresholdPercentage: Value(alertThresholdPercentage),
          notes: Value(notes),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return existing.id;
    } else {
      return into(projectBudgets).insert(
        ProjectBudgetsCompanion.insert(
          projectId: projectId,
          costHead: costHead,
          allocatedAmount: allocatedAmount,
          alertThresholdPercentage: Value(alertThresholdPercentage),
          notes: Value(notes),
        ),
      );
    }
  }

  /// Bulk set or update all cost heads for a project
  Future<void> setProjectBudgets({
    required int projectId,
    required Map<BudgetCostHead, double> allocations,
    double alertThresholdPercentage = 85.0,
  }) async {
    await transaction(() async {
      for (final entry in allocations.entries) {
        if (entry.value >= 0) {
          await upsertBudget(
            projectId: projectId,
            costHead: entry.key,
            allocatedAmount: entry.value,
            alertThresholdPercentage: alertThresholdPercentage,
          );
        }
      }
    });
  }

  /// Watch budget rows for a single project
  Stream<List<ProjectBudget>> watchBudgetsForProject(int projectId) {
    return (select(projectBudgets)
          ..where((b) => b.projectId.equals(projectId))
          ..orderBy([(b) => OrderingTerm.asc(b.id)]))
        .watch();
  }

  /// Watch all budget rows
  Stream<List<ProjectBudget>> watchAllBudgets() {
    return select(projectBudgets).watch();
  }

  /// Delete a single budget entry
  Future<int> deleteBudget(int id) {
    return (delete(projectBudgets)..where((b) => b.id.equals(id))).go();
  }

  /// Delete all budgets for a project
  Future<int> deleteBudgetsForProject(int projectId) {
    return (delete(projectBudgets)..where((b) => b.projectId.equals(projectId))).go();
  }

  /// Watch comprehensive Budget vs Actual variance summary for a project
  Stream<ProjectBudgetSummary?> watchProjectBudgetSummary(int projectId) {
    return customSelect(
      'SELECT 1',
      readsFrom: {projectBudgets, projects, transactions},
    ).watch().asyncMap((_) async {
      final project = await (select(projects)..where((p) => p.id.equals(projectId))).getSingleOrNull();
      if (project == null) return null;

      final budgetRows = await (select(projectBudgets)..where((b) => b.projectId.equals(projectId))).get();
      final pnlTxns = await (select(transactions)
            ..where((t) => t.projectId.equals(projectId) & t.affectsPnl.equals(true)))
          .get();

      return _calculateProjectSummary(project, budgetRows, pnlTxns);
    });
  }

  /// Watch Budget vs Actual summaries across all projects
  Stream<List<ProjectBudgetSummary>> watchAllProjectBudgetSummaries() {
    return customSelect(
      'SELECT 1',
      readsFrom: {projectBudgets, projects, transactions},
    ).watch().asyncMap((_) async {
      final allProjects = await (select(projects)
            ..where((p) => p.type.equalsValue(ProjectType.project))
            ..orderBy([(p) => OrderingTerm.asc(p.name)]))
          .get();

      final allBudgets = await select(projectBudgets).get();
      final allPnlTxns = await (select(transactions)..where((t) => t.affectsPnl.equals(true))).get();

      final budgetMap = <int, List<ProjectBudget>>{};
      for (final b in allBudgets) {
        budgetMap.putIfAbsent(b.projectId, () => []).add(b);
      }

      final txnMap = <int, List<Transaction>>{};
      for (final t in allPnlTxns) {
        txnMap.putIfAbsent(t.projectId, () => []).add(t);
      }

      final summaries = <ProjectBudgetSummary>[];
      for (final p in allProjects) {
        final bRows = budgetMap[p.id] ?? [];
        final pTxns = txnMap[p.id] ?? [];
        summaries.add(_calculateProjectSummary(p, bRows, pTxns));
      }
      return summaries;
    });
  }

  /// Watch Portfolio metrics
  Stream<BudgetPortfolioMetrics> watchBudgetPortfolioMetrics() {
    return watchAllProjectBudgetSummaries().map((summaries) {
      double totalBudget = 0.0;
      double totalActual = 0.0;
      int budgetedCount = 0;
      int healthyCount = 0;
      int warningCount = 0;
      int overBudgetCount = 0;

      for (final s in summaries) {
        totalBudget += s.totalAllocatedBudget;
        totalActual += s.totalActualCost;
        if (s.totalAllocatedBudget > 0) budgetedCount++;

        if (s.isOverBudget) {
          overBudgetCount++;
        } else if (s.isWarning) {
          warningCount++;
        } else {
          healthyCount++;
        }
      }

      final utilizationPct = totalBudget > 0 ? (totalActual / totalBudget) * 100 : 0.0;

      return BudgetPortfolioMetrics(
        totalPortfolioBudget: totalBudget,
        totalPortfolioActualSpent: totalActual,
        netPortfolioVariance: totalBudget - totalActual,
        portfolioUtilizationPercentage: utilizationPct,
        totalProjectsCount: summaries.length,
        budgetedProjectsCount: budgetedCount,
        healthyProjectsCount: healthyCount,
        warningProjectsCount: warningCount,
        overBudgetProjectsCount: overBudgetCount,
      );
    });
  }

  /// Real-time evaluation of how an upcoming transaction will affect the project's budget
  Future<BudgetAlertResult> evaluateBudgetImpact({
    required int projectId,
    required BudgetCostHead costHead,
    required double newAmount,
  }) async {
    final budgetRow = await (select(projectBudgets)
          ..where((b) => b.projectId.equals(projectId) & b.costHead.equalsValue(costHead)))
        .getSingleOrNull();

    // Overall total budget fallback
    final overallBudgetRow = await (select(projectBudgets)
          ..where((b) => b.projectId.equals(projectId) & b.costHead.equalsValue(BudgetCostHead.overallTotal)))
        .getSingleOrNull();

    final allocated = budgetRow?.allocatedAmount ?? 0.0;
    final threshold = budgetRow?.alertThresholdPercentage ?? 85.0;

    // Get current spent for this cost head
    final pnlTxns = await (select(transactions)
          ..where((t) => t.projectId.equals(projectId) & t.affectsPnl.equals(true)))
        .get();

    double currentSpent = 0.0;
    for (final t in pnlTxns) {
      if (_matchesCostHead(t, costHead)) {
        currentSpent += t.amount;
      }
    }

    final projectedSpent = currentSpent + newAmount;
    final hasBudget = allocated > 0;

    double currentPct = hasBudget ? (currentSpent / allocated) * 100 : 0.0;
    double projectedPct = hasBudget ? (projectedSpent / allocated) * 100 : 0.0;

    BudgetHealthStatus status = BudgetHealthStatus.healthy;
    double overrunAmount = 0.0;
    String? warningMessage;

    if (hasBudget) {
      if (projectedPct >= 100.0) {
        status = BudgetHealthStatus.overBudget;
        overrunAmount = projectedSpent - allocated;
        warningMessage =
            'CRITICAL OVERRUN: Adding this entry will push ${costHead.displayName} to ${projectedPct.toStringAsFixed(1)}% of budget (${overrunAmount.toStringAsFixed(0)} cost overrun)!';
      } else if (projectedPct >= threshold) {
        status = BudgetHealthStatus.warning;
        warningMessage =
            'BUDGET CAUTION: Adding this entry will utilize ${projectedPct.toStringAsFixed(1)}% of allocated ${costHead.displayName} budget (${(allocated - projectedSpent).toStringAsFixed(0)} remaining).';
      }
    } else if (overallBudgetRow != null && overallBudgetRow.allocatedAmount > 0) {
      // Evaluate against overall project budget if head budget not set
      final totalProjectSpent = pnlTxns.fold<double>(0.0, (sum, t) => sum + t.amount);
      final projectedTotal = totalProjectSpent + newAmount;
      final overallAlloc = overallBudgetRow.allocatedAmount;
      final overallProjPct = (projectedTotal / overallAlloc) * 100;

      if (overallProjPct >= 100.0) {
        status = BudgetHealthStatus.overBudget;
        overrunAmount = projectedTotal - overallAlloc;
        warningMessage =
            'CRITICAL OVERRUN: Total project cost will reach ${overallProjPct.toStringAsFixed(1)}% of overall target budget (${overrunAmount.toStringAsFixed(0)} overrun)!';
      } else if (overallProjPct >= overallBudgetRow.alertThresholdPercentage) {
        status = BudgetHealthStatus.warning;
        warningMessage =
            'BUDGET CAUTION: Total project cost will reach ${overallProjPct.toStringAsFixed(1)}% of overall target budget.';
      }
    }

    return BudgetAlertResult(
      hasBudget: hasBudget || (overallBudgetRow != null && overallBudgetRow.allocatedAmount > 0),
      costHead: costHead,
      allocatedBudget: allocated,
      currentSpent: currentSpent,
      addedAmount: newAmount,
      projectedSpent: projectedSpent,
      currentUtilizationPct: currentPct,
      projectedUtilizationPct: projectedPct,
      alertThresholdPct: threshold,
      status: status,
      overrunAmount: overrunAmount,
      warningMessage: warningMessage,
    );
  }

  // ─── Private Calculation Helpers ──────────────────────────────────────────

  ProjectBudgetSummary _calculateProjectSummary(
    Project project,
    List<ProjectBudget> budgetRows,
    List<Transaction> pnlTxns,
  ) {
    final budgetByHead = <BudgetCostHead, ProjectBudget>{};
    for (final b in budgetRows) {
      budgetByHead[b.costHead] = b;
    }

    double materialsSpent = 0.0;
    double labourSpent = 0.0;
    double subcontractSpent = 0.0;
    double overheadSpent = 0.0;

    for (final t in pnlTxns) {
      switch (t.type) {
        case TransactionType.purchase:
        case TransactionType.stockAllocation:
          materialsSpent += t.amount;
          break;
        case TransactionType.labourPayment:
          labourSpent += t.amount;
          break;
        case TransactionType.subcontractBill:
          subcontractSpent += t.amount;
          break;
        case TransactionType.expense:
          overheadSpent += t.amount;
          break;
        default:
          break;
      }
    }

    final totalActualCost = materialsSpent + labourSpent + subcontractSpent + overheadSpent;

    final costHeadConfigs = [
      (BudgetCostHead.materials, materialsSpent),
      (BudgetCostHead.labour, labourSpent),
      (BudgetCostHead.subcontract, subcontractSpent),
      (BudgetCostHead.equipmentOverhead, overheadSpent),
    ];

    final variances = <CostHeadVariance>[];
    int overBudgetCount = 0;
    int warningCount = 0;
    double sumAllocatedCostHeads = 0.0;

    for (final (head, spent) in costHeadConfigs) {
      final bRow = budgetByHead[head];
      final alloc = bRow?.allocatedAmount ?? 0.0;
      final threshold = bRow?.alertThresholdPercentage ?? 85.0;
      sumAllocatedCostHeads += alloc;

      final variance = alloc - spent;
      final utilPct = alloc > 0 ? (spent / alloc) * 100 : 0.0;

      BudgetHealthStatus status;
      if (alloc <= 0) {
        status = BudgetHealthStatus.healthy;
      } else if (utilPct >= 100.0) {
        status = BudgetHealthStatus.overBudget;
        overBudgetCount++;
      } else if (utilPct >= threshold) {
        status = BudgetHealthStatus.warning;
        warningCount++;
      } else {
        status = BudgetHealthStatus.healthy;
      }

      variances.add(
        CostHeadVariance(
          costHead: head,
          allocatedBudget: alloc,
          actualSpent: spent,
          variance: variance,
          utilizationPercentage: utilPct,
          alertThresholdPercentage: threshold,
          status: status,
        ),
      );
    }

    // Overall total budget: either explicit overallTotal row or sum of heads
    final explicitOverall = budgetByHead[BudgetCostHead.overallTotal];
    final totalAllocated = explicitOverall != null && explicitOverall.allocatedAmount > 0
        ? explicitOverall.allocatedAmount
        : sumAllocatedCostHeads;

    final overallThreshold = explicitOverall?.alertThresholdPercentage ?? 85.0;
    final netVariance = totalAllocated - totalActualCost;
    final overallUtilPct = totalAllocated > 0 ? (totalActualCost / totalAllocated) * 100 : 0.0;

    BudgetHealthStatus overallStatus;
    if (totalAllocated <= 0) {
      overallStatus = BudgetHealthStatus.healthy;
    } else if (overallUtilPct >= 100.0) {
      overallStatus = BudgetHealthStatus.overBudget;
    } else if (overallUtilPct >= overallThreshold) {
      overallStatus = BudgetHealthStatus.warning;
    } else {
      overallStatus = BudgetHealthStatus.healthy;
    }

    return ProjectBudgetSummary(
      project: project,
      totalAllocatedBudget: totalAllocated,
      totalActualCost: totalActualCost,
      netVariance: netVariance,
      overallUtilizationPercentage: overallUtilPct,
      overallStatus: overallStatus,
      costHeads: variances,
      overBudgetCategoriesCount: overBudgetCount,
      warningCategoriesCount: warningCount,
    );
  }

  bool _matchesCostHead(Transaction t, BudgetCostHead head) {
    return switch (head) {
      BudgetCostHead.materials =>
        t.type == TransactionType.purchase || t.type == TransactionType.stockAllocation,
      BudgetCostHead.labour => t.type == TransactionType.labourPayment,
      BudgetCostHead.subcontract => t.type == TransactionType.subcontractBill,
      BudgetCostHead.equipmentOverhead => t.type == TransactionType.expense,
      BudgetCostHead.overallTotal =>
        t.type == TransactionType.purchase ||
            t.type == TransactionType.stockAllocation ||
            t.type == TransactionType.labourPayment ||
            t.type == TransactionType.subcontractBill ||
            t.type == TransactionType.expense,
    };
  }
}
