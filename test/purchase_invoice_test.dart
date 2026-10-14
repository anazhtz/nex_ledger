import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/purchase/data/purchase_invoice_repository.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';
import 'package:nex_ledger/features/reports/data/ledger_repository.dart';
import 'package:nex_ledger/features/reports/data/report_repository.dart';

void main() {
  late AppDatabase db;
  late PurchaseInvoiceRepository inv;
  late ReportRepository reports;
  late int projA, projB, shop;

  Future<double> cash() => db.transactionDao.watchCashBalance().first;
  Future<ProjectPnl> pnl(int p) => reports.getProjectPnl(p);

  // 4 materials; items 3,20,725.00 + freight 3,000 + loading 1,000 = 3,24,725.00
  List<InvoiceLineDraft> fourLines(
          {List<int?> ids = const [null, null, null, null]}) =>
      [
        InvoiceLineDraft(
            purchaseId: ids[0],
            item: 'TMT Steel',
            hsn: '72142010',
            unit: 'Kg',
            qty: 2500,
            rate: 62,
            gstRate: 18),
        InvoiceLineDraft(
            purchaseId: ids[1],
            item: 'Cement OPC 53',
            hsn: '25232910',
            unit: 'Bag',
            qty: 200,
            rate: 410,
            gstRate: 18),
        InvoiceLineDraft(
            purchaseId: ids[2],
            item: 'M Sand',
            hsn: '25051000',
            unit: 'Cft',
            qty: 15,
            rate: 60,
            gstRate: 5),
        InvoiceLineDraft(
            purchaseId: ids[3],
            item: 'Brick 1st Class',
            hsn: '69041000',
            unit: 'Nos',
            qty: 5000,
            rate: 6.8,
            gstRate: 18),
      ];

  PurchaseInvoiceDraft draft({
    List<InvoiceLineDraft>? lines,
    double paidNow = 0,
    bool advance = false,
    bool inter = false,
    int? project,
    DateTime? date,
    double freight = 3000,
    double loading = 1000,
    bool roundOff = true,
    int? vendor,
  }) =>
      PurchaseInvoiceDraft(
        date: date ?? DateTime(2026, 9, 5),
        invoiceNo: 'INV-4587',
        invoiceDate: DateTime(2026, 9, 5),
        vendorId: vendor ?? shop,
        projectId: project ?? projA,
        supplierGstin: '32aabfs1234a1z5',
        supplierState: 'Kerala',
        interState: inter,
        creditDays: 30,
        isAdvanceStock: advance,
        transportBy: 'Mahadevan Transport',
        vehicleNo: 'KL 11 AB 1234',
        lines: lines ?? fourLines(),
        freight: freight,
        loading: loading,
        roundOff: roundOff,
        paidNow: paidNow,
        paymentMode: PaymentMode.bank,
      );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    inv = PurchaseInvoiceRepository(db);
    reports = ReportRepository(
        db.transactionDao, db.projectDao, db.depositDao, db.expenseCategoryDao);
    Future<int> project(String code) =>
        db.projectDao.insertProject(ProjectsCompanion.insert(
            code: code,
            name: 'Site $code',
            type: ProjectType.project,
            status: ProjectStatus.active,
            startDate: DateTime(2026, 1, 1)));
    projA = await project('PRJ-A');
    projB = await project('PRJ-B');
    shop = await db.purchaseDao
        .insertVendor(VendorsCompanion.insert(name: 'Shree Ganesh Traders'));
  });

  tearDown(() async => db.close());

  group('creating an invoice', () {
    test('paid in full: totals, cash, P&L and rows all agree', () async {
      final id = await inv.createInvoice(draft(paidNow: 324725));
      final d = (await inv.getInvoice(id))!;

      expect(d.invoice.purchaseNo, 'PUR/26-27/00001');
      expect(d.invoice.taxableValue, 271900); // 155,000 + 82,000 + 900 + 34,000
      expect(d.invoice.cgstAmount, 24412.5);
      expect(d.invoice.sgstAmount, 24412.5);
      expect(d.invoice.igstAmount, 0);
      expect(d.invoice.otherCharges, 4000);
      expect(d.invoice.roundOff, 0);
      expect(d.invoice.grandTotal, 324725);
      expect(d.invoice.supplierGstin, '32AABFS1234A1Z5'); // normalised

      // 4 item rows + freight + loading
      expect(d.lines, hasLength(6));
      expect(d.lines.map((l) => l.purchase.itemDescription).toList(), [
        'TMT Steel',
        'Cement OPC 53',
        'M Sand',
        'Brick 1st Class',
        'Transport / Freight',
        'Loading / Unloading',
      ]);
      expect(d.lines.map((l) => l.transaction.amount).toList(),
          [182900, 96760, 945, 40120, 3000, 1000]);
      expect(d.total, 324725); // rows add up to the grand total
      expect(d.paid, 324725);
      expect(d.balance, 0);
      expect(d.status, PaymentStatus.paid);
      expect(
          d.lines.every((l) => l.purchase.paymentStatus == PaymentStatus.paid),
          isTrue);
      expect(d.lines.first.purchase.hsn, '72142010');
      expect(d.lines.first.purchase.cgstAmount, 13950);

      expect(await cash(), -324725);
      final p = await pnl(projA);
      expect(p.purchases, 324725); // GST is part of the cost (Option A)
      expect(p.accountsPayable, 0);
      expect(p.netPnl, -324725);
    });

    test('on credit: nothing leaves cash, the whole bill is payable', () async {
      final id = await inv.createInvoice(draft());
      final d = (await inv.getInvoice(id))!;
      expect(d.paid, 0);
      expect(d.balance, 324725);
      expect(d.status, PaymentStatus.pending);
      expect(
          d.lines
              .every((l) => l.purchase.paymentStatus == PaymentStatus.pending),
          isTrue);
      expect(d.dueDate, DateTime(2026, 10, 5)); // 30 days credit
      expect(await cash(), 0);
      final p = await pnl(projA);
      expect(p.purchases, 324725);
      expect(p.accountsPayable, 324725);
    });

    test('part payment at entry fills the first rows first', () async {
      final id = await inv.createInvoice(draft(paidNow: 200000));
      final d = (await inv.getInvoice(id))!;
      expect(d.status, PaymentStatus.partial);
      expect(d.paid, 200000);
      expect(d.balance, 124725);
      // 182,900 paid in full, then 17,100 of the cement row
      expect(d.lines[0].purchase.paidAmount, 182900);
      expect(d.lines[0].purchase.paymentStatus, PaymentStatus.paid);
      expect(d.lines[1].purchase.paidAmount, 17100);
      expect(d.lines[1].purchase.paymentStatus, PaymentStatus.partial);
      expect(d.lines[2].purchase.paymentStatus, PaymentStatus.pending);
      expect(await cash(), -200000);
      expect((await pnl(projA)).accountsPayable, 124725);
    });

    test('later payments settle it; overpaying is refused', () async {
      final id = await inv.createInvoice(draft(paidNow: 100000));
      var left = await inv.recordInvoicePayment(
          invoiceId: id,
          amount: 124725,
          date: DateTime(2026, 10, 1),
          paymentMode: PaymentMode.cash);
      expect(left, 100000);
      expect(await cash(), -224725);

      await expectLater(
          inv.recordInvoicePayment(
              invoiceId: id, amount: 100000.01, date: DateTime(2026, 10, 2)),
          throwsArgumentError);
      await expectLater(
          inv.recordInvoicePayment(
              invoiceId: id, amount: 0, date: DateTime(2026, 10, 2)),
          throwsArgumentError);

      left = await inv.recordInvoicePayment(
          invoiceId: id, amount: 100000, date: DateTime(2026, 10, 3));
      expect(left, 0);
      final d = (await inv.getInvoice(id))!;
      expect(d.status, PaymentStatus.paid);
      expect(
          d.lines.every((l) => l.purchase.paymentStatus == PaymentStatus.paid),
          isTrue);
      expect(await cash(), -324725);
      expect((await pnl(projA)).accountsPayable, 0);
      expect(
          (await pnl(projA)).purchases, 324725); // paying never changes profit
    });

    test('inter-state invoice is all IGST', () async {
      final id = await inv.createInvoice(draft(inter: true));
      final d = (await inv.getInvoice(id))!;
      expect([d.invoice.cgstAmount, d.invoice.sgstAmount, d.invoice.igstAmount],
          [0, 0, 48825]);
      expect(d.invoice.isInterState, isTrue);
      expect(d.total, 324725);
    });

    test('round-off is folded into the last row so rows still add up',
        () async {
      final id = await inv.createInvoice(draft(lines: [
        const InvoiceLineDraft(item: 'Binding wire', qty: 1, rate: 100.40)
      ], freight: 0, loading: 0));
      final d = (await inv.getInvoice(id))!;
      expect(d.invoice.roundOff, -0.40);
      expect(d.invoice.grandTotal, 100);
      expect(d.lines.single.transaction.amount, 100);
      expect(d.total, d.invoice.grandTotal);
    });

    test('advance stock invoice does not hit P&L until allocated', () async {
      final id = await inv.createInvoice(draft(paidNow: 324725, advance: true));
      expect((await pnl(projA)).purchases, 0);
      expect(await cash(), -324725);

      // allocate the steel row to another project: P&L of that project moves
      final steel = (await inv.getInvoice(id))!.lines.first;
      final purchases =
          PurchaseRepository(db.purchaseDao, db.transactionDao, db);
      await purchases.allocateStockToProject(
          purchaseId: steel.purchase.id,
          targetProjectId: projB,
          date: DateTime(2026, 9, 20),
          amountToAllocate: 100000);
      expect((await pnl(projB)).purchases, 100000);
      expect(await cash(), -324725); // allocation moves no cash
      // an allocated invoice is locked against edit / delete
      await expectLater(inv.deleteInvoice(id), throwsStateError);
      await expectLater(
          inv.updateInvoice(id, draft(advance: true)), throwsStateError);
    });

    test('bad input is refused before anything is saved', () async {
      for (final bad in [
        draft(lines: const []),
        draft(lines: [const InvoiceLineDraft(item: 'X', qty: 0, rate: 5)]),
        draft(lines: [const InvoiceLineDraft(item: 'X', qty: 1, rate: -5)]),
        draft(lines: [
          const InvoiceLineDraft(item: 'X', qty: 1, rate: 5, gstRate: 150)
        ]),
        draft(lines: [
          const InvoiceLineDraft(
              item: 'X', qty: 1, rate: 5, discountPercent: 101)
        ]),
        draft(paidNow: 999999999),
        draft(
            lines: [const InvoiceLineDraft(item: 'Free', qty: 1, rate: 0)],
            freight: 0,
            loading: 0),
      ]) {
        await expectLater(inv.createInvoice(bad), throwsArgumentError);
      }
      expect(await db.select(db.purchaseInvoices).get(), isEmpty);
      expect(await db.select(db.transactions).get(), isEmpty);
      expect(await db.select(db.purchases).get(), isEmpty);
    });
  });

  group('numbering', () {
    test('runs per financial year and restarts in April', () async {
      final a = await inv.createInvoice(draft(date: DateTime(2026, 5, 1)));
      final b = await inv.createInvoice(draft(date: DateTime(2026, 8, 1)));
      final c = await inv
          .createInvoice(draft(date: DateTime(2027, 2, 1))); // still 26-27
      final d = await inv
          .createInvoice(draft(date: DateTime(2027, 4, 1))); // new year
      final e = await inv
          .createInvoice(draft(date: DateTime(2026, 3, 31))); // previous year
      Future<String> no(int id) async =>
          (await inv.getInvoice(id))!.invoice.purchaseNo;
      expect([await no(a), await no(b), await no(c)],
          ['PUR/26-27/00001', 'PUR/26-27/00002', 'PUR/26-27/00003']);
      expect(await no(d), 'PUR/27-28/00001');
      expect(await no(e), 'PUR/25-26/00001');
      expect(await inv.nextPurchaseNo(DateTime(2026, 9, 1)), 'PUR/26-27/00004');
    });
  });

  group('remembering items and supplier GST', () {
    test('HSN, GST rate and unit are remembered and updated per item',
        () async {
      await inv.createInvoice(draft());
      var defaults = await db.select(db.itemDefaults).get();
      expect(defaults, hasLength(4));
      final steel = defaults.firstWhere((i) => i.itemKey == 'tmt steel');
      expect([steel.hsn, steel.gstRate, steel.unit], ['72142010', 18, 'Kg']);

      // same item, different case, new rate -> updates the one row
      await inv.createInvoice(draft(lines: [
        const InvoiceLineDraft(
            item: 'tmt STEEL',
            hsn: '72142099',
            unit: 'Kg',
            qty: 1,
            rate: 100,
            gstRate: 12),
      ], freight: 0, loading: 0));
      defaults = await db.select(db.itemDefaults).get();
      expect(defaults, hasLength(4));
      final again = defaults.firstWhere((i) => i.itemKey == 'tmt steel');
      expect([again.hsn, again.gstRate], ['72142099', 12]);
    });

    test('supplier GSTIN and state are saved on the supplier', () async {
      await inv.createInvoice(PurchaseInvoiceDraft(
        date: DateTime(2026, 9, 5),
        vendorId: shop,
        projectId: projA,
        supplierGstin: ' 32aabfs1234a1z5',
        supplierState: 'Kerala',
        supplierAddress: 'Kozhikode',
        lines: const [InvoiceLineDraft(item: 'X', qty: 1, rate: 10)],
      ));
      final v = await (db.select(db.vendors)..where((x) => x.id.equals(shop)))
          .getSingle();
      expect([v.gstin, v.state, v.address],
          ['32AABFS1234A1Z5', 'Kerala', 'Kozhikode']);
    });
  });

  group('editing', () {
    test(
        'changing quantities updates totals, rows, cash payable and keeps payments',
        () async {
      final id = await inv.createInvoice(draft(paidNow: 100000));
      final before = (await inv.getInvoice(id))!;
      final ids = [for (final l in before.lines.take(4)) l.purchase.id];

      // steel 2,500 -> 3,000 kg (+31,000 incl. GST: 500×62=31,000 +18% = 36,580)
      final lines = fourLines(ids: ids);
      lines[0] = InvoiceLineDraft(
          purchaseId: ids[0],
          item: 'TMT Steel',
          hsn: '72142010',
          unit: 'Kg',
          qty: 3000,
          rate: 62,
          gstRate: 18);
      await inv.updateInvoice(id, draft(lines: lines));

      final d = (await inv.getInvoice(id))!;
      expect(d.invoice.grandTotal, 324725 + 36580);
      expect(d.total, 361305);
      expect(d.paid, 100000); // payments untouched
      expect(d.balance, 261305);
      expect(d.lines.first.purchase.id, ids[0],
          reason: 'item rows keep their ids');
      expect(d.lines.first.transaction.amount, 219480);
      expect(await cash(), -100000);
      final p = await pnl(projA);
      expect(p.purchases, 361305);
      expect(p.accountsPayable, 261305);
      expect(d.status, PaymentStatus.partial);
    });

    test('removing an item and a charge, adding another', () async {
      final id = await inv.createInvoice(draft());
      final ids = [
        for (final l in (await inv.getInvoice(id))!.lines.take(4)) l.purchase.id
      ];
      // keep steel + cement, drop sand + brick, add TMT 8mm, drop loading
      final lines = [
        InvoiceLineDraft(
            purchaseId: ids[0],
            item: 'TMT Steel',
            unit: 'Kg',
            qty: 2500,
            rate: 62,
            gstRate: 18),
        InvoiceLineDraft(
            purchaseId: ids[1],
            item: 'Cement OPC 53',
            unit: 'Bag',
            qty: 200,
            rate: 410,
            gstRate: 18),
        const InvoiceLineDraft(
            item: 'Binding wire', qty: 10, rate: 100, gstRate: 18),
      ];
      await inv.updateInvoice(id, draft(lines: lines, loading: 0));
      final d = (await inv.getInvoice(id))!;
      expect(d.lines.map((l) => l.purchase.itemDescription).toList(), [
        'TMT Steel',
        'Cement OPC 53',
        'Binding wire',
        'Transport / Freight'
      ]);
      expect(d.total, 182900 + 96760 + 1180 + 3000);
      expect(d.total, d.invoice.grandTotal);
      // removed rows left no orphans behind
      expect(await db.select(db.purchases).get(), hasLength(4));
      expect(await db.select(db.transactions).get(), hasLength(4));
    });

    test('cannot cut the total below what is already paid', () async {
      final id = await inv.createInvoice(draft(paidNow: 300000));
      await expectLater(
          inv.updateInvoice(
              id,
              draft(lines: [
                const InvoiceLineDraft(item: 'Only', qty: 1, rate: 1000)
              ], freight: 0, loading: 0)),
          throwsStateError);
      final d = (await inv.getInvoice(id))!;
      expect(d.invoice.grandTotal, 324725,
          reason: 'a refused edit changes nothing');
    });

    test('moving to another project moves the bill and its payments', () async {
      final id = await inv.createInvoice(draft(paidNow: 100000));
      final ids = [
        for (final l in (await inv.getInvoice(id))!.lines.take(4)) l.purchase.id
      ];
      await inv.updateInvoice(
          id, draft(project: projB, lines: fourLines(ids: ids)));
      expect((await pnl(projA)).purchases, 0);
      expect((await pnl(projB)).purchases, 324725);
      final pays = await (db.select(db.transactions)
            ..where((t) => t.type.equals('purchasePayment')))
          .get();
      expect(pays.single.projectId, projB);
    });

    test('switching a paid invoice to credit pricing keeps money honest',
        () async {
      final id = await inv.createInvoice(draft(paidNow: 324725));
      final ids = [
        for (final l in (await inv.getInvoice(id))!.lines.take(4)) l.purchase.id
      ];
      await inv.updateInvoice(id,
          draft(lines: fourLines(ids: ids), freight: 5000)); // freight +2,000
      final d = (await inv.getInvoice(id))!;
      expect(d.total, 326725);
      expect(d.paid, 324725);
      expect(d.balance, 2000);
      expect(d.status, PaymentStatus.partial);
      expect(await cash(), -324725);
    });
  });

  group('deleting', () {
    test('removes rows and payments and restores cash and P&L', () async {
      final id = await inv.createInvoice(draft(paidNow: 150000));
      expect(await cash(), -150000);
      await inv.deleteInvoice(id);
      expect(await cash(), 0);
      final p = await pnl(projA);
      expect([p.purchases, p.accountsPayable], [0, 0]);
      expect(await db.select(db.purchaseInvoices).get(), isEmpty);
      expect(await db.select(db.purchases).get(), isEmpty);
      expect(await db.select(db.transactions).get(), isEmpty);
    });

    test('only that invoice goes; others and legacy purchases stay', () async {
      final a = await inv.createInvoice(draft(paidNow: 1000));
      await inv.createInvoice(draft(paidNow: 2000));
      final legacy = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
      await legacy.addPurchase(
          projectId: projA,
          vendorId: shop,
          date: DateTime(2026, 9, 6),
          itemDescription: 'Old style',
          amount: 500,
          paymentStatus: PaymentStatus.paid);
      await inv.deleteInvoice(a);
      expect(await db.select(db.purchaseInvoices).get(), hasLength(1));
      expect(await cash(), -2500);
    });
  });

  group('the old single-purchase paths stay safe', () {
    test('a legacy purchase works exactly as before', () async {
      final legacy = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
      await legacy.addPurchase(
          projectId: projA,
          vendorId: shop,
          date: DateTime(2026, 9, 6),
          itemDescription: 'Materials',
          amount: 120000,
          paymentStatus: PaymentStatus.paid);
      expect(await cash(), -120000);
      expect((await pnl(projA)).purchases, 120000);
      final row = (await db.purchaseDao.watchAllPurchases().first).single;
      expect(row.purchase.invoiceId, isNull);
      await legacy.deletePurchase(row.purchase.id); // still deletable
      expect(await cash(), 0);
    });

    test('invoice rows cannot be edited or deleted one by one', () async {
      final id = await inv.createInvoice(draft());
      final row = (await inv.getInvoice(id))!.lines.first;
      final legacy = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
      await expectLater(
          legacy.deletePurchase(row.purchase.id), throwsStateError);
      await expectLater(
          legacy.updatePurchase(
              purchaseId: row.purchase.id,
              projectId: projA,
              vendorId: shop,
              date: DateTime(2026, 9, 6),
              itemDescription: 'x',
              amount: 1),
          throwsStateError);
      expect(await db.select(db.purchases).get(), hasLength(6));
    });

    test('"Mark Paid" on an invoice row pays the invoice, not a loose row',
        () async {
      final id = await inv.createInvoice(draft());
      final row = (await inv.getInvoice(id))!.lines.first;
      final legacy = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
      await legacy.markPurchasePaid(
          purchaseId: row.purchase.id,
          paymentDate: DateTime(2026, 9, 10),
          amountPaid: 50000);
      final d = (await inv.getInvoice(id))!;
      expect(d.paid, 50000);
      expect(d.balance, 274725);
      expect(await cash(), -50000);
      final pay = (await db.select(db.transactions).get())
          .firstWhere((t) => t.type == TransactionType.purchasePayment);
      expect(pay.invoiceId, id);
    });
  });

  group('the supplier ledger and other reports', () {
    test('ledger shows the GST-inclusive bill and counts payments once',
        () async {
      final id = await inv.createInvoice(draft(paidNow: 100000));
      await inv.recordInvoicePayment(
          invoiceId: id, amount: 50000, date: DateTime(2026, 10, 1));
      final ledger = await LedgerRepository(db).watchVendorLedger(shop).first;
      expect(ledger.summary.totalCredit, 324725,
          reason: 'bill incl. GST and freight');
      expect(ledger.summary.totalDebit, 150000, reason: 'each payment once');
      expect(ledger.summary.closingBalance, 174725);
    });

    test('material register still sees the items', () async {
      await inv.createInvoice(draft(paidNow: 324725));
      final list = await db.purchaseDao.watchPurchasesByProject(projA).first;
      expect(list, hasLength(6));
      final steel =
          list.firstWhere((l) => l.purchase.itemDescription == 'TMT Steel');
      expect(steel.purchase.quantity, 2500);
      expect(steel.purchase.unit, 'Kg');
    });

    test('Section 11 numbers are unaffected by GST invoices elsewhere',
        () async {
      // The classic check, run on a project that also has a GST invoice.
      final dep = DateTime(2026, 9, 1);
      await db.transactionDao.insertTransaction(TransactionsCompanion.insert(
          projectId: projB,
          date: dep,
          type: TransactionType.deposit,
          affectsPnl: const Value(false),
          amount: 500000));
      await inv.createInvoice(draft(project: projA, paidNow: 324725));
      expect(await cash(), 500000 - 324725);
      expect((await pnl(projB)).income, 0);
      expect((await pnl(projA)).purchases, 324725);
    });
  });
}
