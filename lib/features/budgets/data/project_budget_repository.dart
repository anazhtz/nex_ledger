import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/daos/project_budget_dao.dart';

class ProjectBudgetRepository {
  final ProjectBudgetDao _budgetDao;
  final ProjectDao _projectDao;
  final TransactionDao _txnDao;
  final AppDatabase _db;

  ProjectBudgetRepository(
    this._budgetDao,
    this._projectDao,
    this._txnDao,
    this._db,
  );

  /// Set or update budget for a single cost head
  Future<int> upsertBudget({
    required int projectId,
    required BudgetCostHead costHead,
    required double allocatedAmount,
    double alertThresholdPercentage = 85.0,
    String? notes,
  }) {
    return _budgetDao.upsertBudget(
      projectId: projectId,
      costHead: costHead,
      allocatedAmount: allocatedAmount,
      alertThresholdPercentage: alertThresholdPercentage,
      notes: notes,
    );
  }

  /// Bulk set or update all cost heads for a project
  Future<void> setProjectBudgets({
    required int projectId,
    required Map<BudgetCostHead, double> allocations,
    double alertThresholdPercentage = 85.0,
  }) {
    return _budgetDao.setProjectBudgets(
      projectId: projectId,
      allocations: allocations,
      alertThresholdPercentage: alertThresholdPercentage,
    );
  }

  /// Watch budget rows for a single project
  Stream<List<ProjectBudget>> watchBudgetsForProject(int projectId) {
    return _budgetDao.watchBudgetsForProject(projectId);
  }

  /// Watch comprehensive Budget vs Actual variance summary for a project
  Stream<ProjectBudgetSummary?> watchProjectBudgetSummary(int projectId) {
    return _budgetDao.watchProjectBudgetSummary(projectId);
  }

  /// Watch Budget vs Actual summaries across all projects
  Stream<List<ProjectBudgetSummary>> watchAllProjectBudgetSummaries() {
    return _budgetDao.watchAllProjectBudgetSummaries();
  }

  /// Watch Portfolio-wide metrics
  Stream<BudgetPortfolioMetrics> watchBudgetPortfolioMetrics() {
    return _budgetDao.watchBudgetPortfolioMetrics();
  }

  /// Evaluate real-time budget impact when entering a new expense/purchase
  Future<BudgetAlertResult> evaluateBudgetImpact({
    required int projectId,
    required BudgetCostHead costHead,
    required double newAmount,
  }) {
    return _budgetDao.evaluateBudgetImpact(
      projectId: projectId,
      costHead: costHead,
      newAmount: newAmount,
    );
  }

  /// Delete single budget row
  Future<int> deleteBudget(int id) {
    return _budgetDao.deleteBudget(id);
  }

  /// Delete all budgets for a project
  Future<int> deleteBudgetsForProject(int projectId) {
    return _budgetDao.deleteBudgetsForProject(projectId);
  }
}
