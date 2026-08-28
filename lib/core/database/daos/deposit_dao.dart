import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/tables/deposits_table.dart';
import 'package:nex_ledger/core/database/tables/transactions_table.dart';
import 'package:nex_ledger/core/database/tables/projects_table.dart';

part 'deposit_dao.g.dart';

/// Combined deposit detail with transaction and project.
class DepositDetail {
  final Deposit deposit;
  final Transaction transaction;
  final Project project;
  DepositDetail(this.deposit, this.transaction, this.project);
}

@DriftAccessor(tables: [Deposits, Transactions, Projects])
class DepositDao extends DatabaseAccessor<AppDatabase> with _$DepositDaoMixin {
  DepositDao(super.db);

  /// Watch all deposits with transaction and project info.
  Stream<List<DepositDetail>> watchAllDeposits() {
    final query = select(deposits).join([
      innerJoin(
          transactions, transactions.id.equalsExp(deposits.transactionId)),
      innerJoin(projects, projects.id.equalsExp(deposits.projectId)),
    ])
      ..orderBy([OrderingTerm.desc(transactions.date)]);
    return query.watch().map(
          (rows) => rows
              .map(
                (r) => DepositDetail(
                  r.readTable(deposits),
                  r.readTable(transactions),
                  r.readTable(projects),
                ),
              )
              .toList(),
        );
  }

  /// Watch deposits for a specific project.
  Stream<List<DepositDetail>> watchDepositsByProject(int projectId) {
    final query = select(deposits).join([
      innerJoin(
          transactions, transactions.id.equalsExp(deposits.transactionId)),
      innerJoin(projects, projects.id.equalsExp(deposits.projectId)),
    ])
      ..where(deposits.projectId.equals(projectId))
      ..orderBy([OrderingTerm.desc(transactions.date)]);
    return query.watch().map(
          (rows) => rows
              .map(
                (r) => DepositDetail(
                  r.readTable(deposits),
                  r.readTable(transactions),
                  r.readTable(projects),
                ),
              )
              .toList(),
        );
  }

  /// Watch total security deposits paid to Govt/Client still held (Asset pending recovery).
  Stream<double> watchTotalDepositsPaidHeld() {
    final heldStatuses = [
      DepositStatus.held.name,
      DepositStatus.partiallyAdjusted.name,
    ];
    final query = select(deposits).join([
      innerJoin(
          transactions, transactions.id.equalsExp(deposits.transactionId)),
    ])
      ..where(deposits.depositType.equals(DepositType.paid.name) &
          deposits.status.isIn(heldStatuses));
    return query.watch().map((rows) {
      return rows.fold<double>(
        0.0,
        (sum, r) {
          final original = r.readTable(transactions).amount;
          final adjusted = r.readTable(deposits).adjustedAmount;
          final remaining = original - adjusted;
          return sum + (remaining > 0 ? remaining : 0.0);
        },
      );
    });
  }

  /// Watch total deposits received from clients still held (Liability).
  Stream<double> watchTotalDepositsReceivedHeld() {
    final heldStatuses = [
      DepositStatus.held.name,
      DepositStatus.partiallyAdjusted.name,
    ];
    final query = select(deposits).join([
      innerJoin(
          transactions, transactions.id.equalsExp(deposits.transactionId)),
    ])
      ..where(deposits.depositType.equals(DepositType.received.name) &
          deposits.status.isIn(heldStatuses));
    return query.watch().map((rows) {
      return rows.fold<double>(
        0.0,
        (sum, r) {
          final original = r.readTable(transactions).amount;
          final adjusted = r.readTable(deposits).adjustedAmount;
          final remaining = original - adjusted;
          return sum + (remaining > 0 ? remaining : 0.0);
        },
      );
    });
  }

  /// Watch total deposits still held (paid + received).
  Stream<double> watchTotalDepositsHeld() {
    final heldStatuses = [
      DepositStatus.held.name,
      DepositStatus.partiallyAdjusted.name,
    ];
    final query = select(deposits).join([
      innerJoin(
          transactions, transactions.id.equalsExp(deposits.transactionId)),
    ])
      ..where(deposits.status.isIn(heldStatuses));
    return query.watch().map((rows) {
      return rows.fold<double>(
        0.0,
        (sum, r) {
          final original = r.readTable(transactions).amount;
          final adjusted = r.readTable(deposits).adjustedAmount;
          final remaining = original - adjusted;
          return sum + (remaining > 0 ? remaining : 0.0);
        },
      );
    });
  }

  /// Insert a deposit record (the transaction row is inserted separately).
  Future<int> insertDeposit(DepositsCompanion entry) =>
      into(deposits).insert(entry);

  /// Update deposit status & adjusted amount (called when adjusting or refunding).
  Future<int> updateDepositStatus(
    int depositId,
    DepositStatus status, {
    double? adjustedAmount,
    String? adjustmentReference,
  }) =>
      (update(deposits)..where((d) => d.id.equals(depositId))).write(
        DepositsCompanion(
          status: Value(status),
          adjustedAmount: adjustedAmount != null
              ? Value(adjustedAmount)
              : const Value.absent(),
          adjustmentReference: adjustmentReference != null
              ? Value(adjustmentReference)
              : const Value.absent(),
        ),
      );

  /// Get a deposit by its id.
  Future<Deposit?> getDepositById(int id) =>
      (select(deposits)..where((d) => d.id.equals(id))).getSingleOrNull();
}
