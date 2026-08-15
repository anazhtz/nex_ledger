import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';
import 'package:nex_ledger/features/reports/data/report_repository.dart';

void main() {
  late AppDatabase db;
  late PurchaseRepository purchaseRepo;
  late ReportRepository reportRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    purchaseRepo = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
    reportRepo = ReportRepository(
      db.transactionDao,
      db.projectDao,
      db.depositDao,
      db.expenseCategoryDao,
    );
  });

  tearDown(() async => db.close());

  test('Advance Stock Purchase & Project Allocation Lifecycle', () async {
    // 1. Setup Projects: Central Overhead (Asset Holder) and Villa Project
    final overheadId = await db.into(db.projects).insert(
          ProjectsCompanion.insert(
            code: 'ADM-001',
            name: 'Central Warehouse / Inventory',
            type: ProjectType.adminOverhead,
            status: ProjectStatus.active,
            startDate: DateTime(2026, 1, 1),
            budget: const Value(0),
          ),
        );

    final villaId = await db.into(db.projects).insert(
          ProjectsCompanion.insert(
            code: 'PRJ-2026-001',
            name: 'Luxury Villa Renovation',
            type: ProjectType.project,
            status: ProjectStatus.active,
            startDate: DateTime(2026, 1, 1),
            budget: const Value(2000000),
          ),
        );

    // Setup Vendor
    final vendorId = await purchaseRepo.addVendor('Apex Steel & Cement Co.');

    // 2. Buy ₹10,00,000 worth of Bulk Material / Advance Stock (Paid)
    await purchaseRepo.addPurchase(
      projectId: overheadId,
      vendorId: vendorId,
      date: DateTime(2026, 1, 1),
      itemDescription: 'Bulk Steel TMT 500D (50 Tons)',
      amount: 1000000,
      paymentStatus: PaymentStatus.paid,
      isAdvanceStock: true,
    );

    // Verify: Transaction has affectsCash = true, affectsPnl = false
    final allTxns = await db.transactionDao.watchAllRawTransactions().first;
    expect(allTxns.length, 1);
    expect(allTxns.first.affectsCash, isTrue);
    expect(allTxns.first.affectsPnl, isFalse);

    // Verify: Villa Project P&L is completely unaffected (₹0 cost)
    final villaPnlBefore = await reportRepo.watchProjectPnl(villaId).first;
    expect(villaPnlBefore.purchases, 0.0);
    expect(villaPnlBefore.netPnl, 0.0);

    // Verify: Overhead Project P&L is also ₹0 (held as Asset, not expense)
    final overheadPnl = await reportRepo.watchProjectPnl(overheadId).first;
    expect(overheadPnl.purchases, 0.0);
    expect(overheadPnl.netPnl, 0.0);

    // 3. One year later: Allocate ₹3,00,000 of stock to Villa Project
    final stockList = await purchaseRepo.watchAdvanceStockPurchases().first;
    expect(stockList.length, 1);
    final stockPurchase = stockList.first;
    expect(stockPurchase.purchase.isAdvanceStock, isTrue);
    expect(stockPurchase.purchase.allocatedAmount, 0.0);

    await purchaseRepo.allocateStockToProject(
      purchaseId: stockPurchase.purchase.id,
      targetProjectId: villaId,
      date: DateTime(2027, 1, 15),
      amountToAllocate: 300000,
      narration: 'Allocated 15 Tons TMT Steel for Villa Foundation',
    );

    // 4. Verify: Allocation transaction created with affectsPnl = true, affectsCash = false
    final txnsAfterAlloc =
        await db.transactionDao.watchAllRawTransactions().first;
    expect(txnsAfterAlloc.length, 2);

    final allocTxn = txnsAfterAlloc.firstWhere(
        (t) => t.type == TransactionType.stockAllocation);
    expect(allocTxn.projectId, villaId);
    expect(allocTxn.amount, 300000);
    expect(allocTxn.affectsPnl, isTrue); // Cost recognized for Villa!
    expect(allocTxn.affectsCash, isFalse); // Zero cash movement!

    // 5. Verify: Villa Project P&L recognizes ₹3,00,000 purchase cost
    final villaPnlAfter = await reportRepo.watchProjectPnl(villaId).first;
    expect(villaPnlAfter.purchases, 300000.0);
    expect(villaPnlAfter.netPnl, -300000.0); // Recognized as project cost

    // 6. Verify: Remaining unallocated stock is ₹7,00,000
    final updatedStock =
        await db.purchaseDao.getPurchaseById(stockPurchase.purchase.id);
    expect(updatedStock!.purchase.allocatedAmount, 300000.0);
    final remaining =
        updatedStock.transaction.amount - updatedStock.purchase.allocatedAmount;
    expect(remaining, 700000.0);

    // 7. Verify: Cannot over-allocate beyond remaining stock
    expect(
      () => purchaseRepo.allocateStockToProject(
        purchaseId: stockPurchase.purchase.id,
        targetProjectId: villaId,
        date: DateTime(2027, 2, 1),
        amountToAllocate: 800000, // exceeds 700,000
      ),
      throwsA(isA<StateError>()),
    );
  });
}
