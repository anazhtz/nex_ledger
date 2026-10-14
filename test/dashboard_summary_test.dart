import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/cash_book/data/cash_book_repository.dart';
import 'package:nex_ledger/features/dashboard/providers/dashboard_provider.dart';
import 'package:nex_ledger/features/deposits/data/deposit_repository.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late int projectId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)]);
    projectId = await db.projectDao.insertProject(ProjectsCompanion.insert(
      code: 'PRJ-1',
      name: 'Test',
      type: ProjectType.project,
      status: ProjectStatus.active,
      startDate: DateTime.now(),
    ));
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('today in/out ignores old entries and non-cash adjustments', () async {
    final cash = CashBookRepository(db.transactionDao);
    final deposits = DepositRepository(db.depositDao, db.transactionDao, db);

    await cash.addIncome(
        projectId: projectId, date: DateTime.now(), amount: 1000);
    await cash.addExpense(
        projectId: projectId, date: DateTime.now(), amount: 300);
    // Yesterday: must not count.
    await cash.addIncome(
        projectId: projectId,
        date: DateTime.now().subtract(const Duration(days: 1)),
        amount: 9999);
    // Deposit adjusted to income moves no cash: must not count.
    await deposits.receiveDeposit(
        projectId: projectId,
        date: DateTime.now().subtract(const Duration(days: 2)),
        amount: 500);
    final dep = (await db.depositDao.watchDepositsByProject(projectId).first)
        .first
        .deposit
        .id;
    await deposits.adjustDepositToIncome(
        depositId: dep,
        projectId: projectId,
        adjustedAmount: 500,
        date: DateTime.now(),
        isFullyAdjusted: true);

    final flow = await container.read(todayCashFlowProvider.future);
    expect(flow.inflow, 1000);
    expect(flow.outflow, 300);
  });

  test('vendor bills to pay sums unpaid purchases', () async {
    final purchases = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
    final vendorId =
        await db.purchaseDao.insertVendor(VendorsCompanion.insert(name: 'V'));
    await purchases.addPurchase(
      projectId: projectId,
      vendorId: vendorId,
      date: DateTime.now(),
      itemDescription: 'Cement',
      amount: 8000,
      paymentStatus: PaymentStatus.pending,
    );
    final summary = await container.read(dashboardSummaryProvider.future);
    expect(summary.accountsPayable, 8000);
  });
}
