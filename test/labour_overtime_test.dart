import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/core/utils/wage_calculator.dart';
import 'package:nex_ledger/features/labour/data/labour_repository.dart';
import 'package:nex_ledger/features/labour/presentation/attendance_screen.dart';
import 'package:nex_ledger/features/labour/providers/labour_providers.dart';

void main() {
  late AppDatabase db;
  late LabourRepository repo;
  late int projectId;
  final day = DateTime(2026, 8, 4);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = LabourRepository(db.labourDao, db.transactionDao);
    projectId = await db.projectDao.insertProject(ProjectsCompanion.insert(
      code: 'PRJ-1',
      name: 'Villa',
      type: ProjectType.project,
      status: ProjectStatus.active,
      startDate: DateTime(2026, 1, 1),
    ));
  });

  tearDown(() async => db.close());

  group('wage math', () {
    test('default OT rate is daily rate / 8', () async {
      final id = await repo.addWorker(name: 'Raju', dailyRate: 800);
      final w = (await db.labourDao.getWorkerById(id))!;
      expect(w.effectiveOvertimeRate, 100);
      expect(dayWage(w, AttendanceStatus.present, 2), 1000);
      expect(dayWage(w, AttendanceStatus.halfDay, 1), 500);
      expect(dayWage(w, AttendanceStatus.absent, 0), 0);
    });

    test('a worker-specific OT rate wins', () async {
      final id =
          await repo.addWorker(name: 'Ali', dailyRate: 800, overtimeRate: 150);
      final w = (await db.labourDao.getWorkerById(id))!;
      expect(w.effectiveOvertimeRate, 150);
      expect(dayWage(w, AttendanceStatus.present, 2), 1100);
    });
  });

  group('saving attendance with overtime', () {
    test('OT counts in running balance and re-saving updates, not duplicates',
        () async {
      final id = await repo.addWorker(name: 'Raju', dailyRate: 800);
      await repo.saveBatchAttendance(
        projectId: projectId,
        date: day,
        workerStatuses: {id: AttendanceStatus.present},
        overtimeHours: {id: 2},
      );
      var s = await repo.getPaymentSummary(id, projectId, day, day);
      expect(s.totalDaysWorked, 1);
      expect(s.totalOvertimeHours, 2);
      expect(s.totalOvertimeWages, 200);
      expect(s.totalEarnedWages, 1000);
      expect(s.amountDue, 1000);

      // Edit the same day: OT 2 -> 3.5
      await repo.saveBatchAttendance(
        projectId: projectId,
        date: day,
        workerStatuses: {id: AttendanceStatus.present},
        overtimeHours: {id: 3.5},
      );
      expect(await db.select(db.attendance).get(), hasLength(1));
      s = await repo.getPaymentSummary(id, projectId, day, day);
      expect(s.totalEarnedWages, 1150);

      // Pay in full -> nothing due (running balance, no double payment)
      await repo.recordPayment(
          projectId: projectId, workerId: id, date: day, amount: s.amountDue);
      s = await repo.getPaymentSummary(id, projectId, day, day);
      expect(s.amountDue, 0);
      expect(s.totalPaymentsPaid, 1150);
    });

    test('attendance saved without OT keeps behaving as before', () async {
      final id = await repo.addWorker(name: 'Raju', dailyRate: 800);
      await repo.markAttendance(
          workerId: id,
          projectId: projectId,
          date: day,
          status: AttendanceStatus.halfDay);
      final s = await repo.getPaymentSummary(id, projectId, day, day);
      expect(s.totalEarnedWages, 400);
      expect(s.totalOvertimeHours, 0);
    });
  });

  testWidgets('attendance grid: OT stepper and bulk OT update the estimate',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final id = await repo.addWorker(name: 'Raju', dailyRate: 800);
    expect(id, greaterThan(0));
    final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    container.read(attendanceProjectProvider.notifier).state = projectId;

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(1440, 900),
        builder: (context, _) => MaterialApp(
          theme: AppTheme.light,
          home: const AttendanceScreen(),
        ),
      ),
    ));
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No OT'), findsOneWidget);
    await tester.tap(find.text('All Present'));
    await tester.pump();
    await tester.tap(find.byTooltip('Add overtime (0.5 h)'));
    await tester.pump();
    await tester.tap(find.byTooltip('Add overtime (0.5 h)'));
    await tester.pump();
    expect(find.text('OT 1 h'), findsOneWidget);
    expect(find.text('1 hrs OT'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Bulk OT dialog
    await tester.tap(find.text('OT for All Present'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.descendant(
            of: find.byType(AlertDialog), matching: find.byType(TextField)),
        '2');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('OT 2 h'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
