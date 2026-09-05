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

  test('Purchase creation with HSN, GST tax calculation, invoice override and edit lifecycle', () async {
    // 1. Setup Project & Vendor
    final projectId = await db.into(db.projects).insert(
          ProjectsCompanion.insert(
            code: 'PRJ-VILLA-2026',
            name: 'Luxury Villa Marble & Granite',
            type: ProjectType.project,
            status: ProjectStatus.active,
            startDate: DateTime(2026, 1, 1),
          ),
        );

    final vendorId = await purchaseRepo.addVendor('Rajasthan Natural Stones Pvt Ltd');

    // 2. Add Purchase with HSN 6802, 200 Sq.ft @ ₹150 = ₹30,000 Base + 18% GST (₹5,400) = ₹35,400 Total
    await purchaseRepo.addPurchase(
      projectId: projectId,
      vendorId: vendorId,
      date: DateTime(2026, 3, 10),
      itemDescription: 'Black Galaxy Granite 18mm',
      referenceNo: 'INV-2026-9901',
      quantity: 200.0,
      unit: 'Sq.ft',
      unitRate: 150.0,
      hsnCode: '6802',
      taxApplicable: true,
      gstRate: 18.0,
      gstAmount: 5400.0,
      amount: 35400.0,
      paymentStatus: PaymentStatus.paid,
      paymentMode: PaymentMode.bank,
      narration: 'Delivered at site ground floor',
    );

    // 3. Verify created purchase in DB
    final list1 = await db.purchaseDao.watchPurchasesByProject(projectId).first;
    expect(list1.length, 1);
    final p1 = list1.first;
    expect(p1.purchase.itemDescription, 'Black Galaxy Granite 18mm');
    expect(p1.purchase.hsnCode, '6802');
    expect(p1.purchase.quantity, 200.0);
    expect(p1.purchase.unit, 'Sq.ft');
    expect(p1.purchase.unitRate, 150.0);
    expect(p1.purchase.taxApplicable, isTrue);
    expect(p1.purchase.gstRate, 18.0);
    expect(p1.purchase.gstAmount, 5400.0);
    expect(p1.transaction.amount, 35400.0);
    expect(p1.transaction.referenceNo, 'INV-2026-9901');

    // 4. Verify P&L cost recognizes the full purchase
    final pnl1 = await reportRepo.getProjectPnl(projectId);
    expect(pnl1.purchases, 35400.0);

    // 5. Edit the Purchase:
    // Update quantity to 250 Sq.ft @ ₹160 = ₹40,000 Base
    // Custom invoice GST amount typed as ₹7,210 (with invoice rounding) -> Total ₹47,210
    // HSN updated to 6802.21
    await purchaseRepo.updatePurchase(
      purchaseId: p1.purchase.id,
      projectId: projectId,
      vendorId: vendorId,
      date: DateTime(2026, 3, 12),
      itemDescription: 'Black Galaxy Granite 18mm (Revised Qty)',
      referenceNo: 'INV-2026-9901-REV',
      quantity: 250.0,
      unit: 'Sq.ft',
      unitRate: 160.0,
      hsnCode: '6802.21',
      taxApplicable: true,
      gstRate: 18.0,
      gstAmount: 7210.0,
      amount: 47210.0,
      paymentStatus: PaymentStatus.paid,
      paymentMode: PaymentMode.bank,
      narration: 'Revised bill with additional 50 sq.ft',
    );

    // 6. Verify updated purchase details in DB
    final list2 = await db.purchaseDao.watchPurchasesByProject(projectId).first;
    expect(list2.length, 1);
    final p2 = list2.first;
    expect(p2.purchase.itemDescription, 'Black Galaxy Granite 18mm (Revised Qty)');
    expect(p2.purchase.hsnCode, '6802.21');
    expect(p2.purchase.quantity, 250.0);
    expect(p2.purchase.unitRate, 160.0);
    expect(p2.purchase.gstRate, 18.0);
    expect(p2.purchase.gstAmount, 7210.0);
    expect(p2.transaction.amount, 47210.0);
    expect(p2.transaction.referenceNo, 'INV-2026-9901-REV');

    // 7. Verify P&L report immediately reflects the updated cost
    final pnl2 = await reportRepo.getProjectPnl(projectId);
    expect(pnl2.purchases, 47210.0);
  });
}
