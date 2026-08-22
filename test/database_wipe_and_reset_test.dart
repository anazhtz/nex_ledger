import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/bank_accounts/data/bank_account_repository.dart';
import 'package:nex_ledger/features/cash_book/data/cash_book_repository.dart';
import 'package:nex_ledger/features/projects/data/project_repository.dart';

void main() {
  late AppDatabase db;
  late ProjectRepository projectRepo;
  late BankAccountRepository bankRepo;
  late CashBookRepository cashRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    projectRepo = ProjectRepository(db.projectDao);
    bankRepo = BankAccountRepository(db.bankAccountDao, db.transactionDao, db);
    cashRepo = CashBookRepository(db.transactionDao);
  });

  tearDown(() async => db.close());

  test('wipeAndResetData safely clears all transactional data and resets balances', () async {
    // 1. Create a project
    final pId = await projectRepo.createProject(
      code: 'PRJ-RESET-01',
      name: 'Villa Alpha',
      type: ProjectType.project,
      status: ProjectStatus.active,
      startDate: DateTime(2026, 1, 1),
    );

    // 2. Add an expense
    await cashRepo.addExpense(
      projectId: pId,
      date: DateTime.now(),
      amount: 15000.0,
      paymentMode: PaymentMode.cash,
    );

    // 3. Verify data exists
    var projects = await db.projectDao.getAllProjects();
    expect(projects.length, greaterThanOrEqualTo(1));
    var txns = await db.transactionDao.watchAllTransactions().first;
    expect(txns.length, 1);

    // 4. Perform Wipe & Reset
    await db.wipeAndResetData();

    // 5. Verify all transactional data is gone
    txns = await db.transactionDao.watchAllTransactions().first;
    expect(txns, isEmpty);

    // Project Villa Alpha is gone, but ADMIN-OVH is preserved
    projects = await db.projectDao.getAllProjects();
    expect(projects.any((p) => p.code == 'PRJ-RESET-01'), isFalse);
    expect(projects.any((p) => p.code == 'ADMIN-OVH'), isTrue);

    // Bank accounts are preserved with 0 opening balance
    final accounts = await bankRepo.getAllAccounts();
    expect(accounts, isNotEmpty);
  });
}
