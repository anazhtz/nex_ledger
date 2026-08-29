import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/petty_cash/data/petty_cash_repository.dart';
import 'package:nex_ledger/features/petty_cash/presentation/petty_cash_hub_screen.dart';
import 'package:nex_ledger/features/petty_cash/presentation/petty_cash_wallet_form_screen.dart';
import 'package:nex_ledger/features/petty_cash/presentation/petty_cash_voucher_form_screen.dart';
import 'package:nex_ledger/features/petty_cash/presentation/widgets/petty_cash_disburse_or_return_dialog.dart';

void main() {
  late AppDatabase db;
  late PettyCashRepository pettyCashRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    pettyCashRepo = PettyCashRepository(
      db.pettyCashDao,
      db.transactionDao,
      db,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Site Supervisor Petty Cash & Imprest Float Module Audit', () {
    test(
        '1. Disburse Advance (Cash Out, P&L=0), Expense Vouchers (P&L Hit, Cash Unmoved), Return Unspent Cash & Running Balance',
        () async {
      // 1. Create a Project Site & Bank Account
      final projId = await db.projectDao.insertProject(
        ProjectsCompanion.insert(
          code: 'PRJ-PETTY-2026',
          name: 'Commercial Mall Complex',
          type: ProjectType.project,
          status: ProjectStatus.active,
          startDate: DateTime(2026, 1, 1),
        ),
      );

      final bankId = await db.bankAccountDao.insertAccount(
        BankAccountsCompanion.insert(
          accountName: 'HDFC Current Site Account',
          bankName: const drift.Value('HDFC Bank'),
          accountNumber: const drift.Value('50200012345678'),
          openingBalance: const drift.Value(500000.0),
        ),
      );

      // 2. Create Supervisor Wallet
      final walletId = await pettyCashRepo.createWallet(
        supervisorName: 'Engr. Rajesh Sharma',
        phone: '9840123456',
        assignedProjectId: projId,
        maxFloatLimit: 50000.0,
      );
      expect(walletId, greaterThan(0));

      // 3. Disburse Float Advance: ₹30,000 from Bank Account
      // Physical Cash moves out of bank (affectsCash = true)
      // P&L is unaffected (affectsPnl = false, imprest asset transfer)
      final advVoucherId = await pettyCashRepo.disburseCashAdvance(
        walletId: walletId,
        projectId: projId,
        date: DateTime(2026, 1, 5),
        amount: 30000.0,
        paymentMode: PaymentMode.bank,
        bankAccountId: bankId,
        narration: 'Disbursed site imprest float advance',
        voucherNumber: 'ADV-001',
      );
      expect(advVoucherId, greaterThan(0));

      // Check Wallet Balance: should be ₹30,000 unspent in pocket
      var summary = await pettyCashRepo.watchWalletById(walletId).first;
      expect(summary, isNotNull);
      expect(summary!.totalAdvancesReceived, 30000.0);
      expect(summary.totalExpensesClaimed, 0.0);
      expect(summary.totalCashReturned, 0.0);
      expect(summary.currentUnspentCashBalance, 30000.0);

      // Verify Transaction: affectsCash = true, affectsPnl = false
      var txns = await db.select(db.transactions).get();
      var advTxn = txns.firstWhere((t) => t.amount == 30000.0);
      expect(advTxn.affectsCash, isTrue);
      expect(advTxn.affectsPnl, isFalse);

      // 4. Record Site Expense Voucher 1: ₹4,500 for Worker Tea/Food
      // P&L recognizes ₹4,500 expense (affectsPnl = true)
      // Cash doesn't move again (affectsCash = false, money already left in step 3)
      final v1Id = await pettyCashRepo.recordExpenseVoucher(
        walletId: walletId,
        projectId: projId,
        date: DateTime(2026, 1, 6),
        amount: 4500.0,
        category: 'Worker Tea, Food & Refreshments',
        costHead: BudgetCostHead.labour,
        voucherNumber: 'VCH-101',
        narration: 'Night concrete pour tea and worker snacks',
      );
      expect(v1Id, greaterThan(0));

      // Record Site Expense Voucher 2: ₹6,000 for Water Tanker
      final v2Id = await pettyCashRepo.recordExpenseVoucher(
        walletId: walletId,
        projectId: projId,
        date: DateTime(2026, 1, 7),
        amount: 6000.0,
        category: 'Water Tanker & Site Utilities',
        costHead: BudgetCostHead.equipmentOverhead,
        voucherNumber: 'VCH-102',
        narration: '3 Water tankers for slab curing',
      );
      expect(v2Id, greaterThan(0));

      // Check Wallet Balance: ₹30,000 - ₹10,500 = ₹19,500 in pocket!
      summary = await pettyCashRepo.watchWalletById(walletId).first;
      expect(summary!.totalAdvancesReceived, 30000.0);
      expect(summary.totalExpensesClaimed, 10500.0);
      expect(summary.currentUnspentCashBalance, 19500.0);

      // Verify Expense Transactions: affectsPnl = true, affectsCash = false
      txns = await db.select(db.transactions).get();
      var expTxn1 = txns.firstWhere((t) => t.amount == 4500.0);
      expect(expTxn1.affectsPnl, isTrue);
      expect(expTxn1.affectsCash, isFalse);

      // 5. Return Unspent Cash: Supervisor returns ₹9,500 to office
      // Cash enters office drawer (affectsCash = true)
      // P&L is unaffected (affectsPnl = false)
      final retVoucherId = await pettyCashRepo.returnUnspentCash(
        walletId: walletId,
        projectId: projId,
        date: DateTime(2026, 1, 8),
        amount: 9500.0,
        paymentMode: PaymentMode.cash,
        narration: 'Returned unused cash after slab completion',
        voucherNumber: 'RET-01',
      );
      expect(retVoucherId, greaterThan(0));

      // Check Final Wallet Balance: ₹19,500 - ₹9,500 = ₹10,000 remaining in pocket!
      summary = await pettyCashRepo.watchWalletById(walletId).first;
      expect(summary!.totalAdvancesReceived, 30000.0);
      expect(summary.totalExpensesClaimed, 10500.0);
      expect(summary.totalCashReturned, 9500.0);
      expect(summary.currentUnspentCashBalance, 10000.0);

      // 6. Portfolio Metrics Check
      final metrics = await pettyCashRepo.watchPettyCashPortfolioMetrics().first;
      expect(metrics.activeSupervisorsCount, 1);
      expect(metrics.totalFloatDisbursed, 30000.0);
      expect(metrics.totalSiteExpensesClaimed, 10500.0);
      expect(metrics.totalCashReturned, 9500.0);
      expect(metrics.totalCashInSupervisorsPockets, 10000.0);
    });

    testWidgets('2a. PettyCashHubScreen renders cleanly with 0 overflows', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(1440, 900),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, _) => const MaterialApp(
              home: SizedBox(
                width: 1280,
                height: 800,
                child: PettyCashHubScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(PettyCashHubScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('2b. PettyCashWalletFormScreen renders cleanly with 0 overflows', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(1440, 900),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, _) => const MaterialApp(
              home: SizedBox(
                width: 1280,
                height: 800,
                child: PettyCashWalletFormScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(PettyCashWalletFormScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('2c. PettyCashVoucherFormScreen renders cleanly with 0 overflows', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(1440, 900),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, _) => const MaterialApp(
              home: SizedBox(
                width: 1280,
                height: 800,
                child: PettyCashVoucherFormScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(PettyCashVoucherFormScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('2d. PettyCashDisburseOrReturnDialog renders cleanly with 0 overflows', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(1440, 900),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, _) => const MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 1280,
                  height: 800,
                  child: PettyCashDisburseOrReturnDialog(),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(PettyCashDisburseOrReturnDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
