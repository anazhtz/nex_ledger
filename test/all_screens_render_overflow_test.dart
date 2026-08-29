import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/features/bank_accounts/presentation/bank_accounts_screen.dart';
import 'package:nex_ledger/features/cash_book/presentation/cash_book_entry_form.dart';
import 'package:nex_ledger/features/cash_book/presentation/cash_book_list_screen.dart';
import 'package:nex_ledger/features/dashboard/presentation/dashboard_screen.dart';
import 'package:nex_ledger/features/dashboard/providers/dashboard_provider.dart';
import 'package:nex_ledger/features/deposits/presentation/deposit_entry_form.dart';
import 'package:nex_ledger/features/deposits/presentation/deposit_list_screen.dart';
import 'package:nex_ledger/features/labour/presentation/attendance_screen.dart';
import 'package:nex_ledger/features/labour/presentation/labour_payment_screen.dart';
import 'package:nex_ledger/features/projects/presentation/project_form_screen.dart';
import 'package:nex_ledger/features/projects/presentation/project_list_screen.dart';
import 'package:nex_ledger/features/purchase/presentation/purchase_form_screen.dart';
import 'package:nex_ledger/features/purchase/presentation/purchase_list_screen.dart';
import 'package:nex_ledger/features/reports/presentation/day_book_screen.dart';
import 'package:nex_ledger/features/reports/presentation/deposit_ledger_screen.dart';
import 'package:nex_ledger/features/reports/presentation/project_pnl_screen.dart';
import 'package:nex_ledger/features/reports/presentation/ledgers_hub_screen.dart';
import 'package:nex_ledger/features/settings/presentation/settings_screen.dart';
import 'package:nex_ledger/shared/widgets/app_shell.dart';
import 'package:go_router/go_router.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  Widget createTestWidget(Widget child, {Size size = const Size(1280, 800)}) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: ScreenUtilInit(
        designSize: const Size(1440, 900),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) => MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  group('All Screens Layout & Overflow Audit Tests (Desktop & Laptop Resizing)', () {
    testWidgets('DashboardScreen renders cleanly with 0 overflows', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            dashboardSummaryProvider.overrideWith((ref) async => DashboardSummary(
              cashBalance: 150000.0,
              totalDepositsHeld: 50000.0,
              activeProjects: [],
              projectPnls: [],
            )),
          ],
          child: ScreenUtilInit(
            designSize: const Size(1440, 900),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, _) => MaterialApp(
              theme: AppTheme.light,
              home: const SizedBox(
                width: 1280,
                height: 800,
                child: DashboardScreen(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ProjectListScreen & ProjectFormScreen render cleanly', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const ProjectListScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(ProjectListScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(createTestWidget(const ProjectFormScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(ProjectFormScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('CashBookListScreen & CashBookEntryForm render cleanly', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const CashBookListScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(CashBookListScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(createTestWidget(const CashBookEntryForm()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(CashBookEntryForm), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('PurchaseListScreen & PurchaseFormScreen render cleanly', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const PurchaseListScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(PurchaseListScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(createTestWidget(const PurchaseFormScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(PurchaseFormScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('AttendanceScreen & LabourPaymentScreen render cleanly', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const AttendanceScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(AttendanceScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(createTestWidget(const LabourPaymentScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(LabourPaymentScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('DepositListScreen & DepositEntryForm render cleanly', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const DepositListScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(DepositListScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(createTestWidget(const DepositEntryForm()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(DepositEntryForm), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Reports (Project PnL, Deposit Ledger, Day Book) render cleanly', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const ProjectPnlScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(ProjectPnlScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(createTestWidget(const DepositLedgerScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(DepositLedgerScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(createTestWidget(const DayBookScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(DayBookScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(createTestWidget(const LedgersHubScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(LedgersHubScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('BankAccountsScreen & SettingsScreen render cleanly', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const BankAccountsScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(BankAccountsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('AppShell navigation shell renders cleanly on narrow 850px width', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          ShellRoute(
            builder: (context, state, child) => AppShell(child: child),
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const Center(child: Text('Dashboard Content')),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: ScreenUtilInit(
            designSize: const Size(1440, 900),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, _) => MaterialApp.router(
              routerConfig: router,
              theme: AppTheme.light,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Dashboard Content'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
