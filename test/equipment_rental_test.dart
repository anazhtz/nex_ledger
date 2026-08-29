import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/equipment/data/equipment_repository.dart';
import 'package:nex_ledger/features/equipment/presentation/equipment_hub_screen.dart';
import 'package:nex_ledger/features/equipment/presentation/equipment_form_screen.dart';
import 'package:nex_ledger/features/equipment/presentation/equipment_log_form_screen.dart';

void main() {
  late AppDatabase db;
  late EquipmentRepository equipmentRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    equipmentRepo = EquipmentRepository(
      db.equipmentDao,
      db.transactionDao,
      db,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Site Machinery & Equipment Rental Module Audit', () {
    test(
        '1. Equipment Fleet Master, Daily Meter Usage, Contractor Diesel Deductions & PnL Settlement',
        () async {
      // 1. Create a Project
      final projId = await db.projectDao.insertProject(
        ProjectsCompanion.insert(
          code: 'PRJ-INFRA-2026',
          name: 'City Flyover & Metro Station',
          type: ProjectType.project,
          status: ProjectStatus.active,
          startDate: DateTime(2026, 1, 1),
        ),
      );

      // 2. Create Equipment Rental Vendor
      final vendorId = await db.purchaseDao.insertVendor(
        VendorsCompanion.insert(
          name: 'Sree Balaji Earthmovers & Cranes',
          contact: const drift.Value('9840123456'),
        ),
      );

      // 3. Register Rented Machinery (JCB 3DX)
      final jcbId = await equipmentRepo.createEquipment(
        name: 'JCB 3DX Super Backhoe Loader',
        assetOrRegNumber: 'TN-09-CB-4455',
        category: 'JCB / Backhoe Loader',
        ownership: EquipmentOwnership.rented,
        vendorId: vendorId,
        currentProjectId: projId,
        rentalBasis: EquipmentRentalBasis.hourly,
        standardRate: 1200.0, // ₹1,200 / hr
        fuelPolicy: EquipmentFuelPolicy.contractorSupplied,
        operatorName: 'Suresh Operator',
      );
      expect(jcbId, greaterThan(0));

      // 4. Register Company Owned Asset (Tower Crane)
      final craneId = await equipmentRepo.createEquipment(
        name: 'Potain 50T High-Rise Tower Crane',
        assetOrRegNumber: 'ASSET-TC-001',
        category: 'Tower Crane',
        ownership: EquipmentOwnership.owned,
        currentProjectId: projId,
        rentalBasis: EquipmentRentalBasis.monthly,
        standardRate: 150000.0,
        fuelPolicy: EquipmentFuelPolicy.vendorSupplied,
      );
      expect(craneId, greaterThan(0));

      // Verify Fleet List
      final fleet = await equipmentRepo.watchAllEquipments().first;
      expect(fleet.length, 2);
      expect(fleet.any((e) => e.equipment.id == jcbId && e.vendor?.name == 'Sree Balaji Earthmovers & Cranes'), isTrue);
      expect(fleet.any((e) => e.equipment.id == craneId && e.equipment.ownership == EquipmentOwnership.owned), isTrue);

      // 5. Record Daily Log Sheet for JCB:
      // Start Reading: 1200.0 hrs, End Reading: 1210.0 hrs (Total 10.0 hrs logged)
      // Breakdown / Rain stoppage: 1.0 hr non-billable
      // Billable Hours: 9.0 hrs @ ₹1,200/hr = Gross Rental ₹10,800
      // Contractor Diesel Issued: 40.0 Litres @ ₹95.00/Litre = Diesel Cost Deduction ₹3,800
      // Net Payable to Machine Owner = ₹10,800 - ₹3,800 = ₹7,000!
      final logId = await equipmentRepo.recordDailyLog(
        equipmentId: jcbId,
        projectId: projId,
        logDate: DateTime(2026, 1, 10),
        startReading: 1200.0,
        endReading: 1210.0,
        totalUnitsLogged: 10.0,
        breakdownUnits: 1.0,
        billableUnits: 9.0,
        unitRate: 1200.0,
        grossRentalCost: 10800.0,
        fuelLitresIssued: 40.0,
        fuelRatePerLitre: 95.0,
        fuelCostDeduction: 3800.0,
        netPayableAmount: 7000.0,
        workDescription: 'Pillar excavation and foundation pit trenching',
        operatorName: 'Suresh Operator',
        supervisorVerified: true,
      );
      expect(logId, greaterThan(0));

      // Verify Logs Query
      final logs = await equipmentRepo.watchEquipmentLogs(projectId: projId).first;
      expect(logs.length, 1);
      final logDetail = logs.first;
      expect(logDetail.log.grossRentalCost, 10800.0);
      expect(logDetail.log.fuelCostDeduction, 3800.0);
      expect(logDetail.log.netPayableAmount, 7000.0);
      expect(logDetail.equipment.name, 'JCB 3DX Super Backhoe Loader');
      expect(logDetail.project.code, 'PRJ-INFRA-2026');

      // Verify Fleet Metrics
      final metrics = await equipmentRepo.watchEquipmentFleetMetrics().first;
      expect(metrics.totalMachineryCount, 2);
      expect(metrics.rentedCount, 1);
      expect(metrics.ownedCount, 1);
      expect(metrics.totalLoggedUnits, 9.0);
      expect(metrics.totalGrossRentalIncurred, 10800.0);
      expect(metrics.totalFuelDeducted, 3800.0);
      expect(metrics.totalNetRentalPayable, 7000.0);

      // 6. Record Settlement Payment to Machine Owner
      final txnId = await equipmentRepo.recordEquipmentRentalPayment(
        projectId: projId,
        equipmentId: jcbId,
        paymentAmount: 7000.0,
        paymentDate: DateTime(2026, 1, 12),
        paymentMode: PaymentMode.bank,
        narration: 'Settlement for JCB usage on 10th Jan after ₹3,800 diesel deduction',
      );
      expect(txnId, greaterThan(0));

      // Verify Expense Transaction
      final txns = await db.select(db.transactions).get();
      final pnlTxn = txns.firstWhere((t) => t.id == txnId);
      expect(pnlTxn.type, TransactionType.expense);
      expect(pnlTxn.amount, 7000.0);
      expect(pnlTxn.affectsPnl, isTrue);
      expect(pnlTxn.affectsCash, isTrue);
    });

    testWidgets('2. Equipment Screens render cleanly with 0 overflows', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      // Seed Project & Equipment
      final projId = await db.projectDao.insertProject(
        ProjectsCompanion.insert(
          code: 'PRJ-TEST-EQ',
          name: 'Metro Line Expansion',
          type: ProjectType.project,
          status: ProjectStatus.active,
          startDate: DateTime(2026, 1, 1),
        ),
      );

      final eqId = await equipmentRepo.createEquipment(
        name: 'Hydraulic Poclain Excavator',
        assetOrRegNumber: 'DL-01-AX-9900',
        category: 'Hydraulic Excavator (Poclain)',
        ownership: EquipmentOwnership.rented,
        currentProjectId: projId,
        rentalBasis: EquipmentRentalBasis.hourly,
        standardRate: 2400.0,
        fuelPolicy: EquipmentFuelPolicy.contractorSupplied,
      );

      // 1. Pump EquipmentHubScreen
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
                child: EquipmentHubScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(EquipmentHubScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 2. Pump EquipmentFormScreen
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
                child: EquipmentFormScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(EquipmentFormScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 3. Pump EquipmentLogFormScreen
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(1440, 900),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, _) => MaterialApp(
              home: SizedBox(
                width: 1280,
                height: 800,
                child: EquipmentLogFormScreen(initialEquipmentId: eqId, initialProjectId: projId),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(EquipmentLogFormScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
