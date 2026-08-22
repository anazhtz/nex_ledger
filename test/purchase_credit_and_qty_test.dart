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

  test('Purchase Qty, Unit Rate, and Full Vendor Credit lifecycle', () async {
    // 1. Setup Project & Vendor
    final projectId = await db.into(db.projects).insert(
          ProjectsCompanion.insert(
            code: 'PRJ-VILLA-101',
            name: 'Villa Coastal Project',
            type: ProjectType.project,
            status: ProjectStatus.active,
            startDate: DateTime(2026, 1, 1),
          ),
        );

    final vendorId = await purchaseRepo.addVendor('ABC Cement Suppliers');

    // 2. Add a 100% Credit Purchase: 50 Bags @ ₹380.00 = ₹19,000.00
    await purchaseRepo.addPurchase(
      projectId: projectId,
      vendorId: vendorId,
      date: DateTime(2026, 2, 1),
      itemDescription: 'UltraTech Cement 53 Grade',
      amount: 19000.0,
      quantity: 50.0,
      unitRate: 380.0,
      unit: 'Bags',
      paymentStatus: PaymentStatus.pending,
    );

    // Verify Purchase detail
    final purchases = await db.purchaseDao.watchPurchasesByProject(projectId).first;
    expect(purchases.length, 1);
    final p = purchases.first;
    expect(p.purchase.quantity, 50.0);
    expect(p.purchase.unitRate, 380.0);
    expect(p.purchase.unit, 'Bags');
    expect(p.purchase.paidAmount, 0.0);
    expect(p.purchase.paymentStatus, PaymentStatus.pending);
    expect(purchaseRepo.outstandingAmount(p), 19000.0);

    // Verify P&L and Accounts Payable
    final pnl1 = await reportRepo.watchProjectPnl(projectId).first;
    expect(pnl1.purchases, 19000.0, reason: 'P&L recognizes purchase cost immediately');
    expect(pnl1.accountsPayable, 19000.0, reason: 'Unpaid bill recorded as accounts payable');

    // Verify Cash Balance (should be 0 because credit purchase has affectsCash = false)
    final cashRows1 = await db.transactionDao.watchTransactionsByProject(projectId).first;
    final cashImpact1 = cashRows1.where((t) => t.affectsCash).fold<double>(0.0, (s, t) => s + t.amount);
    expect(cashImpact1, 0.0, reason: 'Credit purchase does not move cash');

    // 3. Make Partial Payment of ₹10,000
    await purchaseRepo.markPurchasePaid(
      purchaseId: p.purchase.id,
      paymentDate: DateTime(2026, 2, 5),
      amountPaid: 10000.0,
      paymentMode: PaymentMode.bank,
      referenceNo: 'NEFT-8899',
    );

    final purchasesAfterPart1 = await db.purchaseDao.watchPurchasesByProject(projectId).first;
    final pAfterPart1 = purchasesAfterPart1.first;
    expect(pAfterPart1.purchase.paidAmount, 10000.0);
    expect(pAfterPart1.purchase.paymentStatus, PaymentStatus.partial);
    expect(purchaseRepo.outstandingAmount(pAfterPart1), 9000.0);

    final pnl2 = await reportRepo.watchProjectPnl(projectId).first;
    expect(pnl2.purchases, 19000.0, reason: 'P&L still exactly ₹19,000 (no double counting)');
    expect(pnl2.accountsPayable, 9000.0, reason: 'Accounts payable reduced to ₹9,000');

    // Verify cash moved by exactly ₹10,000
    final cashRows2 = await db.transactionDao.watchTransactionsByProject(projectId).first;
    final cashOut2 = cashRows2.where((t) => t.affectsCash).fold<double>(0.0, (s, t) => s + t.amount);
    expect(cashOut2, 10000.0);

    // 4. Settle remaining ₹9,000
    await purchaseRepo.markPurchasePaid(
      purchaseId: p.purchase.id,
      paymentDate: DateTime(2026, 2, 10),
      amountPaid: 9000.0,
      paymentMode: PaymentMode.cash,
    );

    final purchasesFinal = await db.purchaseDao.watchPurchasesByProject(projectId).first;
    final pFinal = purchasesFinal.first;
    expect(pFinal.purchase.paidAmount, 19000.0);
    expect(pFinal.purchase.paymentStatus, PaymentStatus.paid);
    expect(purchaseRepo.outstandingAmount(pFinal), 0.0);

    final pnlFinal = await reportRepo.watchProjectPnl(projectId).first;
    expect(pnlFinal.purchases, 19000.0);
    expect(pnlFinal.accountsPayable, 0.0);
  });

  test('Partial Advance Purchase flow', () async {
    final projectId = await db.into(db.projects).insert(
          ProjectsCompanion.insert(
            code: 'PRJ-BLD-202',
            name: 'Commercial Complex',
            type: ProjectType.project,
            status: ProjectStatus.active,
            startDate: DateTime(2026, 1, 1),
          ),
        );

    final vendorId = await purchaseRepo.addVendor('Shree Electricals');

    // Total Bill ₹50,000, Advance Paid Today ₹15,000, Remaining ₹35,000 on credit
    await purchaseRepo.addPurchase(
      projectId: projectId,
      vendorId: vendorId,
      date: DateTime(2026, 2, 1),
      itemDescription: 'Copper Wiring & Switches',
      amount: 50000.0,
      quantity: 100.0,
      unitRate: 500.0,
      unit: 'Nos',
      paidAmount: 15000.0,
      paymentStatus: PaymentStatus.partial,
      paymentMode: PaymentMode.online,
    );

    final purchases = await db.purchaseDao.watchPurchasesByProject(projectId).first;
    expect(purchases.length, 1);
    final p = purchases.first;
    expect(p.purchase.paidAmount, 15000.0);
    expect(p.purchase.paymentStatus, PaymentStatus.partial);
    expect(purchaseRepo.outstandingAmount(p), 35000.0);

    // Verify cash moved by ₹15,000
    final txns = await db.transactionDao.watchTransactionsByProject(projectId).first;
    final cashOut = txns.where((t) => t.affectsCash).fold<double>(0.0, (s, t) => s + t.amount);
    expect(cashOut, 15000.0);

    // Verify P&L is ₹50,000 (total recognized cost) and Accounts Payable is ₹35,000
    final pnl = await reportRepo.watchProjectPnl(projectId).first;
    expect(pnl.purchases, 50000.0);
    expect(pnl.accountsPayable, 35000.0);
  });
}
