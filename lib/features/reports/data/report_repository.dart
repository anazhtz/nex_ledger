import 'dart:async';
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

  /// Unpaid vendor bills — purchase transactions where affectsCash = false.
  /// These have already hit P&L (cost recognized) but cash has not moved yet.
  /// Shown as a liability (Accounts Payable), NOT subtracted again from netPnl.
  final double accountsPayable;

  ProjectPnl({
    required this.project,
    required this.income,
    required this.expenses,
    required this.purchases,
    required this.labourCosts,
    required this.depositsHeld,
    this.accountsPayable = 0.0,
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

/// Day-book transaction item for daily sheets.
class DayBookEntry {
  final Transaction transaction;
  final Project project;
  final BankAccount? bankAccount;
  final String? categoryName;
  final String? vendorName;
  final String? workerName;

  DayBookEntry({
    required this.transaction,
    required this.project,
    this.bankAccount,
    this.categoryName,
    this.vendorName,
    this.workerName,
  });

  bool get isInflow =>
      transaction.type == TransactionType.income ||
      transaction.type == TransactionType.deposit;

  bool get isOutflow =>
      transaction.type == TransactionType.expense ||
      transaction.type == TransactionType.labourPayment ||
      transaction.type == TransactionType.depositRefund ||
      transaction.type == TransactionType.purchasePayment ||
      (transaction.type == TransactionType.purchase && transaction.affectsCash);
}

/// Comprehensive daily day-book summary for a single date.
class DayBookReport {
  final DateTime date;
  final double openingBalance;
  final double totalInflow;
  final double totalOutflow;
  final double netMovement;
  final double closingBalance;
  final double pnlIncome;
  final double pnlExpense;
  final double netPnl;
  final List<DayBookEntry> entries;

  DayBookReport({
    required this.date,
    required this.openingBalance,
    required this.totalInflow,
    required this.totalOutflow,
    required this.netMovement,
    required this.closingBalance,
    required this.pnlIncome,
    required this.pnlExpense,
    required this.netPnl,
    required this.entries,
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
    this._txnDao,
    this._projectDao,
    this._depositDao,
    this._categoryDao,
  );

  /// Reactive stream of P&L for a single project.
  /// Automatically updates whenever transactions, deposits, or project details change.
  Stream<ProjectPnl> watchProjectPnl(int projectId) {
    return _combine3<Project?, List<Transaction>, List<DepositDetail>,
        ProjectPnl>(
      () => _projectDao.watchProjectById(projectId),
      () => _txnDao.watchTransactionsByProject(projectId),
      () => _depositDao.watchDepositsByProject(projectId),
      (project, txns, deposits) {
        if (project == null) {
          throw StateError('Project $projectId not found');
        }

        double income = 0.0;
        double expenses = 0.0;
        double purchases = 0.0;
        double labourCosts = 0.0;
        double positivePayable = 0.0;
        double paidPayable = 0.0;

        for (final t in txns) {
          if (t.affectsPnl) {
            if (t.type == TransactionType.income) {
              income += t.amount;
            } else if (t.type == TransactionType.expense) {
              expenses += t.amount;
            } else if (t.type == TransactionType.purchase ||
                t.type == TransactionType.stockAllocation) {
              purchases += t.amount;
              // If it's a purchase and affectsCash is false, cash hasn't moved — it's a vendor liability.
              if (t.type == TransactionType.purchase && !t.affectsCash) {
                positivePayable += t.amount;
              }
            } else if (t.type == TransactionType.labourPayment) {
              labourCosts += t.amount;
            }
          }
          // purchasePayment (affectsPnl:false, affectsCash:true) reduces accounts payable
          // when the vendor bill is eventually settled.
          if (t.type == TransactionType.purchasePayment) {
            paidPayable += t.amount;
          }
        }

        final accountsPayable =
            (positivePayable - paidPayable).clamp(0.0, double.infinity);

        double depositsHeld = 0.0;
        for (final d in deposits) {
          if (d.deposit.status == DepositStatus.held ||
              d.deposit.status == DepositStatus.partiallyAdjusted) {
            final original = d.transaction.amount;
            final adjusted = d.deposit.adjustedAmount;
            final remaining = original - adjusted;
            if (remaining > 0) {
              depositsHeld += remaining;
            }
          }
        }

        return ProjectPnl(
          project: project,
          income: income,
          expenses: expenses,
          purchases: purchases,
          labourCosts: labourCosts,
          depositsHeld: depositsHeld,
          accountsPayable: accountsPayable,
        );
      },
    );
  }

  /// Reactive stream of consolidated P&L across all projects.
  /// Automatically updates in real time whenever any transaction, deposit, or project changes.
  Stream<List<ProjectPnl>> watchConsolidatedPnl() {
    return _combine3<List<Project>, List<Transaction>, List<DepositDetail>,
        List<ProjectPnl>>(
      () => _projectDao.watchAllProjects(),
      () => _txnDao.watchAllRawTransactions(),
      () => _depositDao.watchAllDeposits(),
      (projects, allTxns, allDeposits) {
        final txnsByProject = <int, List<Transaction>>{};
        for (final t in allTxns) {
          txnsByProject.putIfAbsent(t.projectId, () => []).add(t);
        }

        final depositsByProject = <int, List<DepositDetail>>{};
        for (final d in allDeposits) {
          depositsByProject.putIfAbsent(d.deposit.projectId, () => []).add(d);
        }

        final results = <ProjectPnl>[];
        for (final p in projects) {
          final txns = txnsByProject[p.id] ?? const [];
          final deposits = depositsByProject[p.id] ?? const [];

          double income = 0.0;
          double expenses = 0.0;
          double purchases = 0.0;
          double labourCosts = 0.0;
          double positivePayable = 0.0;
          double paidPayable = 0.0;

          for (final t in txns) {
            if (t.affectsPnl) {
              if (t.type == TransactionType.income) {
                income += t.amount;
              } else if (t.type == TransactionType.expense) {
                expenses += t.amount;
              } else if (t.type == TransactionType.purchase ||
                  t.type == TransactionType.stockAllocation) {
                purchases += t.amount;
                if (t.type == TransactionType.purchase && !t.affectsCash) {
                  positivePayable += t.amount;
                }
              } else if (t.type == TransactionType.labourPayment) {
                labourCosts += t.amount;
              }
            }
            if (t.type == TransactionType.purchasePayment) {
              paidPayable += t.amount;
            }
          }

          final accountsPayable =
              (positivePayable - paidPayable).clamp(0.0, double.infinity);

          double depositsHeld = 0.0;
          for (final d in deposits) {
            if (d.deposit.status == DepositStatus.held ||
                d.deposit.status == DepositStatus.partiallyAdjusted) {
              final original = d.transaction.amount;
              final adjusted = d.deposit.adjustedAmount;
              final remaining = original - adjusted;
              if (remaining > 0) {
                depositsHeld += remaining;
              }
            }
          }

          results.add(ProjectPnl(
            project: p,
            income: income,
            expenses: expenses,
            purchases: purchases,
            labourCosts: labourCosts,
            depositsHeld: depositsHeld,
            accountsPayable: accountsPayable,
          ));
        }

        return results;
      },
    );
  }

  /// Reactive stream of expense breakdown by category group → sub-category → total amount.
  /// Pass [projectId] = null for company-wide breakdown.
  Stream<ExpenseCategoryBreakdown> watchExpenseCategoryBreakdown({
    int? projectId,
  }) {
    return _combine2<List<Transaction>, List<ExpenseCategory>,
        ExpenseCategoryBreakdown>(
      () => _txnDao.watchExpensesWithCategory(projectId: projectId),
      () => _categoryDao.watchAllActiveCategories(),
      (txns, allCats) {
        final catById = {for (final c in allCats) c.id: c};
        final result = <String, Map<String, double>>{};

        for (final txn in txns) {
          if (txn.expenseCategoryId == null) continue;
          final cat = catById[txn.expenseCategoryId!];
          if (cat == null) continue;
          result
              .putIfAbsent(cat.groupName, () => {})
              .update(cat.subCategory, (v) => v + txn.amount,
                  ifAbsent: () => txn.amount);
        }
        return result;
      },
    );
  }

  /// One-off read of P&L for a single project (e.g. for Excel exports).
  Future<ProjectPnl> getProjectPnl(int projectId) =>
      watchProjectPnl(projectId).first;

  /// One-off read of consolidated P&L across all projects (e.g. for Excel exports).
  Future<List<ProjectPnl>> getConsolidatedPnl() =>
      watchConsolidatedPnl().first;

  /// Watch deposit ledger for a project.
  Stream<List<DepositDetail>> watchDepositLedger(int projectId) =>
      _depositDao.watchDepositsByProject(projectId);

  /// Get deposit ledger for a project.
  Future<List<DepositDetail>> getDepositLedger(int projectId) =>
      watchDepositLedger(projectId).first;

  /// Get expense breakdown by category group → sub-category → total amount.
  /// Pass [projectId] = null for company-wide breakdown.
  Future<ExpenseCategoryBreakdown> getExpenseCategoryBreakdown({
    int? projectId,
  }) =>
      watchExpenseCategoryBreakdown(projectId: projectId).first;

  /// Reactive stream of daily day-book transactions & opening/closing summary for [selectedDate].
  Stream<DayBookReport> watchDayBook(
    DateTime selectedDate, {
    int? projectId,
    int? bankAccountId,
  }) {
    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
    final endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59, 999);

    final rawTxnsStream = _txnDao.watchAllRawTransactions();
    final projectsStream = _projectDao.watchAllProjects();

    return _combine2<List<Transaction>, List<Project>, DayBookReport>(
      () => rawTxnsStream,
      () => projectsStream,
      (allTxns, allProjects) {
        final projectMap = {for (final p in allProjects) p.id: p};

        // Compute Opening Balance before startOfDay
        double openingBalance = 0.0;
        for (final t in allTxns) {
          if (t.date.isBefore(startOfDay)) {
            if (bankAccountId != null && t.bankAccountId != bankAccountId) {
              continue;
            }
            if (t.affectsCash) {
              if (t.type == TransactionType.income ||
                  t.type == TransactionType.deposit) {
                openingBalance += t.amount;
              } else if (t.type == TransactionType.expense ||
                  t.type == TransactionType.labourPayment ||
                  t.type == TransactionType.depositRefund ||
                  t.type == TransactionType.purchasePayment ||
                  (t.type == TransactionType.purchase && t.affectsCash)) {
                openingBalance -= t.amount;
              }
            }
          }
        }

        // Filter transactions for this day
        final dayTxns = allTxns.where((t) {
          if (t.date.isBefore(startOfDay) || t.date.isAfter(endOfDay)) return false;
          if (projectId != null && t.projectId != projectId) return false;
          if (bankAccountId != null && t.bankAccountId != bankAccountId) return false;
          return true;
        }).toList();

        double totalInflow = 0.0;
        double totalOutflow = 0.0;
        double pnlIncome = 0.0;
        double pnlExpense = 0.0;

        final entries = <DayBookEntry>[];
        for (final t in dayTxns) {
          final p = projectMap[t.projectId] ??
              Project(
                id: t.projectId,
                code: 'PRJ-${t.projectId}',
                name: 'Project #${t.projectId}',
                type: ProjectType.project,
                status: ProjectStatus.active,
                startDate: t.date,
                createdAt: t.date,
              );

          final entry = DayBookEntry(
            transaction: t,
            project: p,
          );
          entries.add(entry);

          if (t.affectsCash) {
            if (entry.isInflow) {
              totalInflow += t.amount;
            } else if (entry.isOutflow) {
              totalOutflow += t.amount;
            }
          }

          if (t.affectsPnl) {
            if (t.type == TransactionType.income) {
              pnlIncome += t.amount;
            } else if (t.type == TransactionType.expense ||
                t.type == TransactionType.purchase ||
                t.type == TransactionType.labourPayment ||
                t.type == TransactionType.stockAllocation) {
              pnlExpense += t.amount;
            }
          }
        }

        final netMovement = totalInflow - totalOutflow;
        final closingBalance = openingBalance + netMovement;
        final netPnl = pnlIncome - pnlExpense;

        return DayBookReport(
          date: selectedDate,
          openingBalance: openingBalance,
          totalInflow: totalInflow,
          totalOutflow: totalOutflow,
          netMovement: netMovement,
          closingBalance: closingBalance,
          pnlIncome: pnlIncome,
          pnlExpense: pnlExpense,
          netPnl: netPnl,
          entries: entries,
        );
      },
    );
  }
}

/// Helper to combine two streams into one.
Stream<R> _combine2<A, B, R>(
  Stream<A> Function() createStreamA,
  Stream<B> Function() createStreamB,
  R Function(A a, B b) combiner,
) {
  late StreamController<R> controller;
  A? lastA;
  B? lastB;
  bool hasA = false;
  bool hasB = false;

  void tryEmit() {
    if (hasA && hasB && !controller.isClosed) {
      try {
        controller.add(combiner(lastA as A, lastB as B));
      } catch (e, st) {
        controller.addError(e, st);
      }
    }
  }

  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;

  controller = StreamController<R>.broadcast(
    onListen: () {
      subA = createStreamA().listen(
        (a) {
          lastA = a;
          hasA = true;
          tryEmit();
        },
        onError: controller.addError,
      );
      subB = createStreamB().listen(
        (b) {
          lastB = b;
          hasB = true;
          tryEmit();
        },
        onError: controller.addError,
      );
    },
    onCancel: () async {
      await subA?.cancel();
      await subB?.cancel();
      subA = null;
      subB = null;
      hasA = false;
      hasB = false;
    },
  );

  return controller.stream;
}

/// Helper to combine three streams into one.
Stream<R> _combine3<A, B, C, R>(
  Stream<A> Function() createStreamA,
  Stream<B> Function() createStreamB,
  Stream<C> Function() createStreamC,
  R Function(A a, B b, C c) combiner,
) {
  late StreamController<R> controller;
  A? lastA;
  B? lastB;
  C? lastC;
  bool hasA = false;
  bool hasB = false;
  bool hasC = false;

  void tryEmit() {
    if (hasA && hasB && hasC && !controller.isClosed) {
      try {
        controller.add(combiner(lastA as A, lastB as B, lastC as C));
      } catch (e, st) {
        controller.addError(e, st);
      }
    }
  }

  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;
  StreamSubscription<C>? subC;

  controller = StreamController<R>.broadcast(
    onListen: () {
      subA = createStreamA().listen(
        (a) {
          lastA = a;
          hasA = true;
          tryEmit();
        },
        onError: controller.addError,
      );
      subB = createStreamB().listen(
        (b) {
          lastB = b;
          hasB = true;
          tryEmit();
        },
        onError: controller.addError,
      );
      subC = createStreamC().listen(
        (c) {
          lastC = c;
          hasC = true;
          tryEmit();
        },
        onError: controller.addError,
      );
    },
    onCancel: () async {
      await subA?.cancel();
      await subB?.cancel();
      await subC?.cancel();
      subA = null;
      subB = null;
      subC = null;
      hasA = false;
      hasB = false;
      hasC = false;
    },
  );

  return controller.stream;
}
