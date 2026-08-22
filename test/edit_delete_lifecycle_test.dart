import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/cash_book/data/cash_book_repository.dart';
import 'package:nex_ledger/features/deposits/data/deposit_repository.dart';
import 'package:nex_ledger/features/projects/data/project_repository.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';

void main() {
  late AppDatabase db;
  late ProjectRepository projectRepo;
  late CashBookRepository cashBookRepo;
  late PurchaseRepository purchaseRepo;
  late DepositRepository depositRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    projectRepo = ProjectRepository(db.projectDao);
    cashBookRepo = CashBookRepository(db.transactionDao);
    purchaseRepo = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
    depositRepo = DepositRepository(db.depositDao, db.transactionDao, db);
  });

  tearDown(() async => db.close());

  test('Project Edit and Delete Lifecycle', () async {
    // Create project
    final pId = await projectRepo.createProject(
      code: 'PRJ-EDIT-001',
      name: 'Initial Project Name',
      type: ProjectType.project,
      status: ProjectStatus.active,
      startDate: DateTime(2026, 1, 1),
      budget: 100000,
    );

    // Edit project
    await projectRepo.updateProject(
      id: pId,
      code: 'PRJ-EDIT-001-MOD',
      name: 'Updated Project Name',
      clientName: 'Acme Corp',
      type: ProjectType.project,
      status: ProjectStatus.onHold,
      startDate: DateTime(2026, 1, 15),
      budget: 250000,
    );

    final updated = await projectRepo.getProjectById(pId);
    expect(updated, isNotNull);
    expect(updated!.code, 'PRJ-EDIT-001-MOD');
    expect(updated.name, 'Updated Project Name');
    expect(updated.clientName, 'Acme Corp');
    expect(updated.status, ProjectStatus.onHold);
    expect(updated.budget, 250000);

    // Delete project
    await projectRepo.deleteProject(pId);
    final deleted = await projectRepo.getProjectById(pId);
    expect(deleted, isNull);
  });

  test('Cash Book Edit and Delete Lifecycle', () async {
    final pId = await projectRepo.createProject(
      code: 'PRJ-CB-001',
      name: 'Cash Book Test Project',
      type: ProjectType.project,
      status: ProjectStatus.active,
      startDate: DateTime(2026, 1, 1),
    );

    // 1. Add Income ₹50,000
    await cashBookRepo.addIncome(
      projectId: pId,
      date: DateTime(2026, 2, 1),
      amount: 50000,
      narration: 'Client Milestone 1',
    );

    var balance = await cashBookRepo.watchCashBalance().first;
    expect(balance, 50000);

    // 2. Add Expense ₹5,000
    await cashBookRepo.addExpense(
      projectId: pId,
      date: DateTime(2026, 2, 2),
      amount: 5000,
      narration: 'Site Stationery & Supplies',
    );

    balance = await cashBookRepo.watchCashBalance().first;
    expect(balance, 45000);

    final txns = await cashBookRepo.watchAllTransactions().first;
    final expenseTxn = txns.firstWhere((t) => t.transaction.type == TransactionType.expense);

    // 3. Edit Expense from ₹5,000 to ₹8,000
    await cashBookRepo.updateTransaction(
      id: expenseTxn.transaction.id,
      projectId: pId,
      date: DateTime(2026, 2, 2),
      type: TransactionType.expense,
      amount: 8000,
      narration: 'Site Stationery & Printing (Updated)',
    );

    balance = await cashBookRepo.watchCashBalance().first;
    expect(balance, 42000, reason: '₹50,000 - ₹8,000 = ₹42,000');

    // 4. Delete Expense
    await cashBookRepo.deleteTransaction(expenseTxn.transaction.id);
    balance = await cashBookRepo.watchCashBalance().first;
    expect(balance, 50000, reason: 'Expense deleted, cash restored to ₹50,000');
  });

  test('Purchase Edit and Delete Lifecycle', () async {
    final pId = await projectRepo.createProject(
      code: 'PRJ-PURCH-001',
      name: 'Purchase Test Project',
      type: ProjectType.project,
      status: ProjectStatus.active,
      startDate: DateTime(2026, 1, 1),
    );

    final vId1 = await purchaseRepo.addVendor('Supplier One');
    final vId2 = await purchaseRepo.addVendor('Supplier Two');

    // Add Purchase: 10 Bags @ ₹400 = ₹4,000 (Paid)
    await purchaseRepo.addPurchase(
      projectId: pId,
      vendorId: vId1,
      date: DateTime(2026, 2, 1),
      itemDescription: 'Cement Grade A',
      amount: 4000,
      quantity: 10,
      unitRate: 400,
      unit: 'Bags',
      paymentStatus: PaymentStatus.paid,
    );

    final purchases = await purchaseRepo.watchAllPurchases().first;
    expect(purchases.length, 1);
    final p = purchases.first;

    // Edit Purchase: Update to 20 Bags @ ₹400 = ₹8,000 with Vendor 2
    await purchaseRepo.updatePurchase(
      purchaseId: p.purchase.id,
      projectId: pId,
      vendorId: vId2,
      date: DateTime(2026, 2, 3),
      itemDescription: 'Cement Grade A+ Premium',
      amount: 8000,
      quantity: 20,
      unitRate: 400,
      unit: 'Bags',
      paidAmount: 8000,
      paymentStatus: PaymentStatus.paid,
    );

    final updatedPurchases = await purchaseRepo.watchAllPurchases().first;
    final up = updatedPurchases.first;
    expect(up.purchase.quantity, 20);
    expect(up.transaction.amount, 8000);
    expect(up.purchase.itemDescription, 'Cement Grade A+ Premium');
    expect(up.vendor.id, vId2);

    // Delete Purchase
    await purchaseRepo.deletePurchase(p.purchase.id);
    final afterDelete = await purchaseRepo.watchAllPurchases().first;
    expect(afterDelete, isEmpty);

    final allTxns = await db.transactionDao.watchAllTransactions().first;
    expect(allTxns, isEmpty, reason: 'Linked transaction deleted cleanly');
  });

  test('Deposit Delete Lifecycle', () async {
    final pId = await projectRepo.createProject(
      code: 'PRJ-DEP-001',
      name: 'Deposit Test Project',
      type: ProjectType.project,
      status: ProjectStatus.active,
      startDate: DateTime(2026, 1, 1),
    );

    await depositRepo.receiveDeposit(
      projectId: pId,
      date: DateTime(2026, 2, 1),
      amount: 100000,
      narration: 'Security Deposit',
    );

    var deposits = await depositRepo.watchAllDeposits().first;
    expect(deposits.length, 1);
    var cashBalance = await cashBookRepo.watchCashBalance().first;
    expect(cashBalance, 100000);

    // Delete deposit
    await depositRepo.deleteDeposit(deposits.first.deposit.id);
    deposits = await depositRepo.watchAllDeposits().first;
    expect(deposits, isEmpty);

    cashBalance = await cashBookRepo.watchCashBalance().first;
    expect(cashBalance, 0);
  });
}
