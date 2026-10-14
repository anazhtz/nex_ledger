import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/utils/gst_utils.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/features/purchase/data/purchase_invoice_repository.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';
import 'package:nex_ledger/features/purchase/presentation/purchase_invoice_form_screen.dart';
import 'package:nex_ledger/features/purchase/presentation/purchase_list_screen.dart';
import 'package:nex_ledger/features/settings/presentation/widgets/company_gst_card.dart';

/// A GSTIN with a correct check digit built from its first 14 characters.
String gstin(String first14) => first14 + GstUtils.checkCharacter(first14);

void main() {
  late AppDatabase db;
  late int project, localShop, otherStateShop;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    project = await db.projectDao.insertProject(ProjectsCompanion.insert(
        code: 'PRJ-A',
        name: 'Malabar Tower',
        type: ProjectType.project,
        status: ProjectStatus.active,
        startDate: DateTime(2026, 1, 1)));
    localShop = await db.purchaseDao.insertVendor(VendorsCompanion.insert(
        name: 'Shree Ganesh Traders',
        gstin: Value(gstin('32AAAAA0000A1Z')),
        state: const Value('Kerala')));
    otherStateShop = await db.purchaseDao.insertVendor(VendorsCompanion.insert(
        name: 'Chennai Steels',
        gstin: Value(gstin('33AAAAA0000A1Z')),
        state: const Value('Tamil Nadu')));
    await db.setSetting(
        AppDatabase.settingCompanyGstin, gstin('32AABFS1234A1Z')); // Kerala
  });

  tearDown(() async => db.close());

  Future<void> settle(WidgetTester tester, {int rounds = 4}) async {
    for (var i = 0; i < rounds; i++) {
      await tester
          .runAsync(() => Future.delayed(const Duration(milliseconds: 60)));
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pumpApp(WidgetTester tester, Widget screen,
      {Size size = const Size(1500, 1000)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => screen),
      GoRoute(
          path: '/purchases',
          builder: (_, __) => const Scaffold(body: Text('PURCHASES LIST'))),
      GoRoute(
          path: '/purchases/invoice/:id/edit',
          builder: (_, s) =>
              Scaffold(body: Text('EDIT ${s.pathParameters['id']}'))),
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

  Finder field(String key) => find.byKey(Key(key));

  /// Checks a SnackBar message, then lets it expire so the next one can show.
  Future<void> expectSnack(WidgetTester tester, String text) async {
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining(text), findsOneWidget,
        reason: 'snack bar "$text"');
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> pickProject(WidgetTester tester) async {
    await tester.tap(find.text('Select project'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('PRJ-A').last);
    await tester.pumpAndSettle();
  }

  Future<void> pickSupplier(WidgetTester tester, String name) async {
    await tester.tap(find.text('Select supplier'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  Future<void> pickGst(WidgetTester tester, int row, String label) async {
    await tester.ensureVisible(field('inv_gst_$row'));
    await tester.tap(field('inv_gst_$row'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  group('Settings: company GST card', () {
    testWidgets('saves a valid GSTIN and shows the state it implies',
        (tester) async {
      await db.setSetting(AppDatabase.settingCompanyGstin, null);
      await pumpApp(tester,
          const Scaffold(body: SingleChildScrollView(child: CompanyGstCard())));
      expect(find.textContaining('Not set yet'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Company GSTIN'),
          gstin('32AABFS1234A1Z').toLowerCase());
      await tester.pump();
      expect(find.text('Kerala'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await settle(tester);

      expect(await db.getSetting(AppDatabase.settingCompanyGstin),
          gstin('32AABFS1234A1Z'));
      expect(find.textContaining('in Kerala use CGST + SGST'), findsOneWidget);
    });

    testWidgets('a badly shaped GSTIN cannot be saved', (tester) async {
      await db.setSetting(AppDatabase.settingCompanyGstin, null);
      await pumpApp(tester,
          const Scaffold(body: SingleChildScrollView(child: CompanyGstCard())));
      await tester.enterText(
          find.widgetWithText(TextField, 'Company GSTIN'), '32AAB');
      await tester.pump();
      expect(find.textContaining('15 characters'), findsOneWidget);
      final save = tester.widget<FilledButton>(find.ancestor(
          of: find.text('Save'),
          matching: find.byWidgetPredicate((w) => w is FilledButton)));
      expect(save.onPressed, isNull);
      expect(await db.getSetting(AppDatabase.settingCompanyGstin), isNull);
    });
  });

  group('Invoice form: new invoice', () {
    testWidgets('local supplier: CGST + SGST, live totals, saves correctly',
        (tester) async {
      await pumpApp(tester, const PurchaseInvoiceFormScreen());
      expect(find.text('PUR/26-27/00001'.replaceFirst('26-27', _fy())),
          findsOneWidget);

      await pickProject(tester);
      await pickSupplier(tester, 'Shree Ganesh Traders');
      // supplier details fill in by themselves, and the type is worked out
      expect(
          find.text('Supplier is in your state: CGST + SGST.'), findsOneWidget);
      expect(find.text('CGST (₹)'), findsOneWidget);
      expect(find.text('SGST (₹)'), findsOneWidget);
      expect(find.text('IGST (₹)'), findsNothing);

      await tester.enterText(field('inv_item_0'), 'TMT Steel');
      await tester.enterText(field('inv_qty_0'), '2500');
      await tester.enterText(field('inv_rate_0'), '62');
      await pickGst(tester, 0, '18%');
      await tester.pump();
      expect(find.text('1,82,900.00'), findsWidgets); // row amount
      expect(find.text('₹1,82,900.00'), findsWidgets); // grand total

      await tester.tap(find.text('Add Item'));
      await tester.pumpAndSettle();
      await tester.enterText(field('inv_item_1'), 'M Sand');
      await tester.enterText(field('inv_qty_1'), '15');
      await tester.enterText(field('inv_rate_1'), '60');
      await pickGst(tester, 1, '5%');
      await tester.pump();

      // freight, no GST
      await tester.enterText(field('inv_freight'), '3000');
      await tester.pump();
      expect(find.text('₹1,86,845.00'), findsWidgets); // 1,82,900 + 945 + 3,000

      await tester.tap(find.text('Save & Close'));
      await settle(tester, rounds: 6);
      await tester.pumpAndSettle();

      final invs = await db.select(db.purchaseInvoices).get();
      expect(invs, hasLength(1));
      final i = invs.single;
      expect(i.grandTotal, 186845);
      expect(i.cgstAmount, 13972.5); // (27,900 + 45) ÷ 2
      expect([i.taxableValue, i.otherCharges, i.isInterState],
          [155900, 3000, false]);
      expect(i.supplierGstin, gstin('32AAAAA0000A1Z'));
      final rows = await db.select(db.purchases).get();
      expect(rows.map((r) => r.itemDescription).toList(),
          ['TMT Steel', 'M Sand', 'Transport / Freight']);
      expect(find.text('PURCHASES LIST'), findsOneWidget,
          reason: 'goes back to the list after saving');
    });

    testWidgets('supplier in another state switches the whole form to IGST',
        (tester) async {
      await pumpApp(tester, const PurchaseInvoiceFormScreen());
      await pickProject(tester);
      await pickSupplier(tester, 'Chennai Steels');
      expect(find.text('Supplier is in another state: IGST.'), findsOneWidget);
      expect(find.text('IGST (₹)'), findsOneWidget);
      expect(find.text('CGST (₹)'), findsNothing);

      await tester.enterText(field('inv_item_0'), 'TMT Steel');
      await tester.enterText(field('inv_qty_0'), '100');
      await tester.enterText(field('inv_rate_0'), '100');
      await pickGst(tester, 0, '18%');
      await tester.pump();
      expect(find.text('₹11,800.00'), findsWidgets);
      await tester.tap(find.text('Save & Close'));
      await settle(tester, rounds: 6);

      final i = (await db.select(db.purchaseInvoices).get()).single;
      expect([i.cgstAmount, i.sgstAmount, i.igstAmount, i.isInterState],
          [0, 0, 1800, true]);
    });

    testWidgets('the type can be set by hand and put back to automatic',
        (tester) async {
      await pumpApp(tester, const PurchaseInvoiceFormScreen());
      await pickSupplier(tester, 'Shree Ganesh Traders');
      await tester.tap(find.text('Inter State'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Set by hand'), findsOneWidget);
      expect(find.text('IGST (₹)'), findsOneWidget);
      await tester.tap(find.text('Auto'));
      await tester.pumpAndSettle();
      expect(
          find.text('Supplier is in your state: CGST + SGST.'), findsOneWidget);
    });

    testWidgets('a remembered material fills HSN, GST rate and unit',
        (tester) async {
      await db.into(db.itemDefaults).insert(ItemDefaultsCompanion.insert(
          itemKey: 'tmt steel 12mm',
          itemName: 'TMT Steel 12mm',
          hsn: const Value('72142010'),
          gstRate: const Value(18),
          unit: const Value('Kg')));
      await pumpApp(tester, const PurchaseInvoiceFormScreen());
      await tester.enterText(field('inv_item_0'), 'tmt');
      await tester.pumpAndSettle();
      expect(find.text('TMT Steel 12mm'), findsOneWidget); // suggestion
      expect(find.textContaining('HSN 72142010'), findsOneWidget);
      await tester.tap(find.text('TMT Steel 12mm'));
      await tester.pumpAndSettle();

      expect(tester.widget<TextFormField>(field('inv_hsn_0')).controller!.text,
          '72142010');
      expect(find.text('18%'), findsOneWidget);
      expect(find.text('Kg'), findsWidgets);
    });

    testWidgets('missing project, supplier, items or a bad GSTIN stop the save',
        (tester) async {
      await pumpApp(tester, const PurchaseInvoiceFormScreen());
      Future<void> save() async {
        await tester.tap(find.text('Save & Close'));
        await tester.pump();
      }

      await save();
      await expectSnack(tester, 'Please select a project / site.');
      await pickProject(tester);
      await save();
      await expectSnack(tester, 'Please select or add a supplier.');
      await pickSupplier(tester, 'Shree Ganesh Traders');
      await save();
      await expectSnack(tester, 'Add at least one item to the invoice.');

      await tester.enterText(field('inv_item_0'), 'Cement');
      await tester.enterText(field('inv_rate_0'), '400');
      await tester.enterText(
          find.byWidgetPredicate((w) =>
              w is TextField && w.decoration?.hintText == '32AABFS1234A1Z5'),
          '32BADGSTIN');
      await tester.pump();
      await save();
      await expectSnack(tester, 'not in the right format');
      expect(await db.select(db.purchaseInvoices).get(), isEmpty);
    });

    testWidgets('a GSTIN with a wrong check digit asks before saving',
        (tester) async {
      await pumpApp(tester, const PurchaseInvoiceFormScreen());
      await pickProject(tester);
      await pickSupplier(tester, 'Shree Ganesh Traders');
      await tester.enterText(field('inv_item_0'), 'Cement');
      await tester.enterText(field('inv_qty_0'), '1');
      await tester.enterText(field('inv_rate_0'), '400');
      final good = gstin('32AAAAA0000A1Z');
      final wrongDigit = good.substring(0, 14) + (good[14] == '1' ? '2' : '1');
      await tester.enterText(
          find.byWidgetPredicate((w) =>
              w is TextField && w.decoration?.hintText == '32AABFS1234A1Z5'),
          wrongDigit);
      await tester.pump();

      await tester.tap(find.text('Save & Close'));
      await tester.pumpAndSettle();
      expect(find.text('Check the GSTIN'), findsOneWidget);
      expect(await db.select(db.purchaseInvoices).get(), isEmpty);

      await tester.tap(find.text('Go back'));
      await tester.pumpAndSettle();
      expect(await db.select(db.purchaseInvoices).get(), isEmpty);

      await tester.tap(find.text('Save & Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save anyway'));
      await settle(tester, rounds: 6);
      expect(await db.select(db.purchaseInvoices).get(), hasLength(1));
    });

    testWidgets('part payment must be between zero and the total',
        (tester) async {
      await pumpApp(tester, const PurchaseInvoiceFormScreen());
      await pickProject(tester);
      await pickSupplier(tester, 'Shree Ganesh Traders');
      await tester.enterText(field('inv_item_0'), 'Cement');
      await tester.enterText(field('inv_qty_0'), '10');
      await tester.enterText(field('inv_rate_0'), '100');

      await tester.tap(find.text('Credit (Unpaid)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Partial Advance').last);
      await tester.pumpAndSettle();
      await tester.enterText(field('inv_paid'), '5000');
      await tester.pump();
      await tester.tap(find.text('Save & Close'));
      await tester.pump();
      await expectSnack(tester, 'equals the total');
      expect(await db.select(db.purchaseInvoices).get(), isEmpty);
    });
  });

  group('Invoice form: editing', () {
    Future<int> seed({double paid = 0}) =>
        PurchaseInvoiceRepository(db).createInvoice(PurchaseInvoiceDraft(
          date: DateTime(2026, 9, 5),
          invoiceNo: 'INV-1',
          vendorId: localShop,
          projectId: project,
          supplierGstin: gstin('32AAAAA0000A1Z'),
          supplierState: 'Kerala',
          lines: const [
            InvoiceLineDraft(
                item: 'TMT Steel',
                hsn: '72142010',
                unit: 'Kg',
                qty: 100,
                rate: 100,
                gstRate: 18),
            InvoiceLineDraft(
                item: 'Cement', unit: 'Bag', qty: 10, rate: 400, gstRate: 18),
          ],
          paidNow: paid,
        ));

    testWidgets('opens with the saved values and saves changes',
        (tester) async {
      final id = await seed(paid: 5000);
      await pumpApp(tester, PurchaseInvoiceFormScreen(invoiceId: id));
      await settle(tester);

      expect(find.text('Edit Purchase Invoice'.toUpperCase()), findsOneWidget);
      expect(find.text('PUR/26-27/00001'.replaceFirst('26-27', _fy())),
          findsOneWidget);
      expect(tester.widget<TextFormField>(field('inv_item_0')).controller!.text,
          'TMT Steel');
      expect(tester.widget<TextFormField>(field('inv_qty_0')).controller!.text,
          '100');
      expect(tester.widget<TextFormField>(field('inv_hsn_0')).controller!.text,
          '72142010');
      expect(find.textContaining('Paid so far ₹5,000.00'), findsOneWidget);

      await tester.enterText(field('inv_qty_0'), '200');
      await tester.pump();
      await tester.tap(find.text('Save Changes'));
      await settle(tester, rounds: 6);

      final d = (await PurchaseInvoiceRepository(db).getInvoice(id))!;
      expect(d.invoice.taxableValue, 24000); // 200×100 + 10×400
      expect(d.total, 28320);
      expect(d.paid, 5000);
      expect(d.lines.first.purchase.id, isNotNull);
      expect(await db.select(db.purchaseInvoices).get(), hasLength(1));
    });

    testWidgets('cannot lower the total below what is already paid',
        (tester) async {
      final id = await seed(paid: 14000);
      await pumpApp(tester, PurchaseInvoiceFormScreen(invoiceId: id));
      await settle(tester);
      await tester.enterText(field('inv_qty_0'), '1');
      await tester.enterText(field('inv_qty_1'), '1');
      await tester.pump();
      await tester.tap(find.text('Save Changes'));
      await tester.pump();
      await expectSnack(tester, 'less than the');
      final d = (await PurchaseInvoiceRepository(db).getInvoice(id))!;
      expect(d.total, 16520, reason: 'nothing was saved');
    });
  });

  group('Purchases list', () {
    Future<int> seedInvoice() =>
        PurchaseInvoiceRepository(db).createInvoice(PurchaseInvoiceDraft(
          date: DateTime(2026, 9, 5),
          invoiceNo: 'INV-4587',
          vendorId: localShop,
          projectId: project,
          creditDays: 30,
          lines: const [
            InvoiceLineDraft(
                item: 'TMT Steel', qty: 100, rate: 100, gstRate: 18),
            InvoiceLineDraft(item: 'Cement', qty: 10, rate: 400, gstRate: 18),
          ],
          freight: 500,
        ));

    Future<void> seedLegacy() =>
        PurchaseRepository(db.purchaseDao, db.transactionDao, db).addPurchase(
            projectId: project,
            vendorId: localShop,
            date: DateTime(2026, 9, 1),
            itemDescription: 'Old bill',
            amount: 700,
            paymentStatus: PaymentStatus.paid);

    testWidgets('an invoice is one row next to old-style purchases',
        (tester) async {
      await seedInvoice();
      await seedLegacy();
      await pumpApp(tester, const PurchaseListScreen());

      expect(find.textContaining('PUR/'), findsOneWidget);
      expect(find.textContaining('2 items'), findsOneWidget);
      expect(find.text('TMT Steel'), findsNothing,
          reason: 'items are inside the invoice, not separate rows');
      expect(find.text('Old bill'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('₹17,020.00'),
          findsWidgets); // 16,520 incl. GST + 500 freight
      expect(tester.takeException(), isNull);
    });

    testWidgets('the details open on click and a part payment updates them',
        (tester) async {
      final id = await seedInvoice();
      await pumpApp(tester, const PurchaseListScreen());

      await tester.tap(find.textContaining('PUR/'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('TMT Steel'), findsOneWidget);
      expect(find.text('Cement'), findsOneWidget);
      expect(find.text('Transport / Freight'), findsOneWidget);
      expect(find.text('Pay ₹17,020.00'), findsOneWidget);

      await tester.tap(find.text('Pay ₹17,020.00'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.enterText(find.widgetWithText(TextField, '17020'), '7020');
      await tester.tap(find.text('Record Payment'));
      await settle(tester, rounds: 6);
      await tester.pump(const Duration(milliseconds: 400));

      final d = (await tester
          .runAsync(() => PurchaseInvoiceRepository(db).getInvoice(id)))!;
      expect(
          [d.paid, d.balance, d.status], [7020, 10000, PaymentStatus.partial]);
      expect(find.text('Pay ₹10,000.00'), findsOneWidget,
          reason: 'the open dialog updates itself');
    });

    testWidgets('deleting an invoice leaves the old-style purchases alone',
        (tester) async {
      await seedInvoice();
      await seedLegacy();
      await pumpApp(tester, const PurchaseListScreen());

      await tester.tap(find.textContaining('PUR/'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Delete').last);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Delete Invoice'));
      await settle(tester, rounds: 6);
      await tester.pump(const Duration(milliseconds: 400));

      expect(await tester.runAsync(() => db.select(db.purchaseInvoices).get()),
          isEmpty);
      expect(find.text('Old bill'), findsOneWidget);
      expect(
          await tester
              .runAsync(() => db.transactionDao.watchCashBalance().first),
          -700,
          reason: 'only the old bill remains');
      expect(tester.takeException(), isNull);
    });
  });
}

/// The financial-year part of a purchase number for today's date.
String _fy() {
  final now = DateTime.now();
  final start = now.month >= 4 ? now.year : now.year - 1;
  String two(int y) => (y % 100).toString().padLeft(2, '0');
  return '${two(start)}-${two(start + 1)}';
}
