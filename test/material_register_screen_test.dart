import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:drift/native.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/features/materials/presentation/material_register_screen.dart';
import 'package:nex_ledger/features/materials/providers/material_providers.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';
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

  group('Project Material Register & Quantity Statement Tests', () {
    testWidgets('1. Calculates total quantities, average rate, and groups correctly',
        (tester) async {
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
          name: 'Commercial Complex 02',
          code: 'PRJ-COMM-02',
          startDate: DateTime(2026, 8, 1),
          type: ProjectType.project,
          status: ProjectStatus.active,
        ),
      );

      final vendorId = await purchaseRepo.addVendor('Shree Cement & Steel Mart');

      // 2. Add Inwards for Project 1:
      // Inward 1: 500 bags Cement @ ₹380 = ₹1,90,000
      await purchaseRepo.addPurchase(
        projectId: prj1Id,
        vendorId: vendorId,
        date: DateTime(2026, 8, 2),
        itemDescription: 'Ultratech 53G Cement',
        materialCategory: 'Cement & Concrete',
        quantity: 500.0,
        unit: 'Bags',
        unitRate: 380.0,
        amount: 190000.0,
        paidAmount: 190000.0,
        paymentStatus: PaymentStatus.paid,
        referenceNo: 'INV-CEM-001',
      );

      // Inward 2: 700 bags Cement @ ₹390 = ₹2,73,000
      await purchaseRepo.addPurchase(
        projectId: prj1Id,
        vendorId: vendorId,
        date: DateTime(2026, 8, 10),
        itemDescription: 'Ultratech 53G Cement',
        materialCategory: 'Cement & Concrete',
        quantity: 700.0,
        unit: 'Bags',
        unitRate: 390.0,
        amount: 273000.0,
        paidAmount: 273000.0,
        paymentStatus: PaymentStatus.paid,
        referenceNo: 'INV-CEM-002',
      );

      // Inward 3: 10 Tons Steel @ ₹68,000 = ₹6,80,000
      await purchaseRepo.addPurchase(
        projectId: prj1Id,
        vendorId: vendorId,
        date: DateTime(2026, 8, 12),
        itemDescription: '16mm TMT Fe550D Steel',
        materialCategory: 'Steel & Rebar',
        quantity: 10.0,
        unit: 'Tons',
        unitRate: 68000.0,
        amount: 680000.0,
        paidAmount: 680000.0,
        paymentStatus: PaymentStatus.paid,
        referenceNo: 'INV-STL-001',
      );

      // Inward for Project 2 (should not mix when prj1 is filtered):
      await purchaseRepo.addPurchase(
        projectId: prj2Id,
        vendorId: vendorId,
        date: DateTime(2026, 8, 15),
        itemDescription: 'Ultratech 53G Cement',
        materialCategory: 'Cement & Concrete',
        quantity: 300.0,
        unit: 'Bags',
        unitRate: 380.0,
        amount: 114000.0,
        paidAmount: 114000.0,
        paymentStatus: PaymentStatus.paid,
        referenceNo: 'INV-CEM-003',
      );

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          purchaseRepositoryProvider.overrideWithValue(purchaseRepo),
          materialSelectedProjectIdProvider.overrideWith((ref) => prj1Id),
        ],
      );
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(1440, 900),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, _) => MaterialApp(
              theme: AppTheme.light,
              home: const MaterialRegisterScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify UI displays the aggregated quantities:
      // Total Cement: 500 + 700 = 1200 Bags
      expect(find.text('Project Material Register'), findsOneWidget);
      expect(find.text('Ultratech 53G Cement'), findsOneWidget);
      expect(find.text('1200'), findsOneWidget);
      expect(find.text('Bags'), findsWidgets);

      // Total Steel: 10 Tons
      expect(find.text('16mm TMT Fe550D Steel'), findsOneWidget);
      expect(find.text('10'), findsWidgets);
      expect(find.text('Tons'), findsWidgets);

      // Spend for Project 1: ₹1,90,000 + ₹2,73,000 + ₹6,80,000 = ₹11,43,000
      expect(find.text('₹11,43,000.00'), findsWidgets);

      // Open Inward History dialog for Cement (item 2 because Steel has higher amount)
      final inwardButtons = find.text('Inward History');
      expect(inwardButtons, findsWidgets);
      await tester.ensureVisible(inwardButtons.at(1));
      await tester.tap(inwardButtons.at(1));
      await tester.pumpAndSettle();

      // Inward History Modal should show both delivery consignments for Cement (INV-CEM-001 & INV-CEM-002)
      expect(find.text('Inward Consignment Deliveries (2)'), findsOneWidget);
      expect(find.text('INV-CEM-001'), findsOneWidget);
      expect(find.text('INV-CEM-002'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('2. MaterialRegisterScreen renders cleanly with 0 overflow on narrow desktop',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          purchaseRepositoryProvider.overrideWithValue(purchaseRepo),
        ],
      );
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(950, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(1440, 900),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, _) => MaterialApp(
              theme: AppTheme.light,
              home: const MaterialRegisterScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.text('Project Material Register'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
