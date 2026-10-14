import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/features/labour/data/labour_repository.dart';
import 'package:nex_ledger/features/labour/presentation/labour_payment_screen.dart';
import 'package:nex_ledger/shared/widgets/app_dropdown.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

void main() {
  late AppDatabase db;
  late int projectId;
  late int workerId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final repo = LabourRepository(db.labourDao, db.transactionDao);
    projectId = await db.projectDao.insertProject(ProjectsCompanion.insert(
      code: 'PRJ-1',
      name: 'Villa',
      type: ProjectType.project,
      status: ProjectStatus.active,
      startDate: DateTime(2026, 1, 1),
    ));
    workerId = await repo.addWorker(name: 'Raju', dailyRate: 1000);
    // 3 full days worked -> ₹3,000 earned
    for (var d = 1; d <= 3; d++) {
      await repo.markAttendance(
          workerId: workerId,
          projectId: projectId,
          date: DateTime(2026, 8, d),
          status: AttendanceStatus.present);
    }
  });

  tearDown(() async => db.close());

  Future<void> openAndCalculate(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
    addTearDown(container.dispose);
    container.read(selectedProjectIdProvider.notifier).state = projectId;
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(1440, 900),
        builder: (context, _) => MaterialApp(
          theme: AppTheme.light,
          home: const LabourPaymentScreen(),
        ),
      ),
    ));
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byType(AppDropdownField<int?>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Raju').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calculate'));
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
  }

  Finder amountField() =>
      find.widgetWithText(TextFormField, 'Amount to Pay Now (₹)');

  Future<void> confirmNegativeBalanceIfAsked(WidgetTester tester) async {
    if (find.text('Negative Balance Warning').evaluate().isNotEmpty) {
      await tester.tap(find.text('Proceed Anyway'));
      await tester.pumpAndSettle();
    }
  }

  testWidgets(
      'amount defaults to the full balance; a part payment leaves the rest due',
      (tester) async {
    await openAndCalculate(tester);

    expect(find.text('Record Payment of ₹3,000.00'), findsOneWidget,
        reason: 'full balance by default');

    await tester.enterText(amountField(), '1000');
    await tester.pump();
    expect(find.text('Record Payment of ₹1,000.00'), findsOneWidget);

    await tester.ensureVisible(find.text('Record Payment of ₹1,000.00'));
    await tester.tap(find.text('Record Payment of ₹1,000.00'));
    await tester.pumpAndSettle();
    await confirmNegativeBalanceIfAsked(tester);
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    final pays = await db.select(db.transactions).get();
    expect(pays, hasLength(1));
    expect(pays.single.amount, 1000);
    expect(pays.single.type, TransactionType.labourPayment);
    expect(pays.single.workerId, workerId);

    // Summary reloaded: ₹2,000 still due and pre-filled.
    final s = await LabourRepository(db.labourDao, db.transactionDao)
        .getPaymentSummary(
            workerId, projectId, DateTime(2026, 8, 1), DateTime(2026, 8, 31));
    expect(s.amountDue, 2000);
    expect(find.text('Record Payment of ₹2,000.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cannot pay more than is due, or zero', (tester) async {
    await openAndCalculate(tester);

    for (final bad in ['5000', '0', '']) {
      await tester.enterText(amountField(), bad);
      await tester.pump();
      final button = tester.widget<FilledButton>(find.ancestor(
          of: find.textContaining('Record Payment of'),
          matching: find.byWidgetPredicate((w) => w is FilledButton)));
      expect(button.onPressed, isNull,
          reason: '"$bad" must disable the button');
    }
    expect(await db.select(db.transactions).get(), isEmpty);

    // "Full" restores the whole balance
    await tester.tap(find.text('Full'));
    await tester.pump();
    expect(find.text('Record Payment of ₹3,000.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
