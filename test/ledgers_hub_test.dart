import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/features/reports/data/ledger_repository.dart';
import 'package:nex_ledger/features/reports/presentation/ledgers_hub_screen.dart';

void main() {
  late AppDatabase db;
  late LedgerRepository ledgerRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    ledgerRepo = LedgerRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Ledgers Hub & Statements — Comprehensive Business Rules & Accounting Audit', () {
    test('1. Supplier / Vendor Ledger: Billed, Settled, and Running Payable Due', () async {
      // 1. Setup Project & Vendor
      final projId = await db.projectDao.insertProject(
        ProjectsCompanion.insert(
          name: 'Commercial Plaza',
          code: 'PRJ-PLAZA-01',
          startDate: DateTime(2026, 8, 1),
          type: ProjectType.project,
          status: ProjectStatus.active,
        ),
      );

      final vendorId = await db.purchaseDao.insertVendor(
        VendorsCompanion.insert(
          name: 'Supreme Cement & Steel',
          contact: const Value('9876543210'),
        ),
      );

      // 2. Purchase Bill 1: 50 bags @ ₹400 = ₹20,000 (Paid ₹5,000 at bill time, ₹15,000 pending)
      final txnId1 = await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projId,
          date: DateTime(2026, 8, 1),
          type: TransactionType.purchase,
          affectsPnl: const Value(true),
          affectsCash: const Value(true),
          amount: 20000.0,
          paymentMode: const Value(PaymentMode.bank),
          referenceNo: const Value('BILL-101'),
        ),
      );

      await db.into(db.purchases).insert(
        PurchasesCompanion.insert(
          transactionId: txnId1,
          vendorId: vendorId,
          itemDescription: 'UltraTech Cement 50 Bags',
          quantity: const Value(50.0),
          unitRate: const Value(400.0),
          unit: const Value('bags'),
          paidAmount: const Value(5000.0),
          paymentStatus: PaymentStatus.partial,
        ),
      );

      // 3. Purchase Bill 2: 2 Tons TMT Steel @ ₹60,000 = ₹1,20,000 (Full Credit / Pending)
      final txnId2 = await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projId,
          date: DateTime(2026, 8, 5),
          type: TransactionType.purchase,
          affectsPnl: const Value(true),
          affectsCash: const Value(false),
          amount: 120000.0,
          paymentMode: const Value(PaymentMode.bank),
          referenceNo: const Value('BILL-102'),
        ),
      );

      await db.into(db.purchases).insert(
        PurchasesCompanion.insert(
          transactionId: txnId2,
          vendorId: vendorId,
          itemDescription: 'TMT Steel 12mm 2 Tons',
          quantity: const Value(2.0),
          unitRate: const Value(60000.0),
          unit: const Value('tons'),
          paidAmount: const Value(0.0),
          paymentStatus: PaymentStatus.pending,
        ),
      );

      // 4. Standalone Settlement Payment: ₹50,000 paid to Supreme Cement & Steel
      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projId,
          date: DateTime(2026, 8, 10),
          type: TransactionType.purchasePayment,
          affectsPnl: const Value(false), // P&L was already hit at bill creation
          affectsCash: const Value(true),
          amount: 50000.0,
          paymentMode: const Value(PaymentMode.bank),
          referenceNo: const Value('CHQ-8899'),
          narration: const Value('Cheque payment to Supreme Cement & Steel'),
        ),
      );

      // 5. Verify Supplier Ledger
      final result = await ledgerRepo.watchVendorLedger(vendorId).first;
      final summary = result.summary;
      final entries = result.entries;

      // Total Billed: ₹20,000 + ₹1,20,000 = ₹1,40,000
      expect(summary.totalCredit, 140000.0);
      // Total Paid: ₹5,000 (initial) + ₹50,000 (settlement) = ₹55,000
      expect(summary.totalDebit, 55000.0);
      // Net Outstanding Payable: ₹1,40,000 - ₹55,000 = ₹85,000
      expect(summary.closingBalance, 85000.0);
      expect(summary.isPayable, true);

      // Verify entries count: Bill 1 (Cr), Bill 1 Paid (Dr), Bill 2 (Cr), Standalone Payment (Dr) = 4 entries
      expect(entries.length, 4);
    });

    test('2. Labour / Worker Ledger: Attendance Earned, Paid, and Running Wage Due', () async {
      // 1. Setup Project & Worker
      final projId = await db.projectDao.insertProject(
        ProjectsCompanion.insert(
          name: 'Residential Tower',
          code: 'PRJ-TOWER-02',
          startDate: DateTime(2026, 8, 1),
          type: ProjectType.project,
          status: ProjectStatus.active,
        ),
      );

      final workerId = await db.labourDao.insertWorker(
        WorkersCompanion.insert(
          name: 'Sunil Kumar',
          dailyRate: const Value(1200.0),
          trade: const Value('Mason'),
          workerCode: const Value('WRK-001'),
        ),
      );

      // 2. Record Attendance for 3 days:
      // Day 1: Present (1.0d) = ₹1,200
      await db.labourDao.upsertAttendance(
        AttendanceCompanion.insert(
          workerId: workerId,
          projectId: projId,
          date: DateTime(2026, 8, 1),
          status: AttendanceStatus.present,
        ),
      );

      // Day 2: Half Day (0.5d) = ₹600
      await db.labourDao.upsertAttendance(
        AttendanceCompanion.insert(
          workerId: workerId,
          projectId: projId,
          date: DateTime(2026, 8, 2),
          status: AttendanceStatus.halfDay,
        ),
      );

      // Day 3: Present (1.0d) = ₹1,200
      await db.labourDao.upsertAttendance(
        AttendanceCompanion.insert(
          workerId: workerId,
          projectId: projId,
          date: DateTime(2026, 8, 3),
          status: AttendanceStatus.present,
        ),
      );

      // Total earned: 2.5 days * ₹1,200 = ₹3,000

      // 3. Issue Labour Wage Payment of ₹1,500
      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projId,
          workerId: Value(workerId),
          date: DateTime(2026, 8, 4),
          type: TransactionType.labourPayment,
          affectsPnl: const Value(true),
          affectsCash: const Value(true),
          amount: 1500.0,
          paymentMode: const Value(PaymentMode.cash),
          referenceNo: const Value('WAGE-VOUCHER-01'),
        ),
      );

      // 4. Verify Labour Ledger
      final result = await ledgerRepo.watchWorkerLedger(workerId).first;
      final summary = result.summary;
      final entries = result.entries;

      // Total Wages Earned (Credit): ₹3,000
      expect(summary.totalCredit, 3000.0);
      // Total Payments Paid (Debit): ₹1,500
      expect(summary.totalDebit, 1500.0);
      // Net Wage Due (Payable): ₹1,500
      expect(summary.closingBalance, 1500.0);
      expect(entries.length, 4); // 3 attendance items + 1 payment
    });

    test('3. Bank & Cash Account Ledger: Opening Balance, Inflows, Outflows, and Running Balance', () async {
      // 1. Setup Bank Account
      final bankId = await db.bankAccountDao.insertAccount(
        BankAccountsCompanion.insert(
          accountName: 'State Bank of India Current A/c',
          bankName: const Value('SBI'),
          accountNumber: const Value('1234567890'),
          openingBalance: const Value(100000.0), // ₹1,00,000 Opening Balance
          isDefault: const Value(true),
        ),
      );

      final projId = await db.projectDao.insertProject(
        ProjectsCompanion.insert(
          name: 'Admin Overhead',
          code: 'ADMIN-01',
          startDate: DateTime(2026, 8, 1),
          type: ProjectType.adminOverhead,
          status: ProjectStatus.active,
        ),
      );

      // 2. Client Income into SBI: ₹50,000
      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projId,
          date: DateTime(2026, 8, 1),
          type: TransactionType.income,
          affectsPnl: const Value(true),
          affectsCash: const Value(true),
          amount: 50000.0,
          bankAccountId: Value(bankId),
          paymentMode: const Value(PaymentMode.bank),
          referenceNo: const Value('NEFT-CLIENT-01'),
        ),
      );

      // 3. Office Expense from SBI: ₹20,000
      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projId,
          date: DateTime(2026, 8, 5),
          type: TransactionType.expense,
          affectsPnl: const Value(true),
          affectsCash: const Value(true),
          amount: 20000.0,
          bankAccountId: Value(bankId),
          paymentMode: const Value(PaymentMode.bank),
          referenceNo: const Value('CHQ-EXP-01'),
        ),
      );

      // 4. Verify Account Ledger
      final result = await ledgerRepo.watchAccountLedger(bankAccountId: bankId).first;
      final summary = result.summary;
      final entries = result.entries;

      expect(summary.openingBalance, 100000.0);
      expect(summary.totalCredit, 50000.0);
      expect(summary.totalDebit, 20000.0);
      // Closing = 100,000 + 50,000 - 20,000 = 130,000
      expect(summary.closingBalance, 130000.0);
      expect(entries.length, 2);
    });

    test('4. Personal / Owner Equity Ledger: Capital Injected, Drawings, and P&L Isolation', () async {
      // 1. Record Owner Capital Injection: ₹2,00,000
      await ledgerRepo.recordOwnerCapital(
        amount: 200000.0,
        date: DateTime(2026, 8, 1),
        paymentMode: PaymentMode.bank,
        narration: 'Proprietor initial capital injected',
        referenceNo: 'CAP-001',
      );

      // 2. Record Owner Personal Drawings: ₹40,000
      await ledgerRepo.recordOwnerDrawings(
        amount: 40000.0,
        date: DateTime(2026, 8, 10),
        paymentMode: PaymentMode.cash,
        narration: 'Household personal expenses withdrawal',
        referenceNo: 'DRW-001',
      );

      // 3. Verify Personal Ledger
      final result = await ledgerRepo.watchPersonalLedger().first;
      final summary = result.summary;
      final entries = result.entries;

      // Total Capital Injected (Credit): ₹2,00,000
      expect(summary.totalCredit, 200000.0);
      // Total Drawings (Debit): ₹40,000
      expect(summary.totalDebit, 40000.0);
      // Net Owner Capital: ₹1,60,000
      expect(summary.closingBalance, 160000.0);
      expect(entries.length, 2);

      // 4. CRITICAL: Verify Cash Balance reflects net +₹1,60,000
      final cashBalance = await db.transactionDao.watchCashBalance().first;
      expect(cashBalance, 160000.0);

      // 5. CRITICAL: Verify Project P&L is strictly ₹0 (Owner transactions must NEVER touch P&L)
      final allTxns = await db.transactionDao.watchAllRawTransactions().first;
      final pnlTxns = allTxns.where((t) => t.affectsPnl == true).toList();
      expect(pnlTxns.isEmpty, true);
    });

    testWidgets('5. LedgersHubScreen renders cleanly with 0 overflows', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
            builder: (context, _) => MaterialApp(
              theme: AppTheme.light,
              home: const SizedBox(
                width: 1280,
                height: 800,
                child: LedgersHubScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LedgersHubScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
