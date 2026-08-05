import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';

/// P&L summary per project.
class ProjectPnl {
  final Project project;
  final double income;
  final double expenses;
  final double purchases;
  final double labourCosts;
  final double netPnl;
  final double depositsHeld;

  ProjectPnl({
    required this.project,
    required this.income,
    required this.expenses,
    required this.purchases,
    required this.labourCosts,
    required this.depositsHeld,
  }) : netPnl = income - expenses - purchases - labourCosts;
}

/// Row in the deposit ledger report.
class DepositLedgerRow {
  final DepositDetail detail;
  final double received;
  final double adjusted;
  final double refunded;
  final double held;
  DepositLedgerRow({
    required this.detail,
    required this.received,
    required this.adjusted,
    required this.refunded,
    required this.held,
  });
}

/// Expense breakdown — Group → SubCategory → total amount
typedef ExpenseCategoryBreakdown = Map<String, Map<String, double>>;

class ReportRepository {
  final TransactionDao _txnDao;
  final ProjectDao _projectDao;
  final DepositDao _depositDao;
  final ExpenseCategoryDao _categoryDao;

  ReportRepository(
      this._txnDao, this._projectDao, this._depositDao, this._categoryDao);

  /// Compute P&L for a single project.
  /// ONLY sums transactions WHERE affectsPnl = true.
  Future<ProjectPnl> getProjectPnl(int projectId) async {
    final project = await _projectDao.getProjectById(projectId);
    if (project == null) throw StateError('Project $projectId not found');

    final income = await _txnDao.sumByProjectAndTypes(
      projectId,
      [TransactionType.income],
      affectsPnlFilter: true,
    );
    final expenses = await _txnDao.sumByProjectAndTypes(
      projectId,
      [TransactionType.expense],
      affectsPnlFilter: true,
    );
    final purchases = await _txnDao.sumByProjectAndTypes(
      projectId,
      [TransactionType.purchase],
      affectsPnlFilter: true,
    );
    final labourCosts = await _txnDao.sumByProjectAndTypes(
      projectId,
      [TransactionType.labourPayment],
      affectsPnlFilter: true,
    );
    final depositsHeld = await _getProjectDepositsHeld(projectId);

    return ProjectPnl(
      project: project,
      income: income,
      expenses: expenses,
      purchases: purchases,
      labourCosts: labourCosts,
      depositsHeld: depositsHeld,
    );
  }

  /// Compute consolidated P&L across all projects.
  Future<List<ProjectPnl>> getConsolidatedPnl() async {
    final allProjects = await _projectDao.getAllProjects();
    final results = <ProjectPnl>[];
    for (final p in allProjects) {
      results.add(await getProjectPnl(p.id));
    }
    return results;
  }

  /// Get deposit ledger for a project.
  Future<List<DepositDetail>> getDepositLedger(int projectId) =>
      _depositDao.watchDepositsByProject(projectId).first;

  /// Get expense breakdown by category group → sub-category → total amount.
  /// Pass [projectId] = null for company-wide breakdown.
  Future<ExpenseCategoryBreakdown> getExpenseCategoryBreakdown({
    int? projectId,
  }) async {
    // Get all expense transactions with a category
    final txns = await _txnDao.getExpensesWithCategory(projectId: projectId);
    // Get all category details
    final allCats = await _categoryDao.getAllActiveCategories();
    final catById = {for (final c in allCats) c.id: c};

    // Build the nested map: group → subCategory → sum
    final result = <String, Map<String, double>>{};
    for (final txn in txns) {
      if (txn.expenseCategoryId == null) continue;
      final cat = catById[txn.expenseCategoryId!];
      if (cat == null) continue;
      result
          .putIfAbsent(cat.groupName, () => {})
          .update(cat.subCategory, (v) => v + txn.amount, ifAbsent: () => txn.amount);
    }
    return result;
  }

  /// Helper: sum net remaining deposits held for a project.
  Future<double> _getProjectDepositsHeld(int projectId) async {
    final deposits =
        await _depositDao.watchDepositsByProject(projectId).first;
    double held = 0.0;
    for (final d in deposits) {
      if (d.deposit.status == DepositStatus.held ||
          d.deposit.status == DepositStatus.partiallyAdjusted) {
        final original = d.transaction.amount;
        final adjusted = d.deposit.adjustedAmount;
        final remaining = original - adjusted;
        if (remaining > 0) {
          held += remaining;
        }
      }
    }
    return held;
  }
}
