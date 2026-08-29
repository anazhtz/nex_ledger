import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/features/bank_accounts/presentation/bank_accounts_screen.dart';
import 'package:nex_ledger/features/budgets/presentation/project_budget_variance_hub_screen.dart';
import 'package:nex_ledger/features/cash_book/presentation/cash_book_entry_form.dart';
import 'package:nex_ledger/features/cash_book/presentation/cash_book_list_screen.dart';
import 'package:nex_ledger/features/client_billing/presentation/client_billing_hub_screen.dart';
import 'package:nex_ledger/features/dashboard/presentation/dashboard_screen.dart';
import 'package:nex_ledger/features/deposits/presentation/deposit_list_screen.dart';
import 'package:nex_ledger/features/equipment/presentation/equipment_hub_screen.dart';
import 'package:nex_ledger/features/labour/presentation/attendance_screen.dart';
import 'package:nex_ledger/features/labour/presentation/labour_payment_screen.dart';
import 'package:nex_ledger/features/petty_cash/presentation/petty_cash_hub_screen.dart';
import 'package:nex_ledger/features/projects/presentation/project_list_screen.dart';
import 'package:nex_ledger/features/purchase/presentation/purchase_form_screen.dart';
import 'package:nex_ledger/features/purchase/presentation/purchase_list_screen.dart';
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

  Future<void> testScreen(WidgetTester tester, Widget screen) async {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
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
            home: SizedBox(
              width: 1280,
              height: 800,
              child: screen,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byWidget(screen), findsOneWidget);
    expect(tester.takeException(), isNull);
  }

  group('UI Layout & Responsiveness Audit across All Screens', () {
    testWidgets('DashboardScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const DashboardScreen());
    });

    testWidgets('ProjectListScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const ProjectListScreen());
    });

    testWidgets('CashBookListScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const CashBookListScreen());
    });

    testWidgets('PurchaseListScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const PurchaseListScreen());
    });

    testWidgets('PurchaseFormScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const PurchaseFormScreen());
    });

    testWidgets('AttendanceScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const AttendanceScreen());
    });

    testWidgets('LabourPaymentScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const LabourPaymentScreen());
    });

    testWidgets('SubcontractHubScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const SubcontractHubScreen());
    });

    testWidgets('ClientBillingHubScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const ClientBillingHubScreen());
    });

    testWidgets('ProjectBudgetVarianceHubScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const ProjectBudgetVarianceHubScreen());
    });

    testWidgets('EquipmentHubScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const EquipmentHubScreen());
    });

    testWidgets('PettyCashHubScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const PettyCashHubScreen());
    });

    testWidgets('LedgersHubScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const LedgersHubScreen());
    });

    testWidgets('DepositListScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const DepositListScreen());
    });

    testWidgets('ProjectPnlScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const ProjectPnlScreen());
    });

    testWidgets('BankAccountsScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const BankAccountsScreen());
    });

    testWidgets('SettingsScreen renders with 0 overflow', (tester) async {
      await testScreen(tester, const SettingsScreen());
    });
  });
}
