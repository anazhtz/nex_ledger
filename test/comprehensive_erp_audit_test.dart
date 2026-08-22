import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/bank_accounts/data/bank_account_repository.dart';
import 'package:nex_ledger/features/cash_book/data/cash_book_repository.dart';
import 'package:nex_ledger/features/deposits/data/deposit_repository.dart';
import 'package:nex_ledger/features/labour/data/labour_repository.dart';
import 'package:nex_ledger/features/projects/data/project_repository.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';
import 'package:nex_ledger/features/reports/data/report_repository.dart';

void main() {
  late AppDatabase db;
  late ProjectRepository projectRepo;
  late BankAccountRepository bankRepo;
  late CashBookRepository cashBookRepo;
  late PurchaseRepository purchaseRepo;
  late LabourRepository labourRepo;
  late DepositRepository depositRepo;
  late ReportRepository reportRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    projectRepo = ProjectRepository(db.projectDao);
    bankRepo = BankAccountRepository(db.bankAccountDao, db.transactionDao, db);
    cashBookRepo = CashBookRepository(db.transactionDao);
    purchaseRepo = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
    labourRepo = LabourRepository(db.labourDao, db.transactionDao);
    depositRepo = DepositRepository(db.depositDao, db.transactionDao, db);
    reportRepo = ReportRepository(
      db.transactionDao,
      db.projectDao,
      db.depositDao,
      db.expenseCategoryDao,
    );
  });

  tearDown(() async => db.close());

  test('Comprehensive ERP Audit Test — All 9 Feature Items & Financial Lifecycle', () async {
    // ═══════════════════════════════════════════════════════════════════════════
    // STEP 1: Bank Accounts Master & Opening Balances (Item 2)
    // ═══════════════════════════════════════════════════════════════════════════
    final cashAccId = await bankRepo.addAccount(
      accountName: 'Office Petty Cash Drawer',
      isCashAccount: true,
      isDefault: true,
      openingBalance: 15000.0,
    );

    final bankAccId = await bankRepo.addAccount(
      accountName: 'ICICI Bank Current Account',
      bankName: 'ICICI Bank',
      accountNumber: '001105001234',
      isCashAccount: false,
      isDefault: true,
      openingBalance: 500000.0,
    );

    var liq = await bankRepo.watchLiquiditySummary().first;
    expect(liq.cashInHand, 15000.0);
    expect(liq.inBanks, 500000.0);
    expect(liq.totalLiquidity, 515000.0);

    // ═══════════════════════════════════════════════════════════════════════════
    // STEP 2: Project Creation (Item 6)
    // ═══════════════════════════════════════════════════════════════════════════
    final pId = await projectRepo.createProject(
      code: 'PRJ-AUDIT-2026',
      name: 'Skyline Commercial Towers',
      type: ProjectType.project,
      status: ProjectStatus.active,
      startDate: DateTime(2026, 1, 1),
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // STEP 3: Purchase with Qty/Rate & Credit Terms (Items 1 & 3)
    // ═══════════════════════════════════════════════════════════════════════════
    final vId = await purchaseRepo.addVendor('UltraTech Cement Supply');
    await purchaseRepo.addPurchase(
      projectId: pId,
      vendorId: vId,
      date: DateTime(2026, 1, 5),
      itemDescription: 'OPC 53 Grade Cement',
      quantity: 100.0,
      unitRate: 450.0,
      unit: 'Bags',
      amount: 45000.0,
      paymentStatus: PaymentStatus.pending, // Vendor Credit!
      paymentMode: PaymentMode.bank,
      referenceNo: 'INV-UT-101',
    );

    // Verify P&L and Accounts Payable
    var pnl = await reportRepo.watchProjectPnl(pId).first;
    expect(pnl.purchases, 45000.0, reason: 'Expense recognized on accrual basis');
    expect(pnl.accountsPayable, 45000.0, reason: 'Bill is unpaid -> Accounts Payable liability');

    // Physical cash remains untouched
    var cashBal = await db.transactionDao.watchCashBalance().first;
    expect(cashBal, 0.0, reason: 'Zero physical cash moved so far from transactions');

    // Settle partial payment of ₹20,000 to vendor from Bank
    final purchases = await db.purchaseDao.watchPurchasesByProject(pId).first;
    await purchaseRepo.markPurchasePaid(
      purchaseId: purchases.first.purchase.id,
      paymentDate: DateTime(2026, 1, 10),
      amountPaid: 20000.0,
      paymentMode: PaymentMode.bank,
      bankAccountId: bankAccId,
      referenceNo: 'NEFT-ICICI-001',
    );

    pnl = await reportRepo.watchProjectPnl(pId).first;
    expect(pnl.purchases, 45000.0, reason: 'Purchases cost unchanged (no double count)');
    expect(pnl.accountsPayable, 25000.0, reason: '₹45,000 - ₹20,000 = ₹25,000 remaining due');

    // ═══════════════════════════════════════════════════════════════════════════
    // STEP 4: Labour Attendance & Wage Payout (Items 4 & 12c)
    // ═══════════════════════════════════════════════════════════════════════════
    final w1 = await db.labourDao.insertWorker(
      const WorkersCompanion(
        name: Value('Ramesh Kumar'),
        workerCode: Value('W-001'),
        trade: Value('Mason'),
        dailyRate: Value(1000.0),
      ),
    );

    // Save attendance for 2 days
    await labourRepo.saveBatchAttendance(
      projectId: pId,
      date: DateTime(2026, 1, 11),
      workerStatuses: {w1: AttendanceStatus.present},
    );
    await labourRepo.saveBatchAttendance(
      projectId: pId,
      date: DateTime(2026, 1, 12),
      workerStatuses: {w1: AttendanceStatus.present},
    );

    // Check All-Time Running Balance Summary
    final workerSummary = await labourRepo.getPaymentSummary(
      w1,
      pId,
      DateTime(2026, 1, 1),
      DateTime(2026, 1, 31),
    );
    expect(workerSummary.totalDaysWorked, 2.0);
    expect(workerSummary.totalEarnedWages, 2000.0);
    expect(workerSummary.amountDue, 2000.0);

    // Disburse labour wages from Petty Cash
    await labourRepo.recordPayment(
      projectId: pId,
      workerId: w1,
      date: DateTime(2026, 1, 12),
      amount: 2000.0,
      paymentMode: PaymentMode.cash,
      bankAccountId: cashAccId,
      narration: 'Wages for 2 days',
    );

    pnl = await reportRepo.watchProjectPnl(pId).first;
    expect(pnl.labourCosts, 2000.0);

    // ═══════════════════════════════════════════════════════════════════════════
    // STEP 5: Deposit & P&L Recognition (Section 6 & Item 9 Day-Book)
    // ═══════════════════════════════════════════════════════════════════════════
    final today = DateTime(2026, 1, 15);

    // Receive Deposit ₹3,00,000 in ICICI Bank
    await depositRepo.receiveDeposit(
      projectId: pId,
      date: today,
      amount: 300000.0,
      paymentMode: PaymentMode.bank,
      bankAccountId: bankAccId,
      referenceNo: 'DEP-ADV-001',
      narration: 'Client Project Advance',
    );

    // Record Site General Expense ₹3,000 from Cash (Item 8: Expense default)
    await cashBookRepo.addExpense(
      projectId: pId,
      date: today,
      amount: 3000.0,
      paymentMode: PaymentMode.cash,
      bankAccountId: cashAccId,
      referenceNo: 'EXP-101',
      narration: 'Site Municipal Permits',
    );

    // Adjust ₹1,00,000 of deposit to income
    final allDeposits = await db.depositDao.watchAllDeposits().first;
    await depositRepo.adjustDepositToIncome(
      depositId: allDeposits.first.deposit.id,
      projectId: pId,
      adjustedAmount: 100000.0,
      date: today,
      isFullyAdjusted: false,
      adjustmentReference: 'RA-BILL-01',
    );

    // ─── VERIFY DAY-BOOK REPORT FOR TODAY (Item 9) ───
    final dayReport = await reportRepo.watchDayBook(today).first;
    expect(dayReport.totalInflow, 300000.0, reason: 'Physical deposit received today');
    expect(dayReport.totalOutflow, 3000.0, reason: 'Expense paid today');
    expect(dayReport.netMovement, 297000.0, reason: '₹300,000 - ₹3,000 = ₹297,000');
    expect(dayReport.pnlIncome, 100000.0, reason: 'Recognized income hits day P&L');
    expect(dayReport.pnlExpense, 3000.0, reason: 'Expense hits day P&L');
    expect(dayReport.netPnl, 97000.0, reason: '₹100,000 - ₹3,000 = +₹97,000 day profit');

    // ─── FINAL AUDIT OF PROJECT P&L & LIQUIDITY ───
    pnl = await reportRepo.watchProjectPnl(pId).first;
    expect(pnl.income, 100000.0);
    expect(pnl.purchases, 45000.0);
    expect(pnl.labourCosts, 2000.0);
    expect(pnl.expenses, 3000.0);
    expect(pnl.netPnl, 50000.0, reason: '₹100,000 - (₹45,000 + ₹2,000 + ₹3,000) = ₹50,000 Net Profit');
    expect(pnl.depositsHeld, 200000.0, reason: '₹300,000 - ₹100,000 adjusted = ₹200,000 held liability');
    expect(pnl.accountsPayable, 25000.0, reason: '₹25,000 unpaid to cement vendor');

    // Liquidity verification
    liq = await bankRepo.watchLiquiditySummary().first;
    // Petty cash: ₹15,000 - ₹2,000 (labour) - ₹3,000 (expense) = ₹10,000
    expect(liq.cashInHand, 10000.0);
    // Bank: ₹500,000 - ₹20,000 (vendor partial) + ₹300,000 (deposit in) = ₹780,000
    expect(liq.inBanks, 780000.0);
    expect(liq.totalLiquidity, 790000.0);
  });
}
