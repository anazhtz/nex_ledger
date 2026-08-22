import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/cash_book/data/cash_book_repository.dart';
import 'package:nex_ledger/features/deposits/data/deposit_repository.dart';
import 'package:nex_ledger/features/projects/data/project_repository.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';
import 'package:nex_ledger/features/reports/data/report_repository.dart';

void main() {
  late AppDatabase db;
  late ProjectRepository projectRepo;
  late CashBookRepository cashBookRepo;
  late PurchaseRepository purchaseRepo;
  late DepositRepository depositRepo;
  late ReportRepository reportRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    projectRepo = ProjectRepository(db.projectDao);
    cashBookRepo = CashBookRepository(db.transactionDao);
    purchaseRepo = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
    depositRepo = DepositRepository(db.depositDao, db.transactionDao, db);
    reportRepo = ReportRepository(
      db.transactionDao,
      db.projectDao,
      db.depositDao,
      db.expenseCategoryDao,
    );
  });

  tearDown(() async => db.close());

  test('Daily Transaction Day-Book Sheet — Day-by-Day Flow & Balances', () async {
    // 1. Setup Project
    final pId = await projectRepo.createProject(
      code: 'PRJ-DAY-001',
      name: 'Day-Book Validation Project',
      type: ProjectType.project,
      status: ProjectStatus.active,
      startDate: DateTime(2026, 1, 1),
    );

    final vId = await purchaseRepo.addVendor('Apex Hardware');

    final day1 = DateTime(2026, 5, 10, 10, 0);
    final day2 = DateTime(2026, 5, 11, 14, 0);
    final day3 = DateTime(2026, 5, 12, 9, 0);

    // ─── DAY 1 TRANSACTIONS ───
    // Receive Deposit ₹1,00,000 (Cash flow in, P&L unaffected)
    await depositRepo.receiveDeposit(
      projectId: pId,
      date: day1,
      amount: 100000.0,
      paymentMode: PaymentMode.bank,
      referenceNo: 'DEP-001',
      narration: 'Client Advance Deposit',
    );

    // Record Expense ₹5,000 (Cash flow out, P&L expense)
    await cashBookRepo.addExpense(
      projectId: pId,
      date: day1,
      amount: 5000.0,
      paymentMode: PaymentMode.cash,
      referenceNo: 'EXP-001',
      narration: 'Site Stationery & Prints',
    );

    // ─── VERIFY DAY 1 SHEET ───
    final reportDay1 = await reportRepo.watchDayBook(day1).first;
    expect(reportDay1.openingBalance, 0.0, reason: 'No transactions prior to Day 1');
    expect(reportDay1.totalInflow, 100000.0, reason: 'Deposit of ₹1,00,000 received');
    expect(reportDay1.totalOutflow, 5000.0, reason: 'Expense of ₹5,000 paid');
    expect(reportDay1.netMovement, 95000.0, reason: '₹1,00,000 - ₹5,000 = ₹95,000');
    expect(reportDay1.closingBalance, 95000.0, reason: 'Closing balance at end of Day 1');
    expect(reportDay1.pnlIncome, 0.0, reason: 'Deposit is liability, not P&L income');
    expect(reportDay1.pnlExpense, 5000.0, reason: 'Expense hits P&L');
    expect(reportDay1.netPnl, -5000.0);
    expect(reportDay1.entries.length, 2);

    // ─── DAY 2 TRANSACTIONS ───
    // Purchase bill ₹20,000 paid in full (Cash out ₹20,000, P&L expense)
    await purchaseRepo.addPurchase(
      projectId: pId,
      vendorId: vId,
      date: day2,
      itemDescription: 'Steel Rods',
      amount: 20000.0,
      paymentStatus: PaymentStatus.paid,
      paymentMode: PaymentMode.bank,
      referenceNo: 'PUR-001',
    );

    // Adjust deposit to income ₹40,000 (Cash flow ₹0, P&L income ₹40,000)
    final deposits = await db.depositDao.watchAllDeposits().first;
    await depositRepo.adjustDepositToIncome(
      depositId: deposits.first.deposit.id,
      projectId: pId,
      adjustedAmount: 40000.0,
      date: day2,
      isFullyAdjusted: false,
      adjustmentReference: 'ADJ-001',
    );

    // ─── VERIFY DAY 2 SHEET ───
    final reportDay2 = await reportRepo.watchDayBook(day2).first;
    expect(reportDay2.openingBalance, 95000.0, reason: 'Opening balance carried forward from Day 1');
    expect(reportDay2.totalInflow, 0.0, reason: 'Adjusting deposit does NOT move physical cash');
    expect(reportDay2.totalOutflow, 20000.0, reason: 'Purchase cash outflow');
    expect(reportDay2.netMovement, -20000.0);
    expect(reportDay2.closingBalance, 75000.0, reason: '₹95,000 - ₹20,000 = ₹75,000');
    expect(reportDay2.pnlIncome, 40000.0, reason: 'Adjusted deposit is now recognized income');
    expect(reportDay2.pnlExpense, 20000.0, reason: 'Steel Rods purchase recognized');
    expect(reportDay2.netPnl, 20000.0, reason: '₹40,000 - ₹20,000 = +₹20,000 Day Profit');
    expect(reportDay2.entries.length, 2);

    // ─── VERIFY DAY 3 (IDLE DAY) ───
    final reportDay3 = await reportRepo.watchDayBook(day3).first;
    expect(reportDay3.openingBalance, 75000.0, reason: 'Closing balance of Day 2 is opening of Day 3');
    expect(reportDay3.totalInflow, 0.0);
    expect(reportDay3.totalOutflow, 0.0);
    expect(reportDay3.netMovement, 0.0);
    expect(reportDay3.closingBalance, 75000.0);
    expect(reportDay3.entries, isEmpty);
  });
}
