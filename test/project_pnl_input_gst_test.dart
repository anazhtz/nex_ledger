import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/features/cash_book/data/cash_book_repository.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/purchase/data/purchase_invoice_repository.dart';
import 'package:nex_ledger/features/reports/presentation/project_pnl_screen.dart';

void main() {
  late AppDatabase db;
  late int project, other;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    Future<int> mk(String code) =>
        db.projectDao.insertProject(ProjectsCompanion.insert(
            code: code,
            name: 'Site $code',
            type: ProjectType.project,
            status: ProjectStatus.active,
            startDate: DateTime(2026, 1, 1)));
    project = await mk('PRJ-A');
    other = await mk('PRJ-B');
  });
  tearDown(() async => db.close());

  Future<void> pump(WidgetTester tester, int selected) async {
    tester.view.physicalSize = const Size(1500, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    container.read(selectedProjectIdProvider.notifier).state = selected;
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(1440, 900),
        builder: (context, _) =>
            MaterialApp(theme: AppTheme.light, home: const ProjectPnlScreen()),
      ),
    ));
    for (var i = 0; i < 5; i++) {
      await tester
          .runAsync(() => Future.delayed(const Duration(milliseconds: 60)));
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  const label = 'Input GST inside the costs above (information only)';

  testWidgets(
      'P&L shows the input GST inside the costs, and the totals do not change',
      (tester) async {
    await CashBookRepository(db.transactionDao).addIncome(
        projectId: project, date: DateTime(2026, 9, 1), amount: 100000);
    final shop = await db.purchaseDao
        .insertVendor(VendorsCompanion.insert(name: 'Ganesh'));
    await PurchaseInvoiceRepository(db).createInvoice(PurchaseInvoiceDraft(
      date: DateTime(2026, 9, 5), vendorId: shop, projectId: project,
      lines: const [
        InvoiceLineDraft(item: 'Steel', qty: 100, rate: 100, gstRate: 18)
      ], // 10,000 + 1,800 = 11,800
    ));
    await pump(tester, project);
    expect(find.text(label), findsOneWidget);
    expect(find.text('₹1,800.00'), findsWidgets);
    // profit is untouched: income 1,00,000 - purchases 11,800 = 88,200
    expect(find.text('₹88,200.00'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no GST in the project: no extra line', (tester) async {
    await CashBookRepository(db.transactionDao).addExpense(
        projectId: project, date: DateTime(2026, 9, 1), amount: 500);
    await pump(tester, project);
    expect(find.text(label), findsNothing);
  });

  testWidgets("another project's GST is not shown here", (tester) async {
    final shop = await db.purchaseDao
        .insertVendor(VendorsCompanion.insert(name: 'Ganesh'));
    await PurchaseInvoiceRepository(db).createInvoice(PurchaseInvoiceDraft(
      date: DateTime(2026, 9, 5),
      vendorId: shop,
      projectId: other,
      lines: const [
        InvoiceLineDraft(item: 'Steel', qty: 100, rate: 100, gstRate: 18)
      ],
    ));
    await CashBookRepository(db.transactionDao).addExpense(
        projectId: project, date: DateTime(2026, 9, 1), amount: 500);
    await pump(tester, project);
    expect(find.text(label), findsNothing);
  });
}
