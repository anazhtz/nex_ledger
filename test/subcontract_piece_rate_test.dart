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
import 'package:nex_ledger/features/subcontract/data/subcontract_repository.dart';
import 'package:nex_ledger/features/subcontract/presentation/measurement_bill_form_screen.dart';
import 'package:nex_ledger/features/subcontract/presentation/subcontract_hub_screen.dart';
import 'package:nex_ledger/features/subcontract/presentation/subcontract_payment_form_screen.dart';
import 'package:nex_ledger/features/subcontract/presentation/work_order_detail_screen.dart';
import 'package:nex_ledger/features/subcontract/presentation/work_order_form_screen.dart';

void main() {
  late AppDatabase db;
  late SubcontractRepository subRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    subRepo = SubcontractRepository(db.subcontractDao, db.transactionDao, db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Subcontractor Piece-Rate & Measurement Work Orders Comprehensive Audit', () {
    test('1. Work Order Agreement, Running Measurements, Retention Holding & Due Balance', () async {
      // 1. Setup Project
      final prjId = await db.projectDao.insertProject(
        ProjectsCompanion.insert(
          name: 'Grand Horizon Heights',
          code: 'PRJ-2026-009',
          startDate: DateTime(2026, 8, 1),
          type: ProjectType.project,
          status: ProjectStatus.active,
        ),
      );

      // 2. Register Subcontractor
      final subId = await subRepo.addSubcontractor(
        name: 'Murugan Mason & Plastering Gang',
        trade: 'Plastering (Internal & External)',
        contact: '9840123456',
      );

      // 3. Create Work Order Agreement: 10,000 Sq.ft @ ₹18 / Sq.ft = ₹1,80,000 with 5% Retention
      final woId = await subRepo.createWorkOrder(
        orderNumber: 'WO-2026-001',
        projectId: prjId,
        subcontractorId: subId,
        title: 'Internal Wall & Ceiling Plastering',
        trade: 'Plastering',
        unit: 'Sq.ft',
        agreedRate: 18.0,
        estimatedQuantity: 10000.0,
        retentionPercentage: 5.0,
        startDate: DateTime(2026, 8, 1),
      );

      final woDetail = await subRepo.getWorkOrderDetailById(woId);
      expect(woDetail, isNotNull);
      expect(woDetail!.workOrder.contractAmount, 180000.0);
      expect(woDetail.workOrder.retentionPercentage, 5.0);

      // 4. Certified Measurement 1 (RA Bill 1): 4,000 Sq.ft
      // Gross: 4,000 * ₹18 = ₹72,000
      // Retention (5%): ₹3,600
      // Net Billable: ₹68,400
      await subRepo.recordMeasurementBill(
        workOrderId: woId,
        billNumber: 'MB-01',
        date: DateTime(2026, 8, 10),
        measuredQuantity: 4000.0,
        unitRate: 18.0,
        retentionPercentage: 5.0,
        locationOrDescription: 'Ground floor living room and bedrooms plastered',
      );

      // Verify Project P&L recognizes the gross cost of ₹72,000
      final prjTxns = await db.transactionDao.watchTransactionsByProject(prjId).first;
      final bill1Txn = prjTxns.firstWhere((t) => t.type == TransactionType.subcontractBill);
      expect(bill1Txn.amount, 72000.0);
      expect(bill1Txn.affectsPnl, true);
      expect(bill1Txn.affectsCash, false); // No cash out upon measurement certification

      // Check Work Order Financial Summary after Bill 1
      var summary = await subRepo.watchWorkOrderFinancialSummary(woId).first;
      expect(summary, isNotNull);
      expect(summary!.totalMeasuredQuantity, 4000.0);
      expect(summary.progressPercentage, 40.0);
      expect(summary.totalGrossCertified, 72000.0);
      expect(summary.totalRetentionHeld, 3600.0);
      expect(summary.totalNetBillable, 68400.0);
      expect(summary.totalPaid, 0.0);
      expect(summary.currentNetDue, 68400.0);

      // 5. Certified Measurement 2 (RA Bill 2): 3,000 Sq.ft
      // Gross: 3,000 * ₹18 = ₹54,000
      // Retention (5%): ₹2,700
      // Net Billable: ₹51,300
      await subRepo.recordMeasurementBill(
        workOrderId: woId,
        billNumber: 'MB-02',
        date: DateTime(2026, 8, 20),
        measuredQuantity: 3000.0,
        unitRate: 18.0,
        retentionPercentage: 5.0,
        locationOrDescription: '1st floor corridors & ceiling',
      );

      summary = await subRepo.watchWorkOrderFinancialSummary(woId).first;
      expect(summary!.totalMeasuredQuantity, 7000.0);
      expect(summary.progressPercentage, 70.0);
      expect(summary.totalGrossCertified, 126000.0); // 72,000 + 54,000
      expect(summary.totalRetentionHeld, 6300.0);   // 3,600 + 2,700
      expect(summary.totalNetBillable, 119700.0);   // 126,000 - 6,300
      expect(summary.currentNetDue, 119700.0);

      // 6. Record Running Advance / Payment: ₹70,000
      await subRepo.recordSubcontractPayment(
        subcontractorId: subId,
        projectId: prjId,
        workOrderId: woId,
        amount: 70000.0,
        paymentDate: DateTime(2026, 8, 22),
        paymentMode: PaymentMode.bank,
        referenceNo: 'IMPS-9821389',
        notes: 'Running payment for MB-01 and MB-02',
      );

      // Verify payment moves physical cash, but does NOT double count in P&L
      final updatedPrjTxns = await db.transactionDao.watchTransactionsByProject(prjId).first;
      final payTxn = updatedPrjTxns.firstWhere((t) => t.type == TransactionType.subcontractPayment);
      expect(payTxn.amount, 70000.0);
      expect(payTxn.affectsPnl, false); // P&L already recognized at measurement time
      expect(payTxn.affectsCash, true); // Moves bank cash balance

      // Verify running due balance: ₹1,19,700 - ₹70,000 = ₹49,700
      summary = await subRepo.watchWorkOrderFinancialSummary(woId).first;
      expect(summary!.totalPaid, 70000.0);
      expect(summary.currentNetDue, 49700.0);
      expect(summary.totalRetentionHeld, 6300.0);

      // 7. Verify Subcontractor Summary in Directory
      final subSummaries = await subRepo.watchAllSubcontractorSummaries().first;
      expect(subSummaries.length, 1);
      final subSummary = subSummaries.first;
      expect(subSummary.subcontractor.id, subId);
      expect(subSummary.activeWorkOrdersCount, 1);
      expect(subSummary.totalContractValue, 180000.0);
      expect(subSummary.totalGrossCertified, 126000.0);
      expect(subSummary.totalRetentionHeld, 6300.0);
      expect(subSummary.totalPaid, 70000.0);
      expect(subSummary.currentNetDue, 49700.0);
    });

    testWidgets('2. Subcontract screens render cleanly with 0 overflows', (tester) async {
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

      // Pump SubcontractHubScreen
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
                child: SubcontractHubScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SubcontractHubScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Pump WorkOrderFormScreen
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
                child: WorkOrderFormScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(WorkOrderFormScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Pump MeasurementBillFormScreen
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
                child: MeasurementBillFormScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(MeasurementBillFormScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Pump SubcontractPaymentFormScreen
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
                child: SubcontractPaymentFormScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SubcontractPaymentFormScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
