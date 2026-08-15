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

    projectId = await db.projectDao.insertProject(
      ProjectsCompanion.insert(
        code: 'PRJ-TEST-001',
        name: 'Reactivity Test Project',
        type: ProjectType.project,
        status: ProjectStatus.active,
        startDate: DateTime.now(),
      ),
    );

    vendorId = await db.purchaseDao.insertVendor(
      VendorsCompanion.insert(
        name: 'Test Vendor',
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('watchProjectPnl emits immediately when transactions are added',
      () async {
    final stream = reportRepo.watchProjectPnl(projectId);

    // Listen to emissions continuously as entries are added
    final emissions = <ProjectPnl>[];
    final sub = stream.listen(emissions.add);

    // Initial state: 0 income, 0 expenses, 0 purchases, 0 labour
    await Future.delayed(const Duration(milliseconds: 100));
    expect(emissions.last.income, equals(0.0));
    expect(emissions.last.purchases, equals(0.0));
    expect(emissions.last.netPnl, equals(0.0));

    // Step 1: Add a purchase
    await purchaseRepo.addPurchase(
      projectId: projectId,
      vendorId: vendorId,
      date: DateTime.now(),
      itemDescription: 'Steel and Cement',
      amount: 50000.0,
      paymentStatus: PaymentStatus.paid,
    );

    // Wait a brief pump for stream emission
    await Future.delayed(const Duration(milliseconds: 150));
    expect(emissions.last.purchases, equals(50000.0));
    expect(emissions.last.netPnl, equals(-50000.0));

    // Step 2: Add an income
    await cashBookRepo.addIncome(
      projectId: projectId,
      date: DateTime.now(),
      amount: 150000.0,
      narration: 'Client Stage Payment',
    );

    await Future.delayed(const Duration(milliseconds: 150));
    expect(emissions.last.income, equals(150000.0));
    expect(emissions.last.purchases, equals(50000.0));
    expect(emissions.last.netPnl, equals(100000.0));

    // Step 3: Add Labour payment
    await labourRepo.recordPayment(
      projectId: projectId,
      date: DateTime.now(),
      amount: 20000.0,
      narration: 'Weekly labour payout',
    );

    await Future.delayed(const Duration(milliseconds: 150));
    expect(emissions.last.labourCosts, equals(20000.0));
    expect(emissions.last.netPnl, equals(80000.0));

    // Step 4: Add general Expense
    await cashBookRepo.addExpense(
      projectId: projectId,
      date: DateTime.now(),
      amount: 5000.0,
      narration: 'Site utility bill',
    );

    await Future.delayed(const Duration(milliseconds: 150));
    expect(emissions.last.expenses, equals(5000.0));
    expect(emissions.last.netPnl, equals(75000.0));

    // Step 5: Receive a deposit (liability, does NOT affect income/expenses/netPnl)
    await depositRepo.receiveDeposit(
      projectId: projectId,
      date: DateTime.now(),
      amount: 100000.0,
      narration: 'Security deposit',
    );

    await Future.delayed(const Duration(milliseconds: 150));
    expect(emissions.last.depositsHeld, equals(100000.0));
    expect(emissions.last.income, equals(150000.0));
    expect(emissions.last.netPnl, equals(75000.0));

    await sub.cancel();
  });

  test('watchConsolidatedPnl emits immediately across all projects', () async {
    final stream = reportRepo.watchConsolidatedPnl();

    final emissions = <List<ProjectPnl>>[];
    final sub = stream.listen(emissions.add);

    await Future.delayed(const Duration(milliseconds: 150));
    expect(emissions.last.length, equals(2)); // ADMIN-OVH + PRJ-TEST-001

    // Add another project
    final project2Id = await db.projectDao.insertProject(
      ProjectsCompanion.insert(
        code: 'PRJ-TEST-002',
        name: 'Second Project',
        type: ProjectType.project,
        status: ProjectStatus.active,
        startDate: DateTime.now(),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 150));
    expect(emissions.last.length, equals(3));

    // Add income to second project
    await cashBookRepo.addIncome(
      projectId: project2Id,
      date: DateTime.now(),
      amount: 80000.0,
      narration: 'Project 2 income',
    );

    await Future.delayed(const Duration(milliseconds: 150));
    final p2Pnl = emissions.last.firstWhere((p) => p.project.id == project2Id);
    expect(p2Pnl.income, equals(80000.0));
    expect(p2Pnl.netPnl, equals(80000.0));

    await sub.cancel();
  });
}
