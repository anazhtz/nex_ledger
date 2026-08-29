import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/features/auth/presentation/login_screen.dart';
import 'package:nex_ledger/features/bank_accounts/presentation/bank_accounts_screen.dart';
import 'package:nex_ledger/features/budgets/presentation/project_budget_variance_hub_screen.dart';
import 'package:nex_ledger/features/cash_book/presentation/cash_book_entry_form.dart';
import 'package:nex_ledger/features/cash_book/presentation/cash_book_list_screen.dart';
import 'package:nex_ledger/features/client_billing/presentation/client_billing_hub_screen.dart';
import 'package:nex_ledger/features/dashboard/presentation/dashboard_screen.dart';
import 'package:nex_ledger/features/dashboard/providers/dashboard_provider.dart';
import 'package:nex_ledger/features/deposits/presentation/deposit_entry_form.dart';
import 'package:nex_ledger/features/deposits/presentation/deposit_list_screen.dart';
import 'package:nex_ledger/features/equipment/presentation/equipment_hub_screen.dart';
import 'package:nex_ledger/features/labour/presentation/attendance_screen.dart';
import 'package:nex_ledger/features/labour/presentation/labour_payment_screen.dart';
import 'package:nex_ledger/features/labour/presentation/workers_list_screen.dart';
import 'package:nex_ledger/features/petty_cash/presentation/petty_cash_hub_screen.dart';
import 'package:nex_ledger/features/projects/presentation/project_form_screen.dart';
import 'package:nex_ledger/features/projects/presentation/project_list_screen.dart';
import 'package:nex_ledger/features/purchase/presentation/purchase_form_screen.dart';
import 'package:nex_ledger/features/purchase/presentation/purchase_list_screen.dart';
import 'package:nex_ledger/features/reports/presentation/day_book_screen.dart';
import 'package:nex_ledger/features/reports/presentation/deposit_ledger_screen.dart';
import 'package:nex_ledger/features/reports/presentation/ledgers_hub_screen.dart';
import 'package:nex_ledger/features/reports/presentation/project_pnl_screen.dart';
import 'package:nex_ledger/features/settings/presentation/settings_screen.dart';
import 'package:nex_ledger/features/subcontract/presentation/subcontract_hub_screen.dart';
import 'package:nex_ledger/shared/widgets/app_shell.dart';
import 'package:go_router/go_router.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
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

  group('UI Layout & Responsiveness Audit', () {
    testWidgets('DashboardScreen renders with 0 overflow', (tester) async {
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

    testWidgets('ProjectListScreen renders with 0 overflow', (tester) async {
      await tester.pumpWidget(createTestWidget(const ProjectListScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectListScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('CashBookListScreen renders with 0 overflow', (tester) async {
      await tester.pumpWidget(createTestWidget(const CashBookListScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(CashBookListScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('PurchaseListScreen renders with 0 overflow', (tester) async {
      await tester.pumpWidget(createTestWidget(const PurchaseListScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(PurchaseListScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AttendanceScreen renders with 0 overflow', (tester) async {
      await tester.pumpWidget(createTestWidget(const AttendanceScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(AttendanceScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('LabourPaymentScreen renders with 0 overflow', (tester) async {
      await tester.pumpWidget(createTestWidget(const LabourPaymentScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(LabourPaymentScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SubcontractHubScreen renders with 0 overflow', (tester) async {
      await tester.pumpWidget(createTestWidget(const SubcontractHubScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(SubcontractHubScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ClientBillingHubScreen renders with 0 overflow', (tester) async {
      await tester.pumpWidget(createTestWidget(const ClientBillingHubScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(ClientBillingHubScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ProjectBudgetVarianceHubScreen renders with 0 overflow', (tester) async {
      await tester.pumpWidget(createTestWidget(const ProjectBudgetVarianceHubScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectBudgetVarianceHubScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('EquipmentHubScreen renders with 0 overflow', (tester) async {
      await tester.pumpWidget(createTestWidget(const EquipmentHubScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(EquipmentHubScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('PettyCashHubScreen renders with 0 overflow', (tester) async {
      await tester.pumpWidget(createTestWidget(const PettyCashHubScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(PettyCashHubScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('LedgersHubScreen renders with 0 overflow', (tester) async {
      await tester.pumpWidget(createTestWidget(const LedgersHubScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(LedgersHubScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BankAccountsScreen renders with 0 overflow', (tester) async {
      await tester.pumpWidget(createTestWidget(const BankAccountsScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(BankAccountsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SettingsScreen renders with 0 overflow', (tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AppShell navigation shell renders cleanly on compact 800px width', (tester) async {
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
      await tester.pumpAndSettle();
      expect(find.text('Dashboard Content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
