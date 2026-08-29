import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/tables/purchases_table.dart';
import 'package:nex_ledger/core/database/tables/transactions_table.dart';
import 'package:nex_ledger/core/database/tables/vendors_table.dart';
import 'package:nex_ledger/core/database/tables/projects_table.dart';

import 'package:nex_ledger/features/purchase/models/material_consumption.dart';

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

  /// Watch only pending/partial purchases (Accounts Payable view).
  /// Optional [projectId] filter; if null, returns across all projects.
  Stream<List<PurchaseDetail>> watchPendingPurchases({int? projectId}) {
    final pendingStatuses = [
      PaymentStatus.pending.name,
      PaymentStatus.partial.name,
    ];
    final query = select(purchases).join([
      innerJoin(
          transactions, transactions.id.equalsExp(purchases.transactionId)),
      innerJoin(vendors, vendors.id.equalsExp(purchases.vendorId)),
      innerJoin(projects, projects.id.equalsExp(transactions.projectId)),
    ])
      ..where(purchases.paymentStatus.isIn(pendingStatuses));
    if (projectId != null) {
      query.where(transactions.projectId.equals(projectId));
    }
    query.orderBy([OrderingTerm.desc(transactions.date)]);
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

  /// Get a single purchase by its [purchaseId].
  Future<PurchaseDetail?> getPurchaseById(int purchaseId) {
    final query = select(purchases).join([
      innerJoin(
          transactions, transactions.id.equalsExp(purchases.transactionId)),
      innerJoin(vendors, vendors.id.equalsExp(purchases.vendorId)),
      innerJoin(projects, projects.id.equalsExp(transactions.projectId)),
    ])
      ..where(purchases.id.equals(purchaseId));
    return query.getSingleOrNull().then((row) => row == null
        ? null
        : PurchaseDetail(
            row.readTable(purchases),
            row.readTable(transactions),
            row.readTable(vendors),
            row.readTable(projects),
          ));
  }

  /// Update payment status of a purchase.
  Future<int> updatePaymentStatus(
          int purchaseId, PaymentStatus status) =>
      (update(purchases)..where((p) => p.id.equals(purchaseId)))
          .write(PurchasesCompanion(paymentStatus: Value(status)));

  /// Update paid amount and payment status of a purchase.
  Future<int> updatePaymentDetails(
          int purchaseId, double newPaidAmount, PaymentStatus status) =>
      (update(purchases)..where((p) => p.id.equals(purchaseId)))
          .write(PurchasesCompanion(
            paidAmount: Value(newPaidAmount),
            paymentStatus: Value(status),
          ));

  /// Update allocated amount of an advance stock purchase.
  Future<int> updateAllocatedAmount(
          int purchaseId, double newAllocatedAmount) =>
      (update(purchases)..where((p) => p.id.equals(purchaseId)))
          .write(PurchasesCompanion(allocatedAmount: Value(newAllocatedAmount)));

  /// Watch only advance stock purchases.
  Stream<List<PurchaseDetail>> watchAdvanceStockPurchases() {
    final query = select(purchases).join([
      innerJoin(
          transactions, transactions.id.equalsExp(purchases.transactionId)),
      innerJoin(vendors, vendors.id.equalsExp(purchases.vendorId)),
      innerJoin(projects, projects.id.equalsExp(transactions.projectId)),
    ])
      ..where(purchases.isAdvanceStock.equals(true))
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

  // --- Vendor helpers ---

  Stream<List<Vendor>> watchAllVendors() =>
      (select(vendors)..orderBy([(v) => OrderingTerm.asc(v.name)])).watch();

  Future<List<Vendor>> getAllVendors() => select(vendors).get();

  /// Get a single vendor by id.
  Future<Vendor?> getVendorById(int vendorId) =>
      (select(vendors)..where((v) => v.id.equals(vendorId))).getSingleOrNull();

  /// Watch a vendor reactively (for the header card).
  Stream<Vendor?> watchVendorById(int vendorId) =>
      (select(vendors)..where((v) => v.id.equals(vendorId))).watchSingleOrNull();

  Future<int> insertVendor(VendorsCompanion entry) =>
      into(vendors).insert(entry);

  Future<bool> updateVendor(VendorsCompanion entry) =>
      update(vendors).replace(entry);

  Future<int> deleteVendor(int id) =>
      (delete(vendors)..where((v) => v.id.equals(id))).go();

  /// Stream of ALL purchases for a specific vendor across all projects,
  /// newest first — used by the Vendor Ledger detail screen.
  Stream<List<PurchaseDetail>> watchPurchasesByVendor(int vendorId) {
    final query = select(purchases).join([
      innerJoin(
          transactions, transactions.id.equalsExp(purchases.transactionId)),
      innerJoin(vendors, vendors.id.equalsExp(purchases.vendorId)),
      innerJoin(projects, projects.id.equalsExp(transactions.projectId)),
    ])
      ..where(purchases.vendorId.equals(vendorId))
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

  /// Stream of aggregated material consumption for a project grouped by category.
  Stream<List<MaterialConsumptionSummary>> watchMaterialConsumptionByProject(int projectId) {
    return watchPurchasesByProject(projectId).map((purchasesList) {
      final map = <String, List<PurchaseDetail>>{};

      for (final p in purchasesList) {
        final cat = p.purchase.materialCategory?.trim().isNotEmpty == true
            ? p.purchase.materialCategory!.trim()
            : 'General Material';
        map.putIfAbsent(cat, () => []).add(p);
      }

      final results = <MaterialConsumptionSummary>[];

      for (final entry in map.entries) {
        final catName = entry.key;
        final list = entry.value;

        double totalQty = 0.0;
        double totalAmt = 0.0;
        String unit = list.first.purchase.unit ?? 'Units';
        DateTime? latestDate;
        String? latestVendor;

        for (final item in list) {
          totalQty += item.purchase.quantity;
          totalAmt += item.transaction.amount;
          if (item.purchase.unit != null && item.purchase.unit!.isNotEmpty) {
            unit = item.purchase.unit!;
          }
          if (latestDate == null || item.transaction.date.isAfter(latestDate)) {
            latestDate = item.transaction.date;
            latestVendor = item.vendor.name;
          }
        }

        final avgRate = totalQty > 0 ? (totalAmt / totalQty) : 0.0;

        results.add(MaterialConsumptionSummary(
          categoryName: catName,
          totalQuantity: totalQty,
          unit: unit,
          totalAmount: totalAmt,
          avgUnitRate: avgRate,
          billCount: list.length,
          lastPurchaseDate: latestDate,
          lastVendorName: latestVendor,
        ));
      }

      // Sort by highest amount spent first
      results.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      return results;
    });
  }
}
