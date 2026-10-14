import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/core/utils/gst_utils.dart';
import 'package:nex_ledger/features/cash_book/data/cash_book_repository.dart';
import 'package:nex_ledger/features/cash_book/presentation/cash_book_entry_form.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/subcontract/data/subcontract_repository.dart';
import 'package:nex_ledger/features/subcontract/presentation/measurement_bill_form_screen.dart';

String gstin(String first14) => first14 + GstUtils.checkCharacter(first14);

void main() {
  late AppDatabase db;
  late int project;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    project = await db.projectDao.insertProject(ProjectsCompanion.insert(
        code: 'PRJ-A',
        name: 'Malabar Tower',
        type: ProjectType.project,
        status: ProjectStatus.active,
        startDate: DateTime(2026, 1, 1)));
    await db.setSetting(
        AppDatabase.settingCompanyGstin, gstin('32AABFS1234A1Z')); // Kerala
  });

  tearDown(() async => db.close());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester
          .runAsync(() => Future.delayed(const Duration(milliseconds: 60)));
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pumpApp(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1400, 1300);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    container.read(selectedProjectIdProvider.notifier).state = project;
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => screen),
      GoRoute(
          path: '/cash-book',
          builder: (_, __) => const Scaffold(body: Text('CASH BOOK LIST'))),
      GoRoute(
          path: '/subcontracts',
          builder: (_, __) => const Scaffold(body: Text('SUBCONTRACTS'))),
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(1440, 900),
        builder: (context, _) =>
            MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    ));
    await settle(tester);
  }

  /// Taps a save button; if the form asks about a negative balance, proceeds.
  Future<void> saveAndConfirm(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pump(const Duration(milliseconds: 400));
    if (find.text('Proceed Anyway').evaluate().isNotEmpty) {
      await tester.tap(find.text('Proceed Anyway'));
    }
    await settle(tester);
  }

  Future<void> pickRate(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.byKey(const Key('gst_rate')));
    await tester.tap(find.byKey(const Key('gst_rate')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text(label).last);
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('Cash Book expense form', () {
    testWidgets('GST is off by default and the amount is saved as typed',
        (tester) async {
      await pumpApp(tester, const CashBookEntryForm());
      expect(find.text('This expense has GST'), findsOneWidget);
      expect(find.text('Total with GST'), findsNothing);
      await tester.enterText(find.byKey(const Key('cb_amount')), '5000');
      await saveAndConfirm(tester, 'Save Cash Book Entry');
      final t = (await db.select(db.transactions).get()).single;
      expect(t.amount, 5000);
      expect(await db.select(db.transactionGsts).get(), isEmpty);
    });

    testWidgets(
        'GST on: shows tax and total live, saves value + GST with the details',
        (tester) async {
      await pumpApp(tester, const CashBookEntryForm());
      await tester.enterText(find.byKey(const Key('cb_amount')), '10000');
      await tester.ensureVisible(find.byKey(const Key('gst_switch')));
      await tester.tap(find.byKey(const Key('gst_switch')));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Amount before GST (₹) *'), findsOneWidget);
      expect(find.text('₹11,800.00'),
          findsOneWidget); // total with 18% (the default rate)
      expect(find.text('₹900.00'), findsNWidgets(2)); // CGST and SGST

      await pickRate(tester, '12%');
      expect(find.text('₹11,200.00'), findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('gst_party')), 'Sri Hardware');
      await saveAndConfirm(tester, 'Save Cash Book Entry');

      final t = (await db.select(db.transactions).get()).single;
      expect(t.amount, 11200);
      final g = (await db.select(db.transactionGsts).get()).single;
      expect(
          [g.taxableAmount, g.gstRate, g.cgstAmount, g.sgstAmount, g.partyName],
          [10000, 12, 600, 600, 'Sri Hardware']);
      expect(find.text('CASH BOOK LIST'), findsOneWidget);
    });

    testWidgets("a party GSTIN from another state switches to IGST by itself",
        (tester) async {
      await pumpApp(tester, const CashBookEntryForm());
      await tester.enterText(find.byKey(const Key('cb_amount')), '10000');
      await tester.ensureVisible(find.byKey(const Key('gst_switch')));
      await tester.tap(find.byKey(const Key('gst_switch')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('CGST @'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('gst_gstin')),
          gstin('33AAAAA0000A1Z')); // Tamil Nadu
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('IGST @'), findsOneWidget);
      expect(find.textContaining('CGST @'), findsNothing);
      expect(find.text('₹1,800.00'), findsOneWidget);

      await saveAndConfirm(tester, 'Save Cash Book Entry');
      final g = (await db.select(db.transactionGsts).get()).single;
      expect([g.cgstAmount, g.sgstAmount, g.igstAmount, g.isInterState],
          [0, 0, 1800, true]);
    });

    testWidgets(
        'editing an expense with GST shows the value before GST and keeps it editable',
        (tester) async {
      await CashBookRepository(db.transactionDao).addExpense(
          projectId: project,
          date: DateTime(2026, 9, 1),
          amount: 10000,
          gst: const ExpenseGstInput(rate: 18, partyName: 'Sri Hardware'));
      final id = (await db.select(db.transactions).get()).single.id;
      expect((await db.select(db.transactions).get()).single.amount, 11800);

      await pumpApp(tester, CashBookEntryForm(transactionId: id));
      await settle(tester);
      expect(
          tester
              .widget<TextFormField>(find.byKey(const Key('cb_amount')))
              .controller!
              .text,
          '10000');
      expect(tester.widget<Switch>(find.byKey(const Key('gst_switch'))).value,
          isTrue);
      expect(find.text('₹11,800.00'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('cb_amount')), '20000');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('₹23,600.00'), findsOneWidget);
      await saveAndConfirm(tester, 'Update Entry');
      expect((await db.select(db.transactions).get()).single.amount, 23600);
      expect((await db.select(db.transactionGsts).get()).single.taxableAmount,
          20000);
    });

    testWidgets('income entries have no GST option', (tester) async {
      await pumpApp(tester, const CashBookEntryForm());
      await tester.tap(find.text('Income (+)'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('This expense has GST'), findsNothing);
    });
  });

  group('Subcontract measurement bill form', () {
    late int woId, subId;

    setUp(() async {
      final sub =
          SubcontractRepository(db.subcontractDao, db.transactionDao, db);
      subId = await sub.addSubcontractor(
          name: 'Murugan Gang',
          trade: 'Plastering',
          contact: '9840123456',
          panOrGst: gstin('33AAAAA0000A1Z'));
      woId = await sub.createWorkOrder(
          orderNumber: 'WO-1',
          projectId: project,
          subcontractorId: subId,
          title: 'Plastering',
          trade: 'Plastering',
          unit: 'Sq.ft',
          agreedRate: 50,
          estimatedQuantity: 5000,
          retentionPercentage: 5,
          startDate: DateTime(2026, 8, 1));
    });

    testWidgets('without GST: the bill is exactly as before', (tester) async {
      await pumpApp(
          tester, MeasurementBillFormScreen(initialWorkOrderId: woId));
      await settle(tester);
      expect(find.text('This bill has GST'), findsOneWidget);
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Measured Qty for this Bill *'),
          '1000');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Net Billable Amount (Payable):'), findsOneWidget);
      await tester.ensureVisible(find.text('Certify & Save (Ctrl+Enter)'));
      await tester.tap(find.text('Certify & Save (Ctrl+Enter)'));
      await settle(tester);
      final b = (await db.select(db.measurementBills).get()).single;
      expect([b.grossAmount, b.netAmount, b.gstRate], [50000, 47500, 0]);
    });

    testWidgets(
        "with GST: preview adds it to the payable, retention stays on the bill value, subcontractor's GSTIN fills in",
        (tester) async {
      await pumpApp(
          tester, MeasurementBillFormScreen(initialWorkOrderId: woId));
      await settle(tester);
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Measured Qty for this Bill *'),
          '1000');
      await tester.ensureVisible(find.byKey(const Key('gst_switch')));
      await tester.tap(find.byKey(const Key('gst_switch')));
      await tester.pump(const Duration(milliseconds: 400));

      // the subcontractor's saved GSTIN is already there, and it is another state -> IGST
      expect(
          tester
              .widget<TextField>(find.byKey(const Key('gst_gstin')))
              .controller!
              .text,
          gstin('33AAAAA0000A1Z'));
      expect(
          tester
              .widget<TextField>(find.byKey(const Key('gst_party')))
              .controller!
              .text,
          'Murugan Gang');
      expect(find.textContaining('IGST @'), findsOneWidget);

      expect(find.text('Net Payable (incl. GST):'), findsOneWidget);
      expect(find.text('₹56,500.00'),
          findsOneWidget); // 50,000 - 2,500 retention + 9,000 GST
      expect(find.text('+ ₹9,000.00'), findsOneWidget);

      await tester.ensureVisible(find.text('Certify & Save (Ctrl+Enter)'));
      await tester.tap(find.text('Certify & Save (Ctrl+Enter)'));
      await settle(tester);

      final b = (await db.select(db.measurementBills).get()).single;
      expect([
        b.grossAmount,
        b.retentionAmount,
        b.igstAmount,
        b.cgstAmount,
        b.netAmount,
        b.isInterState
      ], [
        50000,
        2500,
        9000,
        0,
        56500,
        true
      ]);
      expect(b.partyGstin, gstin('33AAAAA0000A1Z'));
      final t = (await db.select(db.transactions).get()).single;
      expect([t.amount, t.type], [59000, TransactionType.subcontractBill]);
      expect(find.text('SUBCONTRACTS'), findsOneWidget);
    });
  });
}
