import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/tables/purchases_table.dart';
import 'package:nex_ledger/core/database/tables/transactions_table.dart';
import 'package:nex_ledger/core/database/tables/vendors_table.dart';
import 'package:nex_ledger/core/database/tables/projects_table.dart';

part 'purchase_dao.g.dart';

/// Combined result with all related entities.
class PurchaseDetail {
  final Purchase purchase;
  final Transaction transaction;
  final Vendor vendor;
  final Project project;
  PurchaseDetail(this.purchase, this.transaction, this.vendor, this.project);
}

@DriftAccessor(tables: [Purchases, Transactions, Vendors, Projects])
class PurchaseDao extends DatabaseAccessor<AppDatabase>
    with _$PurchaseDaoMixin {
  PurchaseDao(super.db);

  /// Watch all purchases with full detail, newest first.
  Stream<List<PurchaseDetail>> watchAllPurchases() {
    final query = select(purchases).join([
      innerJoin(
          transactions, transactions.id.equalsExp(purchases.transactionId)),
      innerJoin(vendors, vendors.id.equalsExp(purchases.vendorId)),
      innerJoin(projects, projects.id.equalsExp(transactions.projectId)),
    ])
      ..orderBy([OrderingTerm.desc(transactions.date)]);
    return query.watch().map(
          (rows) => rows
              .map(
                (r) => PurchaseDetail(
                  r.readTable(purchases),
                  r.readTable(transactions),
                  r.readTable(vendors),
                  r.readTable(projects),
                ),
              )
              .toList(),
        );
  }

  /// Watch purchases filtered by project.
  Stream<List<PurchaseDetail>> watchPurchasesByProject(int projectId) {
    final query = select(purchases).join([
      innerJoin(
          transactions, transactions.id.equalsExp(purchases.transactionId)),
      innerJoin(vendors, vendors.id.equalsExp(purchases.vendorId)),
      innerJoin(projects, projects.id.equalsExp(transactions.projectId)),
    ])
      ..where(transactions.projectId.equals(projectId))
      ..orderBy([OrderingTerm.desc(transactions.date)]);
    return query.watch().map(
          (rows) => rows
              .map(
                (r) => PurchaseDetail(
                  r.readTable(purchases),
                  r.readTable(transactions),
                  r.readTable(vendors),
                  r.readTable(projects),
                ),
              )
              .toList(),
        );
  }

  /// Update payment status of a purchase.
  Future<int> updatePaymentStatus(
      int purchaseId, PaymentStatus status) =>
      (update(purchases)..where((p) => p.id.equals(purchaseId)))
          .write(PurchasesCompanion(paymentStatus: Value(status)));

  // --- Vendor helpers ---

  Stream<List<Vendor>> watchAllVendors() =>
      (select(vendors)..orderBy([(v) => OrderingTerm.asc(v.name)])).watch();

  Future<List<Vendor>> getAllVendors() => select(vendors).get();

  Future<int> insertVendor(VendorsCompanion entry) =>
      into(vendors).insert(entry);

  Future<bool> updateVendor(VendorsCompanion entry) =>
      update(vendors).replace(entry);

  Future<int> deleteVendor(int id) =>
      (delete(vendors)..where((v) => v.id.equals(id))).go();
}
