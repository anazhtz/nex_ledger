import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/tables/bank_accounts_table.dart';
import 'package:nex_ledger/core/database/tables/client_ra_bills_table.dart';
import 'package:nex_ledger/core/database/tables/client_receipts_table.dart';
import 'package:nex_ledger/core/database/tables/projects_table.dart';
import 'package:nex_ledger/core/database/tables/transactions_table.dart';

part 'client_billing_dao.g.dart';

/// Full detail of a Client RA Bill with joined project and transaction.
class ClientRaBillDetail {
  final ClientRaBill bill;
  final Transaction transaction;
  final Project project;

  ClientRaBillDetail({
    required this.bill,
    required this.transaction,
    required this.project,
  });
}

/// Full detail of a Client Receipt with joined project, transaction, bill, and bank account.
class ClientReceiptDetail {
  final ClientReceipt receipt;
  final Transaction transaction;
  final Project project;
  final ClientRaBill? clientRaBill;
  final BankAccount? bankAccount;

  ClientReceiptDetail({
    required this.receipt,
    required this.transaction,
    required this.project,
    this.clientRaBill,
    this.bankAccount,
  });
}

/// Real-time revenue progress metrics for a project's client contract.
class ProjectRevenueProgress {
  final Project project;
  final double clientContractValue;
  final double totalGrossBilled;
  final double totalRetentionWithheld;
  final double totalAdvanceRecovered;
  final double totalTdsDeducted;
  final double totalNetCertifiedInvoiced;
  final double totalClientReceipts;
  final double clientOutstandingReceivables;
  final double clientRetentionHeldByClient;
  final double billingProgressPercentage;
  final double unbilledContractValue;
  final int raBillCount;
  final int receiptCount;

  ProjectRevenueProgress({
    required this.project,
    required this.clientContractValue,
    required this.totalGrossBilled,
    required this.totalRetentionWithheld,
    required this.totalAdvanceRecovered,
    required this.totalTdsDeducted,
    required this.totalNetCertifiedInvoiced,
    required this.totalClientReceipts,
    required this.clientOutstandingReceivables,
    required this.clientRetentionHeldByClient,
    required this.billingProgressPercentage,
    required this.unbilledContractValue,
    required this.raBillCount,
    required this.receiptCount,
  });
}

