import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/features/purchase/data/purchase_invoice_repository.dart';
import 'package:nex_ledger/features/reports/presentation/gst_register_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<void> seed() async {
    final repo = PurchaseInvoiceRepository(db);
    Future<int> project(String code) =>
        db.projectDao.insertProject(ProjectsCompanion.insert(
            code: code,
            name: 'Site $code',
            type: ProjectType.project,
            status: ProjectStatus.active,
            startDate: DateTime(2026, 1, 1)));
    final a = await project('PRJ-A');
    final b = await project('PRJ-B');
    final kerala = await db.purchaseDao.insertVendor(VendorsCompanion.insert(
        name: 'Ganesh Traders', gstin: const Value('32AAAAA0000A1Z5')));
    final tamil = await db.purchaseDao.insertVendor(VendorsCompanion.insert(
        name: 'Chennai Steels', gstin: const Value('33AAAAA0000A1Z5')));
    await repo.createInvoice(PurchaseInvoiceDraft(
      date: DateTime(2026, 9, 5),
      invoiceNo: 'K-101',
      vendorId: kerala,
      projectId: a,
      supplierGstin: '32AAAAA0000A1Z5',
      lines: const [
        InvoiceLineDraft(
            item: 'TMT Steel',
            hsn: '72142010',
            qty: 2500,
            rate: 62,
            gstRate: 18),
        InvoiceLineDraft(item: 'M Sand', qty: 15, rate: 60, gstRate: 5),
      ],
      freight: 3000,
    ));
    await repo.createInvoice(PurchaseInvoiceDraft(
      date: DateTime(2026, 10, 10),
      invoiceNo: 'T-77',
      vendorId: tamil,
      projectId: b,
      supplierGstin: '33AAAAA0000A1Z5',
      interState: true,
      lines: const [
        InvoiceLineDraft(item: 'TMT Steel', qty: 100, rate: 100, gstRate: 18)
      ],
    ));
    await repo.createInvoice(PurchaseInvoiceDraft(
      date: DateTime(2026, 11, 2),
      invoiceNo: 'K-102',
      vendorId: kerala,
      projectId: a,
      supplierGstin: '32AAAAA0000A1Z5',
      lines: const [
        InvoiceLineDraft(item: 'Cement', qty: 10, rate: 400, gstRate: 5)
      ],
    ));
  }

  Future<void> pump(WidgetTester tester,
      {Size size = const Size(1500, 900)}) async {
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
            MaterialApp(theme: AppTheme.light, home: const GstRegisterScreen()),
      ),
    ));
    for (var i = 0; i < 4; i++) {
      await tester
          .runAsync(() => Future.delayed(const Duration(milliseconds: 60)));
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('lists every GST invoice with correct totals', (tester) async {
    await seed();
    await pump(tester);
    expect(find.text('GST Purchase Register'), findsOneWidget);
    expect(find.text('GST Invoices (3)'), findsOneWidget);
    expect(find.textContaining('PUR/'), findsNWidgets(3));
    expect(find.text('₹1,69,900.00'), findsWidgets); // taxable value
    expect(find.text('₹29,945.00'), findsWidgets); // total GST
    expect(find.text('₹2,02,845.00'), findsWidgets); // invoice total
    expect(find.textContaining('CGST ₹14,072.50'), findsOneWidget);
    expect(find.textContaining('IGST ₹1,800.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'project filter narrows invoices and totals; Clear filters restores',
      (tester) async {
    await seed();
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('gst-project-null')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.textContaining('PRJ-B').last);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('GST Invoices (1)'), findsOneWidget);
    expect(find.text('₹11,800.00'), findsWidgets);
    expect(find.text('Chennai Steels'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('GST Invoices (3)'), findsOneWidget);
  });

  testWidgets('By GST Rate groups items, By Supplier groups invoices',
      (tester) async {
    await seed();
    await pump(tester);

    await tester.tap(find.text('By GST Rate'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('GST by Rate'), findsOneWidget);
    expect(find.text('5%'), findsOneWidget);
    expect(find.text('18%'), findsOneWidget);
    expect(find.text('₹1,65,000.00'), findsOneWidget); // taxable at 18%
    expect(find.text('₹4,900.00'), findsOneWidget); // taxable at 5%

    await tester.tap(find.text('By Supplier'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Suppliers (2)'), findsOneWidget);
    expect(find.text('₹1,91,045.00'), findsOneWidget); // Ganesh total
    // click a supplier to see its invoices
    await tester.tap(find.text('Chennai Steels'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('GST Invoices (1)'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);
  });

  testWidgets('clicking a purchase number opens the invoice details',
      (tester) async {
    await seed();
    await pump(tester);
    await tester
        .tap(find.textContaining('PUR/').first); // newest: the cement invoice
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Cement'), findsOneWidget);
    expect(find.text('K-102'), findsWidgets);
  });

  testWidgets('empty database: friendly message and Export disabled',
      (tester) async {
    await pump(tester);
    expect(find.textContaining('No GST purchase invoices yet'), findsOneWidget);
    final export = tester.widget<FilledButton>(find.ancestor(
        of: find.textContaining('Export Excel'),
        matching: find.byWidgetPredicate((w) => w is FilledButton)));
    expect(export.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(1024, 700), Size(1280, 800)]) {
    testWidgets(
        'fits at ${size.width.toInt()}x${size.height.toInt()} in all three views',
        (tester) async {
      await seed();
      await pump(tester, size: size);
      expect(tester.takeException(), isNull);
      for (final v in ['By GST Rate', 'By Supplier', 'By Invoice']) {
        await tester.tap(find.text(v));
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull, reason: v);
      }
    });
  }
}
