import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/utils/excel_export_service.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';
import 'package:nex_ledger/features/reports/data/purchase_register.dart';

void main() {
  late AppDatabase db;
  late PurchaseRepository repo;
  late int projA, projB, shopX, shopY;

  Future<List<PurchaseDetail>> all() =>
      db.purchaseDao.watchAllPurchases().first;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
    Future<int> project(String code) =>
        db.projectDao.insertProject(ProjectsCompanion.insert(
            code: code,
            name: 'Site $code',
            type: ProjectType.project,
            status: ProjectStatus.active,
            startDate: DateTime(2026, 1, 1)));
    projA = await project('A');
    projB = await project('B');
    shopX = await db.purchaseDao
        .insertVendor(VendorsCompanion.insert(name: 'Ganesh Traders'));
    shopY = await db.purchaseDao
        .insertVendor(VendorsCompanion.insert(name: 'Anil Steels'));

    Future<void> buy(int p, int v, DateTime d, double amt, PaymentStatus s,
            {double paid = 0, bool stock = false}) =>
        repo.addPurchase(
            projectId: p,
            vendorId: v,
            date: d,
            itemDescription: 'Item',
            amount: amt,
            paymentStatus: s,
            paidAmount: paid,
            isAdvanceStock: stock);

    await buy(projA, shopX, DateTime(2026, 4, 10), 10000, PaymentStatus.paid);
    await buy(projA, shopY, DateTime(2026, 5, 5), 20000, PaymentStatus.pending);
    await buy(projB, shopX, DateTime(2026, 5, 20, 15, 30), 30000,
        PaymentStatus.partial,
        paid: 12000);
    await buy(projB, shopX, DateTime(2026, 6, 1), 5000, PaymentStatus.paid,
        stock: true);
  });

  tearDown(() async => db.close());

  test('no filter: every bill, newest first, totals add up', () async {
    final rows = applyPurchaseFilter(await all(), const PurchaseFilter());
    expect(rows, hasLength(4));
    expect(rows.first.transaction.date, DateTime(2026, 6, 1));
    final t = purchaseTotals(rows);
    expect(t.count, 4);
    expect(t.total, 65000);
    expect(t.paid, 27000);
    expect(t.balance, 38000);
  });

  test('filters by project, shop, status and they combine', () async {
    final data = await all();
    expect(applyPurchaseFilter(data, PurchaseFilter(projectId: projB)),
        hasLength(2));
    expect(applyPurchaseFilter(data, PurchaseFilter(vendorId: shopX)),
        hasLength(3));
    expect(
        applyPurchaseFilter(
            data, const PurchaseFilter(status: PaymentStatus.paid)),
        hasLength(2));
    expect(
        applyPurchaseFilter(
            data, const PurchaseFilter(status: PaymentStatus.pending)),
        hasLength(1));
    final combo = applyPurchaseFilter(
        data,
        PurchaseFilter(
            projectId: projB, vendorId: shopX, status: PaymentStatus.partial));
    expect(combo, hasLength(1));
    expect(combo.single.transaction.amount, 30000);
    expect(
        applyPurchaseFilter(
            data,
            PurchaseFilter(
                projectId: projA, vendorId: shopY, status: PaymentStatus.paid)),
        isEmpty);
  });

  test('date range is inclusive of both end days (even late in the day)',
      () async {
    final data = await all();
    final may = applyPurchaseFilter(
        data,
        PurchaseFilter(
            dateRange: DateTimeRange(
                start: DateTime(2026, 5, 5), end: DateTime(2026, 5, 20))));
    expect(may.map((d) => d.transaction.amount), [30000, 20000]);
    final justFirst = applyPurchaseFilter(
        data,
        PurchaseFilter(
            dateRange: DateTimeRange(
                start: DateTime(2026, 4, 10), end: DateTime(2026, 4, 10))));
    expect(justFirst, hasLength(1));
  });

  test('balance falls as a bill is settled, status follows', () async {
    var bill = (await all()).firstWhere((d) => d.transaction.amount == 30000);
    expect(purchaseBalance(bill), 18000);

    await repo.markPurchasePaid(
        purchaseId: bill.purchase.id,
        paymentDate: DateTime(2026, 6, 10),
        amountPaid: 8000);
    bill = (await all()).firstWhere((d) => d.transaction.amount == 30000);
    expect(bill.purchase.paymentStatus, PaymentStatus.partial);
    expect(purchaseBalance(bill), 10000);

    await repo.markPurchasePaid(
        purchaseId: bill.purchase.id,
        paymentDate: DateTime(2026, 6, 11),
        amountPaid: 10000);
    bill = (await all()).firstWhere((d) => d.transaction.amount == 30000);
    expect(bill.purchase.paymentStatus, PaymentStatus.paid);
    expect(purchaseBalance(bill), 0);
    expect(purchaseTotals(await all()).balance, 20000);
  });

  test('shop-wise summary groups bills and sorts biggest first', () async {
    final shops = summarizeByShop(await all());
    expect(shops.map((s) => s.vendor.name), ['Ganesh Traders', 'Anil Steels']);
    final x = shops.first;
    expect([x.bills, x.total, x.paid, x.balance], [3, 45000, 27000, 18000]);
    expect(x.lastBillDate, DateTime(2026, 6, 1));
    final y = shops.last;
    expect([y.bills, y.total, y.paid, y.balance], [1, 20000, 0, 20000]);

    // respects filters: only project B
    final b = summarizeByShop(
        applyPurchaseFilter(await all(), PurchaseFilter(projectId: projB)));
    expect(b, hasLength(1));
    expect(b.single.total, 35000);
    expect(summarizeByShop(const []), isEmpty);
  });

  test('Indian financial year runs April to March', () {
    var r = financialYearRange(DateTime(2026, 3, 31));
    expect([r.start, r.end], [DateTime(2025, 4, 1), DateTime(2026, 3, 31)]);
    r = financialYearRange(DateTime(2026, 4, 1));
    expect([r.start, r.end], [DateTime(2026, 4, 1), DateTime(2027, 3, 31)]);
    expect(financialYearLabel(DateTime(2026, 10, 14)), '2026-27');
    expect(financialYearLabel(DateTime(2027, 1, 5)), '2026-27');
  });

  test('Excel workbook has a bills sheet and a shop sheet with matching totals',
      () async {
    final rows = applyPurchaseFilter(await all(), const PurchaseFilter());
    final excel = ExcelExportService.buildPurchaseRegisterWorkbook(
        rows: rows, filterText: 'Project: All  |  Shop: All');
    expect(excel.tables.keys.toSet(), {'Purchase Register', 'By Shop'});

    String? cell(Sheet sh, int r, int c) => sh.rows[r][c]?.value?.toString();

    final bills = excel.tables['Purchase Register']!;
    // 4 title/info rows + header + 4 bills + total
    expect(bills.rows.length, 10);
    expect(cell(bills, 4, 2), 'Shop / Supplier');
    final shopsInOrder = [for (var r = 5; r < 9; r++) cell(bills, r, 2)];
    expect(shopsInOrder..sort(),
        ['Anil Steels', 'Ganesh Traders', 'Ganesh Traders', 'Ganesh Traders']);
    final total = bills.rows[9];
    expect(total[8]?.value.toString(), contains('TOTAL (4 bills)'));
    expect(double.parse(total[9]!.value.toString()), 65000);
    expect(double.parse(total[10]!.value.toString()), 27000);
    expect(double.parse(total[11]!.value.toString()), 38000);

    final shops = excel.tables['By Shop']!;
    expect(shops.rows.length, 8); // 4 info + header + 2 shops + total
    expect(cell(shops, 5, 1), 'Ganesh Traders');
    expect(double.parse(shops.rows[5][6]!.value.toString()), 18000);
    expect(double.parse(shops.rows[7][4]!.value.toString()), 65000);
  });
}
