import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/tables/transactions_table.dart';
import 'package:nex_ledger/core/database/tables/projects_table.dart';

part 'transaction_dao.g.dart';

/// Combined result for a transaction with its project name.
class TransactionWithProject {
  final Transaction transaction;
  final Project project;
  TransactionWithProject(this.transaction, this.project);
}

@DriftAccessor(tables: [Transactions, Projects])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  /// Watch all transactions joined with project, newest first.
  Stream<List<TransactionWithProject>> watchAllTransactions() {
    final query = select(transactions).join([
      innerJoin(projects, projects.id.equalsExp(transactions.projectId)),
    ])
      ..orderBy([OrderingTerm.desc(transactions.date)]);
    return query.watch().map(
          (rows) => rows
              .map(
                (r) => TransactionWithProject(
                  r.readTable(transactions),
                  r.readTable(projects),
                ),
              )
              .toList(),
        );
  }

  /// Watch all raw transactions ordered by date desc.
  Stream<List<Transaction>> watchAllRawTransactions() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  /// Watch transactions for a specific project.
  Stream<List<Transaction>> watchTransactionsByProject(int projectId) =>
      (select(transactions)
            ..where((t) => t.projectId.equals(projectId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  /// Watch transactions filtered by type list.
  Stream<List<TransactionWithProject>> watchFilteredTransactions({
    int? projectId,
    List<TransactionType>? types,
    DateTime? from,
    DateTime? to,
  }) {
    final query = select(transactions).join([
      innerJoin(projects, projects.id.equalsExp(transactions.projectId)),
    ]);
    if (projectId != null) {
      query.where(transactions.projectId.equals(projectId));
    }
    if (types != null && types.isNotEmpty) {
      query.where(
        transactions.type.isIn(types.map((t) => t.name).toList()),
      );
    }
    if (from != null) {
      query.where(transactions.date.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where(transactions.date.isSmallerOrEqualValue(to));
    }
    query.orderBy([OrderingTerm.desc(transactions.date)]);
    return query.watch().map(
          (rows) => rows
              .map(
                (r) => TransactionWithProject(
                  r.readTable(transactions),
                  r.readTable(projects),
                ),
              )
              .toList(),
        );
  }

  /// Insert a transaction and return its id.
  Future<int> insertTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  /// Sum of all cash-affecting amounts (credits - debits) = cash balance.
  /// Credits: income, deposit. Debits: expense, purchase, labourPayment, depositRefund.
  Stream<double> watchCashBalance() {
    final balanceExp = CustomExpression<double>(
      "SUM(CASE WHEN type IN ('income', 'deposit') THEN amount ELSE -amount END)"
    );

    final query = selectOnly(transactions)
      ..addColumns([balanceExp])
      ..where(transactions.affectsCash.equals(true));

    return query.watchSingle().map((row) => row.read(balanceExp) ?? 0.0);
  }

  /// Sum of amount for a project filtered by type and affectsPnl flag.
  Future<double> sumByProjectAndTypes(
    int projectId,
    List<TransactionType> types, {
    bool? affectsPnlFilter,
  }) async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.projectId.equals(projectId))
      ..where(transactions.type.isIn(types.map((t) => t.name).toList()));
    if (affectsPnlFilter != null) {
      query.where(
        affectsPnlFilter
            ? transactions.affectsPnl.equals(true)
            : transactions.affectsPnl.equals(false),
      );
    }
    final result = await query.getSingle();
    return result.read(transactions.amount.sum()) ?? 0.0;
  }

  /// Get all expense transactions that have a category assigned.
  /// Used for expense category breakdown reports.
  Future<List<Transaction>> getExpensesWithCategory({int? projectId}) async {
    final query = select(transactions)
      ..where((t) => t.type.equals(TransactionType.expense.name))
      ..where((t) => t.expenseCategoryId.isNotNull());
    if (projectId != null) {
      query.where((t) => t.projectId.equals(projectId));
    }
    return query.get();
  }

  /// Watch all expense transactions that have a category assigned.
  Stream<List<Transaction>> watchExpensesWithCategory({int? projectId}) {
    final query = select(transactions)
      ..where((t) => t.type.equals(TransactionType.expense.name))
      ..where((t) => t.expenseCategoryId.isNotNull());
    if (projectId != null) {
      query.where((t) => t.projectId.equals(projectId));
    }
    return query.watch();
  }
}
