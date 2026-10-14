import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';
import 'package:nex_ledger/features/reports/presentation/purchase_register_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<void> seed() async {
    final repo = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
    Future<int> project(String code) =>
        db.projectDao.insertProject(ProjectsCompanion.insert(
            code: code,
            name: 'Site $code',
            type: ProjectType.project,
            status: ProjectStatus.active,
            startDate: DateTime(2026, 1, 1)));
    final a = await project('PRJ-A');
    final b = await project('PRJ-B');
    final x = await db.purchaseDao
        .insertVendor(VendorsCompanion.insert(name: 'Ganesh Traders'));
    final y = await db.purchaseDao
        .insertVendor(VendorsCompanion.insert(name: 'Anil Steels'));
    Future<void> buy(int p, int v, DateTime d, double amt, PaymentStatus s,
            {double paid = 0}) =>
        repo.addPurchase(
            projectId: p,
            vendorId: v,
            date: d,
            itemDescription: 'Item ${amt.toInt()}',
            amount: amt,
            paymentStatus: s,
            paidAmount: paid);
    await buy(a, x, DateTime(2026, 4, 10), 10000, PaymentStatus.paid);
    await buy(a, y, DateTime(2026, 5, 5), 20000, PaymentStatus.pending);
    await buy(b, x, DateTime(2026, 5, 20), 30000, PaymentStatus.partial,
        paid: 12000);
    await buy(b, x, DateTime(2026, 6, 1), 5000, PaymentStatus.paid);
  }

  Future<void> pump(WidgetTester tester, Widget screen,
      {Size size = const Size(1366, 900)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(1440, 900),
        builder: (context, _) =>
            MaterialApp(theme: AppTheme.light, home: screen),
      ),
    ));
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('shows every bill and correct totals', (tester) async {
    await seed();
    await pump(tester, const PurchaseRegisterScreen());
    expect(find.text('Purchase Register'), findsOneWidget);
    expect(find.text('Purchase Bills (4)'), findsOneWidget);
    expect(find.text('₹65,000.00'), findsWidgets); // total purchased
    expect(find.text('₹27,000.00'), findsWidgets); // paid
    expect(find.text('₹38,000.00'), findsWidgets); // balance
    expect(find.text('Ganesh Traders'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('payment filter narrows bills and totals, Clear filters restores',
      (tester) async {
    await seed();
    await pump(tester, const PurchaseRegisterScreen());

    await tester.tap(find.byKey(const ValueKey('status-null')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pending').last);
    await tester.pumpAndSettle();

    expect(find.text('Purchase Bills (1)'), findsOneWidget);
    expect(find.text('Anil Steels'), findsOneWidget);
    expect(find.text('Ganesh Traders'), findsNothing);
    expect(find.text('₹20,000.00'), findsWidgets);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('Purchase Bills (4)'), findsOneWidget);
    expect(find.text('Clear filters'), findsNothing);
  });

  testWidgets('project filter and period menu work together', (tester) async {
    await seed();
    await pump(tester, const PurchaseRegisterScreen());

    await tester.tap(find.byKey(const ValueKey('project-null')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('PRJ-B').last);
    await tester.pumpAndSettle();
    expect(find.text('Purchase Bills (2)'), findsOneWidget);

    // Period menu offers the Indian financial year
    await tester.tap(find.text('All time'));
    await tester.pumpAndSettle();
    expect(find.text('This financial year (Apr–Mar)'), findsOneWidget);
    await tester.tap(find.text('This month'));
    await tester.pumpAndSettle();
    // none of the seeded 2026 bills fall in the current month
    expect(find.text('Purchase Bills (0)'), findsOneWidget);
    expect(find.text('No purchases match these filters.'), findsOneWidget);
  });

  testWidgets('By Shop view groups bills; clicking a shop shows its bills',
      (tester) async {
    await seed();
    await pump(tester, const PurchaseRegisterScreen());

    await tester.tap(find.text('By Shop'));
    await tester.pumpAndSettle();
    expect(find.text('Shops (2)'), findsOneWidget);
    expect(find.text('₹45,000.00'), findsWidgets); // Ganesh total
    expect(find.text('₹18,000.00'), findsWidgets); // Ganesh balance

    await tester.tap(find.text('Anil Steels'));
    await tester.pumpAndSettle();
    expect(find.text('Purchase Bills (1)'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);
  });

  testWidgets('shop-wise entry opens directly on the By Shop view',
      (tester) async {
    await seed();
    await pump(tester, const PurchaseRegisterScreen(byShop: true));
    expect(find.text('Shop-wise Purchases'), findsOneWidget);
    expect(find.text('Shops (2)'), findsOneWidget);
  });

  testWidgets('empty database: friendly message and Export disabled',
      (tester) async {
    await pump(tester, const PurchaseRegisterScreen());
    expect(find.text('No purchases recorded yet.'), findsOneWidget);
    final export = tester.widget<FilledButton>(find.ancestor(
        of: find.textContaining('Export Excel'),
        matching: find.byWidgetPredicate((w) => w is FilledButton)));
    expect(export.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(1024, 700), Size(1280, 800)]) {
    testWidgets(
        'fits at ${size.width.toInt()}x${size.height.toInt()} in both views',
        (tester) async {
      await seed();
      await pump(tester, const PurchaseRegisterScreen(), size: size);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('By Shop'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
