import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/client_billing/data/client_billing_repository.dart';
import 'package:nex_ledger/features/client_billing/presentation/client_billing_hub_screen.dart';
import 'package:nex_ledger/features/client_billing/presentation/client_ra_bill_form_screen.dart';
import 'package:nex_ledger/features/client_billing/presentation/client_receipt_form_screen.dart';
import 'package:nex_ledger/features/reports/data/report_repository.dart';

void main() {
  late AppDatabase db;
  late ClientBillingRepository billingRepo;
  late ReportRepository reportRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    billingRepo = ClientBillingRepository(
      db.clientBillingDao,
      db.transactionDao,
      db.projectDao,
      db,
    );
    reportRepo = ReportRepository(
      db.transactionDao,
      db.projectDao,
      db.depositDao,
      db.expenseCategoryDao,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Client RA Billing & Contract Revenue Comprehensive Audit', () {
    test(
        '1. Client Contract Setup, Progressive RA Invoicing, Retention Withholding, Receipts & PnL Separation',
        () async {
      // 1. Create a Project with Client Contract of ₹1,00,00,000 (1 Crore)
      final projId = await db.projectDao.insertProject(
        ProjectsCompanion.insert(
          code: 'PRJ-2026-002',
          name: 'Tech Park Tower A',
          clientName: const drift.Value('Apex Mega Developers Ltd'),
          clientContractValue: const drift.Value(10000000.0), // 1 Crore
          clientRetentionPercentage: const drift.Value(5.0),
          type: ProjectType.project,
          status: ProjectStatus.active,
          startDate: DateTime(2026, 1, 1),
          budget: const drift.Value(8000000.0),
        ),
      );

      // Verify initial project progress
      var progress =
          await billingRepo.watchProjectRevenueProgress(projId).first;
      expect(progress, isNotNull);
      expect(progress!.clientContractValue, 10000000.0);
      expect(progress.totalGrossBilled, 0.0);
      expect(progress.billingProgressPercentage, 0.0);
      expect(progress.clientOutstandingReceivables, 0.0);
      expect(progress.clientRetentionHeldByClient, 0.0);

      // 2. Raise RA Bill 01: ₹30,00,000 Gross Work (Plinth & Foundation)
      // Deductions: 5% Retention (₹1,50,000), TDS 1% (₹30,000) -> Net Certified: ₹28,20,000
      final bill1Id = await billingRepo.raiseClientRaBill(
        projectId: projId,
        billNumber: 'RA-01',
        billDate: DateTime(2026, 2, 15),
        stageOrDescription: 'Foundation & Raft Concrete Slab Completed',
        grossAmount: 3000000.0,
        retentionPercentage: 5.0,
        taxOrTdsDeduction: 30000.0,
      );
      expect(bill1Id, greaterThan(0));

      // Verify PnL immediately recognizes ₹30,00,000 gross revenue
      var pnl = await reportRepo.watchProjectPnl(projId).first;
      expect(pnl.income, 3000000.0);

      // Verify progress metrics after RA Bill 01
      progress = await billingRepo.watchProjectRevenueProgress(projId).first;
      expect(progress!.totalGrossBilled, 3000000.0);
      expect(progress.billingProgressPercentage, 30.0);
      expect(progress.totalRetentionWithheld, 150000.0);
      expect(progress.totalNetCertifiedInvoiced, 2820000.0);
      expect(progress.clientOutstandingReceivables, 2820000.0);
      expect(progress.clientRetentionHeldByClient, 150000.0);
      expect(progress.unbilledContractValue, 7000000.0);

      // 3. Raise RA Bill 02: ₹25,00,000 Gross Work (Ground & 1st Floor RCC)
      // Deductions: 5% Retention (₹1,25,000), Mobilization Adv Recovery (₹5,00,000), TDS (₹25,000)
      // Net Certified: ₹18,50,000
      final bill2Id = await billingRepo.raiseClientRaBill(
        projectId: projId,
        billNumber: 'RA-02',
        billDate: DateTime(2026, 3, 20),
        stageOrDescription: 'Ground & 1st Floor Slab Concreting Completed',
        grossAmount: 2500000.0,
        retentionPercentage: 5.0,
        advanceDeduction: 500000.0,
        taxOrTdsDeduction: 25000.0,
      );
      expect(bill2Id, greaterThan(0));

      // PnL income is now ₹55,00,000 (₹30L + ₹25L)
      pnl = await reportRepo.watchProjectPnl(projId).first;
      expect(pnl.income, 5500000.0);

      // Cumulative Progress
      progress = await billingRepo.watchProjectRevenueProgress(projId).first;
      expect(progress!.totalGrossBilled, 5500000.0);
      expect(progress.billingProgressPercentage, closeTo(55.0, 0.01));
      expect(progress.totalRetentionWithheld, 275000.0); // ₹1.5L + ₹1.25L
      expect(progress.totalNetCertifiedInvoiced, 4670000.0); // ₹28.2L + ₹18.5L
      expect(progress.clientOutstandingReceivables, 4670000.0);
      expect(progress.unbilledContractValue, 4500000.0);

      // 4. Record Client Receipt 01: Client pays RA-01 Net Certified (₹28,20,000) via Bank
      final accounts = await db.bankAccountDao.watchAllAccounts().first;
      final bankId = accounts.isNotEmpty ? accounts.first.id : 1;
      final receipt1Id = await billingRepo.recordClientReceipt(
        projectId: projId,
        clientRaBillId: bill1Id,
        receiptDate: DateTime(2026, 2, 28),
        amount: 2820000.0,
        paymentMode: PaymentMode.bank,
        bankAccountId: bankId,
        referenceNo: 'UTR-HDFC-991823719',
      );
      expect(receipt1Id, greaterThan(0));

      // CRITICAL CHECK: PnL income remains exactly ₹55,00,000 (NOT double-booked by cash receipt)
      pnl = await reportRepo.watchProjectPnl(projId).first;
      expect(pnl.income, 5500000.0);

      // Receivables updated: ₹46,70,000 - ₹28,20,000 = ₹18,50,000 due
      progress = await billingRepo.watchProjectRevenueProgress(projId).first;
      expect(progress!.totalClientReceipts, 2820000.0);
      expect(progress.clientOutstandingReceivables, 1850000.0);
      expect(progress.clientRetentionHeldByClient, 275000.0);

      // 5. Record Client Retention Release of ₹1,50,000 after DLP
      final releaseReceiptId = await billingRepo.recordClientReceipt(
        projectId: projId,
        receiptDate: DateTime(2026, 8, 15),
        amount: 150000.0,
        paymentMode: PaymentMode.bank,
        bankAccountId: bankId,
        isRetentionRelease: true,
        referenceNo: 'UTR-HDFC-RET-001',
      );
      expect(releaseReceiptId, greaterThan(0));

      // Remaining Retention with Client: ₹2,75,000 - ₹1,50,000 = ₹1,25,000
      progress = await billingRepo.watchProjectRevenueProgress(projId).first;
      expect(progress!.clientRetentionHeldByClient, 125000.0);
      expect(progress.totalClientReceipts, 2970000.0);
    });

    testWidgets('2. Client Billing screens render cleanly with 0 overflows',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      // 1. Pump ClientBillingHubScreen
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
                child: ClientBillingHubScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ClientBillingHubScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 2. Pump ClientRaBillFormScreen
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
                child: ClientRaBillFormScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ClientRaBillFormScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 3. Pump ClientReceiptFormScreen
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
                child: ClientReceiptFormScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ClientReceiptFormScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
