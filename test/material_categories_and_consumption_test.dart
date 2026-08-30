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
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';
import 'package:nex_ledger/features/purchase/presentation/purchase_form_screen.dart';
import 'package:nex_ledger/features/purchase/presentation/purchase_list_screen.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_providers.dart';

void main() {
  late AppDatabase db;
  late PurchaseRepository purchaseRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    purchaseRepo = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Material Categories & Project Material Consumption Audit', () {
    test('1. Material Categorization & Project Cumulative Consumption Stats', () async {
      // 1. Setup Projects & Vendor
      final prj1Id = await db.projectDao.insertProject(
        ProjectsCompanion.insert(
          name: 'Luxury Villa 01',
          code: 'PRJ-VILLA-01',
          startDate: DateTime(2026, 8, 1),
          type: ProjectType.project,
          status: ProjectStatus.active,
        ),
      );

      final prj2Id = await db.projectDao.insertProject(
        ProjectsCompanion.insert(
          name: 'Commercial Mall 02',
          code: 'PRJ-MALL-02',
          startDate: DateTime(2026, 8, 1),
          type: ProjectType.project,
          status: ProjectStatus.active,
        ),
      );

      final vendorId = await purchaseRepo.addVendor('Supreme Builders Supply');

      // 2. Add Purchases for Project 1:
      // Bill 1: 200 bags Cement @ ₹400 = ₹80,000
      await purchaseRepo.addPurchase(
        projectId: prj1Id,
        vendorId: vendorId,
        date: DateTime(2026, 8, 1),
        itemDescription: 'UltraTech 53G Cement',
        materialCategory: 'Cement',
        quantity: 200.0,
        unit: 'Bags',
        unitRate: 400.0,
        amount: 80000.0,
        paidAmount: 80000.0,
        paymentStatus: PaymentStatus.paid,
      );

      // Bill 2: 250 bags Cement @ ₹420 = ₹1,05,000
      await purchaseRepo.addPurchase(
        projectId: prj1Id,
        vendorId: vendorId,
        date: DateTime(2026, 8, 5),
        itemDescription: 'ACC Suraksha Cement',
        materialCategory: 'Cement',
        quantity: 250.0,
        unit: 'Bags',
        unitRate: 420.0,
        amount: 105000.0,
        paidAmount: 105000.0,
        paymentStatus: PaymentStatus.paid,
      );

      // Bill 3: 5 Tons Steel @ ₹60,000 = ₹3,00,000
      await purchaseRepo.addPurchase(
        projectId: prj1Id,
        vendorId: vendorId,
        date: DateTime(2026, 8, 8),
        itemDescription: 'TMT 16mm Steel Rods',
        materialCategory: 'Steel / TMT / Rebar',
        quantity: 5.0,
        unit: 'Tons',
        unitRate: 60000.0,
        amount: 300000.0,
        paidAmount: 300000.0,
        paymentStatus: PaymentStatus.paid,
      );

      // 3. Add Purchase for Project 2 (Different Project):
      // Bill 4: 100 bags Cement @ ₹400 = ₹40,000
      await purchaseRepo.addPurchase(
        projectId: prj2Id,
        vendorId: vendorId,
        date: DateTime(2026, 8, 10),
        itemDescription: 'Cement for Mall',
        materialCategory: 'Cement',
        quantity: 100.0,
        unit: 'Bags',
        unitRate: 400.0,
        amount: 40000.0,
        paidAmount: 40000.0,
        paymentStatus: PaymentStatus.paid,
      );

      // 4. Verify Project 1 Material Consumption Breakdown
      final prj1Materials = await purchaseRepo.watchMaterialConsumptionByProject(prj1Id).first;
      expect(prj1Materials.length, 2);

      // Steel Category in PRJ 1
      final steelSummary = prj1Materials.firstWhere((m) => m.categoryName == 'Steel / TMT / Rebar');
      expect(steelSummary.totalQuantity, 5.0);
      expect(steelSummary.unit, 'Tons');
      expect(steelSummary.totalAmount, 300000.0);
      expect(steelSummary.avgUnitRate, 60000.0);
      expect(steelSummary.billCount, 1);

      // Cement Category in PRJ 1 (200 + 250 = 450 Bags, ₹80,000 + ₹1,05,000 = ₹1,85,000)
      final cementSummary = prj1Materials.firstWhere((m) => m.categoryName == 'Cement');
      expect(cementSummary.totalQuantity, 450.0);
      expect(cementSummary.unit, 'Bags');
      expect(cementSummary.totalAmount, 185000.0);
      expect(cementSummary.avgUnitRate, closeTo(411.11, 0.01));
      expect(cementSummary.billCount, 2);

      // 5. Verify Project 2 Material Consumption Isolation
      final prj2Materials = await purchaseRepo.watchMaterialConsumptionByProject(prj2Id).first;
      expect(prj2Materials.length, 1);
      expect(prj2Materials.first.categoryName, 'Cement');
      expect(prj2Materials.first.totalQuantity, 100.0);
      expect(prj2Materials.first.totalAmount, 40000.0);
    });

    testWidgets('2. PurchaseFormScreen & PurchaseListScreen render cleanly with material breakdown', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          purchaseViewTabProvider.overrideWith((ref) => 1), // Material Breakdown tab
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
                child: PurchaseFormScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(PurchaseFormScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Pump PurchaseListScreen
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
                child: PurchaseListScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(PurchaseListScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
