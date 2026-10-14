import 'dart:io';
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
import 'package:nex_ledger/features/reports/presentation/reports_center_screen.dart';
import 'package:nex_ledger/features/reports/providers/ledger_providers.dart';
import 'package:nex_ledger/shared/widgets/app_shell.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  group('Reports Center data', () {
    test('search finds reports by plain words, not just titles', () {
      List<String> titles(String q) => [
            for (final g in filterReportGroups(q))
              for (final e in g.entries) e.title,
          ];
      expect(titles('shop'), contains('Shop / Supplier Ledger'));
      expect(titles('rent'), contains('Machinery & Rental'));
      expect(titles('stock'), contains('Material Register'));
      expect(titles('contractor'), contains('Contractor Ledger'));
      expect(titles('investor'), contains('Investor / Owner Ledger'));
      expect(titles('PROFIT'), contains('Project P&L'));
      expect(titles('zzzz'), isEmpty);
      expect(
          titles('  '),
          hasLength(
              kReportGroups.fold<int>(0, (n, g) => n + g.entries.length)));
    });

    test('every report points to a real route', () {
      final routes = File('lib/app.dart').readAsStringSync();
      for (final g in kReportGroups) {
        for (final e in g.entries) {
          expect(routes.contains("path: '${e.route}'"), isTrue,
              reason: '${e.title} -> ${e.route} is not a route in app.dart');
        }
      }
    });

    test('each report has a title and a plain description', () {
      for (final g in kReportGroups) {
        for (final e in g.entries) {
          expect(e.title.trim(), isNotEmpty);
          expect(e.description.trim().length, greaterThan(15), reason: e.title);
        }
      }
    });
  });

  Future<ProviderContainer> pumpApp(WidgetTester tester, String initialLocation,
      {Size size = const Size(1440, 900)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);

    Widget page(String name) =>
        Scaffold(body: Center(child: Text('PAGE:$name')));
    final router = GoRouter(initialLocation: initialLocation, routes: [
      ShellRoute(
        builder: (c, s, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => page('dashboard')),
          GoRoute(path: '/purchases', builder: (_, __) => page('purchases')),
          GoRoute(path: '/vendors/:id', builder: (_, __) => page('vendor')),
          GoRoute(path: '/projects', builder: (_, __) => page('projects')),
          GoRoute(path: '/ledgers', builder: (_, __) => page('ledgers')),
          GoRoute(
              path: '/reports',
              builder: (_, __) => const ReportsCenterScreen()),
          GoRoute(
              path: '/reports/day-book', builder: (_, __) => page('daybook')),
          GoRoute(path: '/equipment', builder: (_, __) => page('equipment')),
        ],
      ),
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(1440, 900),
        builder: (context, _) => MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ),
      ),
    ));
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 150)));
    await tester.pump(const Duration(milliseconds: 100));
    return container;
  }

  group('Sidebar', () {
    testWidgets('groups by task; only the active group is open',
        (tester) async {
      await pumpApp(tester, '/');
      for (final h in [
        'SITES',
        'BUY & STOCK',
        'LABOUR & SUBCONTRACT',
        'MONEY'
      ]) {
        expect(find.text(h), findsOneWidget, reason: h);
      }
      // single-item groups have no header, but their item is visible
      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Reports Center'), findsOneWidget);
      expect(find.text('Settings & Backup'), findsOneWidget);
      expect(find.text('HOME'), findsNothing);
      expect(find.text('REPORTS'), findsNothing);
      // old scattered report entries are gone from the sidebar
      expect(find.text('Daily Day-Book'), findsNothing);
      expect(find.text('All Ledgers'), findsNothing);
      // other groups are folded away on the dashboard
      expect(find.text('Purchases'), findsNothing);
      expect(find.text('Cash Book'), findsNothing);
    });

    testWidgets('clicking a group header opens and closes it', (tester) async {
      await pumpApp(tester, '/');
      await tester.tap(find.text('BUY & STOCK'));
      await tester.pumpAndSettle();
      expect(find.text('Purchases'), findsOneWidget);
      expect(find.text('Materials & Stock'), findsOneWidget);
      expect(find.text('Machinery & Rental'), findsOneWidget);

      await tester.tap(find.text('BUY & STOCK'));
      await tester.pumpAndSettle();
      expect(find.text('Purchases'), findsNothing);
    });

    testWidgets('opens the group of the page you are on, incl. sub-pages',
        (tester) async {
      await pumpApp(tester, '/vendors/7'); // vendor page belongs to Purchases
      expect(find.text('Purchases'), findsOneWidget);
      expect(find.text('Materials & Stock'), findsOneWidget);
    });

    testWidgets('navigating by tapping an item opens its group',
        (tester) async {
      await pumpApp(tester, '/');
      await tester.tap(find.text('SITES'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();
      expect(find.text('PAGE:projects'), findsOneWidget);
      expect(find.text('Project Budgets'), findsOneWidget);
    });
  });

  group('Reports Center screen', () {
    testWidgets('lists every group and filters as you type', (tester) async {
      await pumpApp(tester, '/reports');
      expect(find.text('Reports Center'), findsWidgets);
      expect(find.text('Purchases & Shops'), findsOneWidget);
      expect(find.text('Machinery & Rental'), findsWidgets);

      await tester.enterText(find.byType(TextField), 'rent');
      await tester.pumpAndSettle();
      expect(find.text('Machinery & Rental'), findsWidgets);
      expect(find.text('Purchases & Shops'), findsNothing);

      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pumpAndSettle();
      expect(find.textContaining('No report matches'), findsOneWidget);
    });

    testWidgets('a ledger report opens the Ledgers page on the right tab',
        (tester) async {
      final container = await pumpApp(tester, '/reports');
      await tester.ensureVisible(find.text('Contractor Ledger'));
      await tester.tap(find.text('Contractor Ledger'));
      await tester.pumpAndSettle();
      expect(find.text('PAGE:ledgers'), findsOneWidget);
      expect(container.read(activeLedgerTabProvider), LedgerType.subcontractor);
      // and the sidebar keeps "Reports Center" selected for /ledgers
      expect(find.text('Reports Center'), findsOneWidget);
    });

    testWidgets('a plain report just navigates', (tester) async {
      await pumpApp(tester, '/reports');
      await tester.ensureVisible(find.text('Daily Day-Book'));
      await tester.tap(find.text('Daily Day-Book'));
      await tester.pumpAndSettle();
      expect(find.text('PAGE:daybook'), findsOneWidget);
    });
  });

  group('Small windows', () {
    testWidgets('Reports Center fits at the minimum window size',
        (tester) async {
      await pumpApp(tester, '/reports', size: const Size(1024, 700));
      expect(find.text('Project P&L'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('icon-only sidebar (<900px) shows every destination',
        (tester) async {
      await pumpApp(tester, '/', size: const Size(800, 700));
      // headers are hidden, all icons are reachable
      expect(find.text('SITES'), findsNothing);
      for (final tip in [
        'Purchases',
        'Reports Center',
        'Cash Book',
        'Attendance'
      ]) {
        expect(find.byTooltip(tip), findsOneWidget, reason: tip);
      }
      expect(tester.takeException(), isNull);
    });
  });
}
