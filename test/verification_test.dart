import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/cash_book/data/cash_book_repository.dart';
import 'package:nex_ledger/features/deposits/data/deposit_repository.dart';
import 'package:nex_ledger/features/labour/data/labour_repository.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';
import 'package:nex_ledger/features/reports/data/report_repository.dart';

void main() {
  late AppDatabase db;
  late DepositRepository depositRepo;
  late PurchaseRepository purchaseRepo;
  late LabourRepository labourRepo;
  late CashBookRepository cashBookRepo;
  late ReportRepository reportRepo;
  late int projectId;
  late int vendorId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    depositRepo = DepositRepository(db.depositDao, db.transactionDao, db);
    purchaseRepo = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
    labourRepo = LabourRepository(db.labourDao, db.transactionDao);
    cashBookRepo = CashBookRepository(db.transactionDao);
    reportRepo = ReportRepository(
        db.transactionDao, db.projectDao, db.depositDao, db.expenseCategoryDao);

    // Create Project PRJ-2026-001 ("Luxury Villa Renovation")
    projectId = await db.projectDao.insertProject(
      ProjectsCompanion.insert(
        code: 'PRJ-2026-001',
        name: 'Luxury Villa Renovation',
        type: ProjectType.project,
        status: ProjectStatus.active,
        startDate: DateTime.now(),
      ),
    );

    // Create Vendor ABC Hardware
    vendorId = await db.purchaseDao.insertVendor(
      VendorsCompanion.insert(
        name: 'ABC Hardware',
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('Section 11 Verification Test Case — Section 6 Deposit vs P&L Rule',
      () async {
    // Initial state check
    double cash = await db.transactionDao.watchCashBalance().first;
    expect(cash, equals(0.0));

    // STEP 1: Deposit received: ₹5,00,000
    await depositRepo.receiveDeposit(
      projectId: projectId,
      date: DateTime.now(),
      amount: 500000.0,
      narration: 'Initial Client Deposit',
    );

    cash = await db.transactionDao.watchCashBalance().first;
    double depositHeld = await db.depositDao.watchTotalDepositsHeld().first;
    ProjectPnl pnl1 = await reportRepo.getProjectPnl(projectId);

    expect(cash, equals(500000.0),
        reason: 'Step 1: Cash Balance must be ₹5,00,000');
    expect(depositHeld, equals(500000.0),
        reason: 'Step 1: Deposit Liability Held must be ₹5,00,000');
    expect(pnl1.income, equals(0.0),
        reason: 'Step 1: P&L Recognized Income must be ₹0');
    expect(pnl1.netPnl, equals(0.0), reason: 'Step 1: Net P&L must be ₹0');

    // STEP 2: Purchase: materials, ₹1,20,000
    await purchaseRepo.addPurchase(
      projectId: projectId,
      vendorId: vendorId,
      date: DateTime.now(),
      itemDescription: 'Construction materials',
      amount: 120000.0,
      paymentStatus: PaymentStatus.paid,
    );

    cash = await db.transactionDao.watchCashBalance().first;
    pnl1 = await reportRepo.getProjectPnl(projectId);

    expect(cash, equals(380000.0),
        reason: 'Step 2: Cash Balance must be ₹3,80,000');
    expect(pnl1.purchases, equals(120000.0),
        reason: 'Step 2: Project Purchases must be ₹1,20,000');

    // STEP 3: Labour Payment: 10 days @ ₹1,000/day = ₹10,000
    await labourRepo.recordPayment(
      projectId: projectId,
      date: DateTime.now(),
      amount: 10000.0,
      narration: '10 days site worker payment',
    );

    cash = await db.transactionDao.watchCashBalance().first;
    pnl1 = await reportRepo.getProjectPnl(projectId);

    expect(cash, equals(370000.0),
        reason: 'Step 3: Cash Balance must be ₹3,70,000');
    expect(pnl1.labourCosts, equals(10000.0),
        reason: 'Step 3: Project Labour Cost must be ₹10,000');

    // STEP 4: Expense: fuel/transport, ₹5,000
    await cashBookRepo.addExpense(
      projectId: projectId,
      date: DateTime.now(),
      amount: 5000.0,
      narration: 'Fuel and transport',
    );

    cash = await db.transactionDao.watchCashBalance().first;
    pnl1 = await reportRepo.getProjectPnl(projectId);

    expect(cash, equals(365000.0),
        reason: 'Step 4: Cash Balance must be ₹3,65,000');
    expect(pnl1.expenses, equals(5000.0),
        reason: 'Step 4: Project Expenses must be ₹5,000');

    // STEP 5: Adjust Deposit to Income: ₹3,00,000
    final deposits =
        await db.depositDao.watchDepositsByProject(projectId).first;
    expect(deposits.length, equals(1));
    final depositId = deposits.first.deposit.id;

    await depositRepo.adjustDepositToIncome(
      depositId: depositId,
      projectId: projectId,
      adjustedAmount: 300000.0,
      date: DateTime.now(),
      isFullyAdjusted: false,
    );

    // VERIFY FINAL 5 NUMBERS
    cash = await db.transactionDao.watchCashBalance().first;
    depositHeld = await db.depositDao.watchTotalDepositsHeld().first;
    final finalPnl = await reportRepo.getProjectPnl(projectId);
    final totalCosts =
        finalPnl.purchases + finalPnl.labourCosts + finalPnl.expenses;

    expect(finalPnl.income, equals(300000.0),
        reason: 'Final: Total Recognized Income must be ₹3,00,000');
    expect(totalCosts, equals(135000.0),
        reason: 'Final: Total Costs must be ₹1,35,000');
    expect(finalPnl.netPnl, equals(165000.0),
        reason: 'Final: Net Project P&L must be ₹1,65,000 profit');
    expect(depositHeld, equals(200000.0),
        reason: 'Final: Deposit Balance Held must be ₹2,00,000');
    expect(cash, equals(365000.0),
        reason: 'Final: Physical Cash in Bank/Hand must be ₹3,65,000');
  });
}