@DriftAccessor(tables: [
  ClientRaBills,
  ClientReceipts,
  Projects,
  Transactions,
  BankAccounts,
])
class ClientBillingDao extends DatabaseAccessor<AppDatabase>
    with _$ClientBillingDaoMixin {
  ClientBillingDao(super.db);

  // ─── Client RA Bills Queries ───────────────────────────────────────────────

  Stream<List<ClientRaBillDetail>> watchClientRaBills({int? projectId}) {
    final query = select(clientRaBills).join([
      innerJoin(projects, projects.id.equalsExp(clientRaBills.projectId)),
      innerJoin(transactions,
          transactions.id.equalsExp(clientRaBills.transactionId)),
    ]);

    if (projectId != null) {
      query.where(clientRaBills.projectId.equals(projectId));
    }

    query.orderBy([OrderingTerm.desc(clientRaBills.billDate)]);

    return query.watch().map((rows) {
      return rows.map((r) {
        return ClientRaBillDetail(
          bill: r.readTable(clientRaBills),
          transaction: r.readTable(transactions),
          project: r.readTable(projects),
        );
      }).toList();
    });
  }

  Future<ClientRaBillDetail?> getClientRaBillById(int id) async {
    final query = select(clientRaBills).join([
      innerJoin(projects, projects.id.equalsExp(clientRaBills.projectId)),
      innerJoin(transactions,
          transactions.id.equalsExp(clientRaBills.transactionId)),
    ])..where(clientRaBills.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    return ClientRaBillDetail(
      bill: row.readTable(clientRaBills),
      transaction: row.readTable(transactions),
      project: row.readTable(projects),
    );
  }

  Future<int> insertClientRaBill(ClientRaBillsCompanion entry) =>
      into(clientRaBills).insert(entry);

  Future<int> deleteClientRaBill(int id) async {
    final bill = await (select(clientRaBills)..where((b) => b.id.equals(id)))
        .getSingleOrNull();
    if (bill == null) return 0;

    return db.transaction(() async {
      await (delete(transactions)..where((t) => t.id.equals(bill.transactionId)))
          .go();
      return (delete(clientRaBills)..where((b) => b.id.equals(id))).go();
    });
  }

  // ─── Client Receipts Queries ───────────────────────────────────────────────

  Stream<List<ClientReceiptDetail>> watchClientReceipts({
    int? projectId,
    int? raBillId,
  }) {
    final query = select(clientReceipts).join([
      innerJoin(projects, projects.id.equalsExp(clientReceipts.projectId)),
      innerJoin(transactions,
          transactions.id.equalsExp(clientReceipts.transactionId)),
      leftOuterJoin(clientRaBills,
          clientRaBills.id.equalsExp(clientReceipts.clientRaBillId)),
      leftOuterJoin(bankAccounts,
          bankAccounts.id.equalsExp(clientReceipts.bankAccountId)),
    ]);

    if (projectId != null) {
      query.where(clientReceipts.projectId.equals(projectId));
    }
    if (raBillId != null) {
      query.where(clientReceipts.clientRaBillId.equals(raBillId));
    }

    query.orderBy([OrderingTerm.desc(clientReceipts.receiptDate)]);

    return query.watch().map((rows) {
      return rows.map((r) {
        return ClientReceiptDetail(
          receipt: r.readTable(clientReceipts),
          transaction: r.readTable(transactions),
          project: r.readTable(projects),
          clientRaBill: r.readTableOrNull(clientRaBills),
          bankAccount: r.readTableOrNull(bankAccounts),
        );
      }).toList();
    });
  }

  Future<int> insertClientReceipt(ClientReceiptsCompanion entry) =>
      into(clientReceipts).insert(entry);

  Future<int> deleteClientReceipt(int id) async {
    final receipt = await (select(clientReceipts)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
    if (receipt == null) return 0;

    return db.transaction(() async {
      await (delete(transactions)
            ..where((t) => t.id.equals(receipt.transactionId)))
          .go();
      return (delete(clientReceipts)..where((r) => r.id.equals(id))).go();
    });
  }

  // ─── Project Revenue Progress Streams ──────────────────────────────────────

  Stream<ProjectRevenueProgress?> watchProjectRevenueProgress(int projectId) {
    return customSelect(
      'SELECT 1',
      readsFrom: {projects, clientRaBills, clientReceipts, transactions},
    ).watch().asyncMap((_) async {
      final project = await (select(projects)..where((p) => p.id.equals(projectId)))
          .getSingleOrNull();
      if (project == null) return null;

      final bills = await (select(clientRaBills)
            ..where((b) => b.projectId.equals(projectId)))
          .get();

      final receipts = await (select(clientReceipts)
            ..where((r) => r.projectId.equals(projectId)))
          .get();

      double grossBilled = 0.0;
      double retentionWithheld = 0.0;
      double advanceRecovered = 0.0;
      double tdsDeducted = 0.0;
      double netCertified = 0.0;

      for (final b in bills) {
        grossBilled += b.grossAmount;
        retentionWithheld += b.retentionAmount;
        advanceRecovered += b.advanceDeduction;
        tdsDeducted += b.taxOrTdsDeduction;
        netCertified += b.netCertifiedAmount;
      }

      double totalReceipts = 0.0;
      double retentionReleased = 0.0;

      for (final r in receipts) {
        totalReceipts += r.amount;
        if (r.isRetentionRelease) {
          retentionReleased += r.amount;
        }
      }

      final contractValue = project.clientContractValue > 0
          ? project.clientContractValue
          : (project.budget ?? grossBilled);

      final unbilled = (contractValue - grossBilled).clamp(0.0, double.infinity);
      final progressPct = contractValue > 0
          ? ((grossBilled / contractValue) * 100).clamp(0.0, 999.0)
          : 0.0;

      final outstanding = (netCertified - totalReceipts).clamp(0.0, double.infinity);
      final remainingRetention = (retentionWithheld - retentionReleased).clamp(0.0, double.infinity);

      return ProjectRevenueProgress(
        project: project,
        clientContractValue: contractValue,
        totalGrossBilled: grossBilled,
        totalRetentionWithheld: retentionWithheld,
        totalAdvanceRecovered: advanceRecovered,
        totalTdsDeducted: tdsDeducted,
        totalNetCertifiedInvoiced: netCertified,
        totalClientReceipts: totalReceipts,
        clientOutstandingReceivables: outstanding,
        clientRetentionHeldByClient: remainingRetention,
        billingProgressPercentage: progressPct,
        unbilledContractValue: unbilled,
        raBillCount: bills.length,
        receiptCount: receipts.length,
      );
    });
  }

  Stream<List<ProjectRevenueProgress>> watchAllProjectRevenueSummaries() {
    return customSelect(
      'SELECT 1',
      readsFrom: {projects, clientRaBills, clientReceipts, transactions},
    ).watch().asyncMap((_) async {
      final allProjects = await (select(projects)
            ..where((p) => p.type.equalsValue(ProjectType.project))
            ..orderBy([(p) => OrderingTerm.asc(p.name)]))
          .get();

      final results = <ProjectRevenueProgress>[];

      for (final p in allProjects) {
        final bills = await (select(clientRaBills)
              ..where((b) => b.projectId.equals(p.id)))
            .get();

        final receipts = await (select(clientReceipts)
              ..where((r) => r.projectId.equals(p.id)))
            .get();

        double grossBilled = 0.0;
        double retentionWithheld = 0.0;
        double advanceRecovered = 0.0;
        double tdsDeducted = 0.0;
        double netCertified = 0.0;

        for (final b in bills) {
          grossBilled += b.grossAmount;
          retentionWithheld += b.retentionAmount;
          advanceRecovered += b.advanceDeduction;
          tdsDeducted += b.taxOrTdsDeduction;
          netCertified += b.netCertifiedAmount;
        }

        double totalReceipts = 0.0;
        double retentionReleased = 0.0;

        for (final r in receipts) {
          totalReceipts += r.amount;
          if (r.isRetentionRelease) {
            retentionReleased += r.amount;
          }
        }

        final contractValue = p.clientContractValue > 0
            ? p.clientContractValue
            : (p.budget ?? grossBilled);

        final unbilled = (contractValue - grossBilled).clamp(0.0, double.infinity);
        final progressPct = contractValue > 0
            ? ((grossBilled / contractValue) * 100).clamp(0.0, 999.0)
            : 0.0;

        final outstanding = (netCertified - totalReceipts).clamp(0.0, double.infinity);
        final remainingRetention =
            (retentionWithheld - retentionReleased).clamp(0.0, double.infinity);

        results.add(ProjectRevenueProgress(
          project: p,
          clientContractValue: contractValue,
          totalGrossBilled: grossBilled,
          totalRetentionWithheld: retentionWithheld,
          totalAdvanceRecovered: advanceRecovered,
          totalTdsDeducted: tdsDeducted,
          totalNetCertifiedInvoiced: netCertified,
          totalClientReceipts: totalReceipts,
          clientOutstandingReceivables: outstanding,
          clientRetentionHeldByClient: remainingRetention,
          billingProgressPercentage: progressPct,
          unbilledContractValue: unbilled,
          raBillCount: bills.length,
          receiptCount: receipts.length,
        ));
      }

      return results;
    });
  }
}
