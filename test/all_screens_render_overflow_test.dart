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
import 'package:nex_ledger/features/settings/presentation/settings_screen.dart';
import 'package:nex_ledger/shared/widgets/app_shell.dart';

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

  group('All Screens Layout & Overflow Audit Tests (Desktop & Laptop Resizing)', () {
    testWidgets('DashboardScreen renders cleanly with 0 overflows', (tester) async {
      await tester.pumpWidget(createTestWidget(const DashboardScreen()));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('ProjectListScreen & ProjectFormScreen render cleanly', (tester) async {
      await tester.pumpWidget(createTestWidget(const ProjectListScreen()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectListScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      await tester.pumpWidget(createTestWidget(const ProjectFormScreen()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('CashBookListScreen & CashBookEntryForm render cleanly', (tester) async {
      await tester.pumpWidget(createTestWidget(const CashBookListScreen()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(CashBookListScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      await tester.pumpWidget(createTestWidget(const CashBookEntryForm()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(CashBookEntryForm), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('PurchaseListScreen & PurchaseFormScreen render cleanly', (tester) async {
      await tester.pumpWidget(createTestWidget(const PurchaseListScreen()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(PurchaseListScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      await tester.pumpWidget(createTestWidget(const PurchaseFormScreen()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(PurchaseFormScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('AttendanceScreen & LabourPaymentScreen render cleanly', (tester) async {
      await tester.pumpWidget(createTestWidget(const AttendanceScreen()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(AttendanceScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      await tester.pumpWidget(createTestWidget(const LabourPaymentScreen()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(LabourPaymentScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('DepositListScreen & DepositEntryForm render cleanly', (tester) async {
      await tester.pumpWidget(createTestWidget(const DepositListScreen()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(DepositListScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      await tester.pumpWidget(createTestWidget(const DepositEntryForm()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(DepositEntryForm), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('Reports (Project PnL, Deposit Ledger, Day Book) render cleanly', (tester) async {
      await tester.pumpWidget(createTestWidget(const ProjectPnlScreen()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectPnlScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      await tester.pumpWidget(createTestWidget(const DepositLedgerScreen()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(DepositLedgerScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      await tester.pumpWidget(createTestWidget(const DayBookScreen()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(DayBookScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('BankAccountsScreen & SettingsScreen render cleanly', (tester) async {
      await tester.pumpWidget(createTestWidget(const BankAccountsScreen()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(BankAccountsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('AppShell navigation shell renders cleanly on narrow 850px width', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AppShell(child: Center(child: Text('Dashboard Content'))),
        size: const Size(850, 600),
      ));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Dashboard Content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
