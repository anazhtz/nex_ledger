import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/cash_book/data/cash_book_repository.dart';
import 'package:nex_ledger/features/purchase/data/purchase_invoice_repository.dart';
import 'package:nex_ledger/features/reports/data/input_gst.dart';
import 'package:nex_ledger/features/subcontract/data/subcontract_repository.dart';

void main() {
  late AppDatabase db;
  late int projA, projB;

  Future<List<InputGstEntry>> load() => InputGstRepository(db).loadEntries();

  Future<int> categoryId(String name) async =>
      (await (db.select(db.expenseCategories)
                ..where((c) => c.subCategory.equals(name)))
              .getSingle())
          .id;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    Future<int> project(String code) =>
        db.projectDao.insertProject(ProjectsCompanion.insert(
            code: code,
            name: 'Site $code',
            type: ProjectType.project,
            status: ProjectStatus.active,
            startDate: DateTime(2026, 1, 1)));
    projA = await project('PRJ-A');
    projB = await project('PRJ-B');

    final shop = await db.purchaseDao
        .insertVendor(VendorsCompanion.insert(name: 'Ganesh Traders'));
    final inv = PurchaseInvoiceRepository(db);
    // 1. A: 10,000 @18% local + freight (freight is not GST)
    await inv.createInvoice(PurchaseInvoiceDraft(
      date: DateTime(2026, 9, 5),
      invoiceNo: 'K-1',
      vendorId: shop,
      projectId: projA,
      supplierGstin: '32AAAAA0000A1Z5',
      lines: const [
        InvoiceLineDraft(item: 'TMT Steel', qty: 100, rate: 100, gstRate: 18),
        InvoiceLineDraft(
            item: 'Binding wire', qty: 10, rate: 50), // 0% item: no GST
      ],
      freight: 500,
    ));
    // 2. B: 10,000 @12%, inter-state
    await inv.createInvoice(PurchaseInvoiceDraft(
      date: DateTime(2026, 10, 10),
      invoiceNo: 'T-1',
      vendorId: shop,
      projectId: projB,
      interState: true,
      lines: const [
        InvoiceLineDraft(item: 'Sand', qty: 200, rate: 50, gstRate: 12)
      ],
    ));
    // 2b. A purchase with no GST at all must not show up
    await inv.createInvoice(PurchaseInvoiceDraft(
      date: DateTime(2026, 10, 12),
      vendorId: shop,
      projectId: projA,
      lines: const [InvoiceLineDraft(item: 'Plain', qty: 1, rate: 999)],
    ));

    // 3. A: subcontract bill, 1000 × 50 = 50,000 @18%
    final sub = SubcontractRepository(db.subcontractDao, db.transactionDao, db);
    final subId =
        await sub.addSubcontractor(name: 'Murugan Gang', trade: 'Plastering');
    final woId = await sub.createWorkOrder(
        orderNumber: 'WO-1',
        projectId: projA,
        subcontractorId: subId,
        title: 'Plastering',
        trade: 'Plastering',
        unit: 'Sq.ft',
        agreedRate: 50,
        estimatedQuantity: 5000,
        retentionPercentage: 5,
        startDate: DateTime(2026, 8, 1));
    await sub.recordMeasurementBill(
        workOrderId: woId,
        billNumber: 'MB-01',
        date: DateTime(2026, 9, 20),
        measuredQuantity: 1000,
        unitRate: 50,
        gstRate: 18,
        partyGstin: '33AAAAA0000A1Z5');
    // a subcontract bill with no GST must not show up
    await sub.recordMeasurementBill(
        workOrderId: woId,
        billNumber: 'MB-02',
        date: DateTime(2026, 9, 25),
        measuredQuantity: 100,
        unitRate: 50);

    final cash = CashBookRepository(db.transactionDao);
    // 4. A: fuel expense 2,000 @18%
    await cash.addExpense(
        projectId: projA,
        date: DateTime(2026, 9, 30),
        amount: 2000,
        expenseCategoryId: await categoryId('Fuel'),
        gst: const ExpenseGstInput(
            rate: 18, partyName: 'HP Petrol Pump', billNo: 'F-9'));
    // 5. B: machinery rent 20,000 @18%
    await cash.addExpense(
        projectId: projB,
        date: DateTime(2026, 10, 15),
        amount: 20000,
        expenseCategoryId: await categoryId('Equipment Rental'),
        gst: const ExpenseGstInput(
            rate: 18,
            partyName: 'Balaji Cranes',
            partyGstin: '33AAAAA0000A1Z5'));
    // 6. an expense without GST must not show up
    await cash.addExpense(
        projectId: projA, date: DateTime(2026, 10, 1), amount: 777);
  });

  tearDown(() async => db.close());

  test('collects exactly the bills that carry GST, from all four sources',
      () async {
    final all = await load();
    expect(all, hasLength(5));
    expect(all.map((e) => e.source).toSet(), InputGstSource.values.toSet());

    final purchaseA = all.firstWhere(
        (e) => e.source == InputGstSource.purchases && e.projectId == projA);
    expect([
      purchaseA.taxable,
      purchaseA.cgst,
      purchaseA.sgst,
      purchaseA.igst
    ], [
      10000,
      900,
      900,
      0
    ], reason: 'only the 18% item; the 0% item and the freight carry no GST');
    expect(purchaseA.docNo, contains('K-1'));
    expect(purchaseA.party, 'Ganesh Traders');

    final purchaseB = all.firstWhere(
        (e) => e.source == InputGstSource.purchases && e.projectId == projB);
    expect([purchaseB.taxable, purchaseB.cgst, purchaseB.sgst, purchaseB.igst],
        [10000, 0, 0, 1200]);

    final sub = all.firstWhere((e) => e.source == InputGstSource.subcontract);
    expect([
      sub.party,
      sub.gstin,
      sub.docNo,
      sub.detail,
      sub.taxable,
      sub.gst
    ], [
      'Murugan Gang',
      '33AAAAA0000A1Z5',
      'MB-01',
      'Plastering',
      50000,
      9000
    ]);

    final fuel = all.firstWhere((e) => e.source == InputGstSource.expenses);
    expect([fuel.party, fuel.detail, fuel.docNo, fuel.gst],
        ['HP Petrol Pump', 'Fuel', 'F-9', 360]);

    final rent = all.firstWhere((e) => e.source == InputGstSource.machinery);
    expect([rent.party, rent.projectId, rent.taxable, rent.cgst, rent.sgst],
        ['Balaji Cranes', projB, 20000, 1800, 1800]);
  });

  test('input GST per project, with the split by source', () async {
    final byProject = summarizeByProject(await load());
    expect(byProject.map((p) => p.projectCode), ['PRJ-A', 'PRJ-B'],
        reason: 'biggest GST first');

    final a = byProject[0];
    expect([
      a.totals.taxable,
      a.totals.cgst,
      a.totals.sgst,
      a.totals.igst,
      a.totals.gst
    ], [
      62000,
      5580,
      5580,
      0,
      11160
    ]);
    expect(a.gstBySource, {
      InputGstSource.purchases: 1800,
      InputGstSource.subcontract: 9000,
      InputGstSource.expenses: 360
    });

    final b = byProject[1];
    expect([
      b.totals.taxable,
      b.totals.cgst,
      b.totals.sgst,
      b.totals.igst,
      b.totals.gst
    ], [
      30000,
      1800,
      1800,
      1200,
      4800
    ]);
    expect(b.gstBySource,
        {InputGstSource.purchases: 1200, InputGstSource.machinery: 3600});

    final all = inputGstTotals(await load());
    expect([all.entries, all.taxable, all.gst, all.total],
        [5, 92000, 15960, 107960]);
    expect(byProject.fold<double>(0, (s, p) => s + p.totals.gst), all.gst,
        reason: 'projects add up to the grand total');
  });

  test('by source, and filters by project / source / period', () async {
    final all = await load();
    final bySource = summarizeBySource(all);
    expect(bySource.map((s) => s.source.label),
        ['Purchases', 'Subcontractors', 'Machinery Rent', 'Other Expenses']);
    expect(bySource.map((s) => s.totals.gst), [3000, 9000, 3600, 360]);

    expect(applyInputGstFilter(all, InputGstFilter(projectId: projB)),
        hasLength(2));
    expect(
        applyInputGstFilter(
            all, const InputGstFilter(source: InputGstSource.subcontract)),
        hasLength(1));
    final oct = applyInputGstFilter(
        all,
        InputGstFilter(
            dateRange: DateTimeRange(
                start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 15))));
    expect(oct.map((e) => e.source),
        [InputGstSource.machinery, InputGstSource.purchases],
        reason: 'last day included, newest first');
    expect(
        applyInputGstFilter(all,
            InputGstFilter(projectId: projA, source: InputGstSource.machinery)),
        isEmpty);
    expect(
        inputGstTotals(
                applyInputGstFilter(all, InputGstFilter(projectId: projA)))
            .gst,
        11160);
  });

  test(
      'turning GST off on an expense removes it from the report; deleting does too',
      () async {
    var all = await load();
    final fuelTxn = (await (db.select(db.transactions)
          ..where((t) => t.amount.equals(2360)))
        .getSingle());
    final cash = CashBookRepository(db.transactionDao);
    await cash.updateTransaction(
        id: fuelTxn.id,
        projectId: projA,
        date: fuelTxn.date,
        type: TransactionType.expense,
        amount: 2000,
        expenseCategoryId: fuelTxn.expenseCategoryId);
    all = await load();
    expect(all.any((e) => e.source == InputGstSource.expenses), isFalse);

    await cash.deleteTransaction((await (db.select(db.transactions)
              ..where((t) => t.amount.equals(23600)))
            .getSingle())
        .id);
    all = await load();
    expect(all.any((e) => e.source == InputGstSource.machinery), isFalse);
  });

  test('empty database gives empty results, not errors', () async {
    final fresh = AppDatabase(NativeDatabase.memory());
    expect(await InputGstRepository(fresh).loadEntries(), isEmpty);
    expect(summarizeByProject(const []), isEmpty);
    expect(inputGstTotals(const []).total, 0);
    await fresh.close();
  });

  test('GST on advance stock is paid but not yet in project costs', () async {
    final shop = (await db.select(db.vendors).get()).first.id;
    await PurchaseInvoiceRepository(db).createInvoice(PurchaseInvoiceDraft(
      date: DateTime(2026, 10, 20),
      invoiceNo: 'S-1',
      vendorId: shop,
      projectId: projA,
      isAdvanceStock: true,
      lines: const [
        InvoiceLineDraft(item: 'Cement stock', qty: 100, rate: 100, gstRate: 18)
      ],
    ));
    final all = await load();
    final stock = all.firstWhere((e) => e.docNo.contains('S-1'));
    expect(stock.inProjectCost, isFalse);
    expect(stock.gst, 1800,
        reason: 'the GST was paid, so it is in the input GST report');

    final a = summarizeByProject(all).firstWhere((p) => p.projectId == projA);
    expect(a.totals.gst, 11160 + 1800,
        reason: 'input GST counts everything paid');
    expect(a.gstInCosts, 11160,
        reason: 'but only the GST inside project costs is shown against costs');
    expect(gstInProjectCosts(all, projectId: projA), 11160);
    expect(gstInProjectCosts(all), 15960,
        reason: 'all projects, stock excluded');
  });

  test('costs with and without GST', () {
    const v = ProjectCostView(totalCosts: 595600, gstInCosts: 75600);
    expect(v.costsWithoutGst, 520000);
    expect(
        const ProjectCostView(totalCosts: 100, gstInCosts: 0).costsWithoutGst,
        100);
  });
}
