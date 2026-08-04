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

class ReportRepository {
  final TransactionDao _txnDao;
  final ProjectDao _projectDao;
  final DepositDao _depositDao;

  ReportRepository(this._txnDao, this._projectDao, this._depositDao);

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
