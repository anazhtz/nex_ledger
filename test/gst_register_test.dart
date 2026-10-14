import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/excel_export_service.dart';
import 'package:nex_ledger/features/purchase/data/purchase_invoice_repository.dart';
import 'package:nex_ledger/features/reports/data/gst_register.dart';

void main() {
  late AppDatabase db;
  late PurchaseInvoiceRepository repo;
  late int projA, projB, kerala, tamil;

  Future<List<InvoiceDetail>> all() => repo.watchInvoices().first;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = PurchaseInvoiceRepository(db);
    Future<int> project(String code) =>
        db.projectDao.insertProject(ProjectsCompanion.insert(
            code: code,
            name: 'Site $code',
            type: ProjectType.project,
            status: ProjectStatus.active,
            startDate: DateTime(2026, 1, 1)));
    projA = await project('PRJ-A');
    projB = await project('PRJ-B');
    kerala = await db.purchaseDao.insertVendor(VendorsCompanion.insert(
        name: 'Ganesh Traders', gstin: const Value('32AAAAA0000A1Z5')));
    tamil = await db.purchaseDao.insertVendor(VendorsCompanion.insert(
        name: 'Chennai Steels', gstin: const Value('33AAAAA0000A1Z5')));

    // A: local, 2 items + freight           -> total 1,86,845
    await repo.createInvoice(PurchaseInvoiceDraft(
      date: DateTime(2026, 9, 5),
      invoiceNo: 'K-101',
      vendorId: kerala,
      projectId: projA,
      supplierGstin: '32AAAAA0000A1Z5',
      supplierState: 'Kerala',
      lines: const [
        InvoiceLineDraft(
            item: 'TMT Steel',
            hsn: '72142010',
            unit: 'Kg',
            qty: 2500,
            rate: 62,
            gstRate: 18),
        InvoiceLineDraft(
            item: 'M Sand',
            hsn: '25051000',
            unit: 'Cft',
            qty: 15,
            rate: 60,
            gstRate: 5),
      ],
      freight: 3000,
      paidNow: 186845,
      paymentMode: PaymentMode.bank,
    ));
    // B: inter-state, one item               -> total 11,800
    await repo.createInvoice(PurchaseInvoiceDraft(
      date: DateTime(2026, 10, 10),
      invoiceNo: 'T-77',
      vendorId: tamil,
      projectId: projB,
      supplierGstin: '33AAAAA0000A1Z5',
      supplierState: 'Tamil Nadu',
      interState: true,
      lines: const [
        InvoiceLineDraft(
            item: 'TMT Steel',
            hsn: '72142010',
            unit: 'Kg',
            qty: 100,
            rate: 100,
            gstRate: 18)
      ],
    ));
    // C: local, one item, 5%                 -> total 4,200
    await repo.createInvoice(PurchaseInvoiceDraft(
      date: DateTime(2026, 11, 2),
      invoiceNo: 'K-102',
      vendorId: kerala,
      projectId: projA,
      supplierGstin: '32AAAAA0000A1Z5',
      supplierState: 'Kerala',
      lines: const [
        InvoiceLineDraft(
            item: 'Cement',
            hsn: '25232910',
            unit: 'Bag',
            qty: 10,
            rate: 400,
            gstRate: 5)
      ],
    ));
  });

  tearDown(() async => db.close());

  test('totals tie out: taxable + GST + charges = invoice totals', () async {
    final t = gstRegisterTotals(await all());
    expect(t.invoices, 3);
    expect(t.taxable, 169900);
    expect([t.cgst, t.sgst, t.igst], [14072.5, 14072.5, 1800]);
    expect(t.totalGst, 29945);
    expect(t.otherCharges, 3000);
    expect(t.total, 202845);
    expect(t.taxable + t.totalGst + t.otherCharges + t.roundOff, t.total);
  });

  test('filters by project, supplier and period (inclusive)', () async {
    final data = await all();
    expect(applyGstFilter(data, const GstRegisterFilter()), hasLength(3));
    expect(
        applyGstFilter(data, GstRegisterFilter(projectId: projA))
            .map((d) => d.invoice.invoiceNo),
        ['K-102', 'K-101']);
    expect(
        applyGstFilter(data, GstRegisterFilter(vendorId: tamil))
            .map((d) => d.invoice.invoiceNo),
        ['T-77']);
    final oct = applyGstFilter(
        data,
        GstRegisterFilter(
            dateRange: DateTimeRange(
                start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 10))));
    expect(oct.map((d) => d.invoice.invoiceNo), ['T-77'],
        reason: 'last day is included');
    expect(
        applyGstFilter(
            data, GstRegisterFilter(projectId: projB, vendorId: kerala)),
        isEmpty);
    expect(
        gstRegisterTotals(
                applyGstFilter(data, GstRegisterFilter(projectId: projA)))
            .total,
        191045);
  });

  test('rate-wise summary groups items and splits GST correctly', () async {
    final rates = summarizeByRate(await all());
    expect(rates.map((r) => r.rate), [5, 18]);
    final five = rates[0];
    expect([five.items, five.taxable, five.cgst, five.sgst, five.igst],
        [2, 4900, 122.5, 122.5, 0]);
    final eighteen = rates[1];
    expect([
      eighteen.items,
      eighteen.taxable,
      eighteen.cgst,
      eighteen.sgst,
      eighteen.igst
    ], [
      2,
      165000,
      13950,
      13950,
      1800
    ]);
    // freight is not an item, so it is not in any rate
    expect(rates.fold<double>(0, (a, r) => a + r.taxable), 169900);
  });

  test('supplier-wise summary, biggest first', () async {
    final s = summarizeBySupplier(await all());
    expect(s.map((x) => x.name), ['Ganesh Traders', 'Chennai Steels']);
    expect([s[0].invoices, s[0].taxable, s[0].gst, s[0].total],
        [2, 159900, 28145, 191045]);
    expect([s[1].invoices, s[1].taxable, s[1].gst, s[1].total],
        [1, 10000, 1800, 11800]);
    expect(s[0].gstin, '32AAAAA0000A1Z5');
  });

  test('an empty selection gives zeros, not errors', () async {
    expect(gstRegisterTotals(const []).total, 0);
    expect(summarizeByRate(const []), isEmpty);
    expect(summarizeBySupplier(const []), isEmpty);
  });

  test('Excel workbook has the four sheets with matching numbers', () async {
    final rows = applyGstFilter(await all(), const GstRegisterFilter());
    final excel = ExcelExportService.buildGstRegisterWorkbook(
        rows: rows, filterText: 'Project: All');
    expect(excel.tables.keys.toSet(),
        {'Invoice Register', 'Item Details', 'By GST Rate', 'By Supplier'});

    String? v(Sheet sh, int r, int c) => sh.rows[r][c]?.value?.toString();
    double d(Sheet sh, int r, int c) => double.parse(v(sh, r, c)!);

    final inv = excel.tables['Invoice Register']!;
    expect(inv.rows.length, 4 + 1 + 3 + 1); // info, header, 3 invoices, total
    expect(v(inv, 4, 1), 'Purchase No');
    expect(v(inv, 5, 3), 'K-102', reason: 'newest first');
    final total = inv.rows.last;
    expect(total[1]?.value.toString(), contains('TOTAL (3 invoices)'));
    expect(d(inv, 8, 10), 169900); // taxable
    expect(d(inv, 8, 11), 14072.5); // CGST
    expect(d(inv, 8, 13), 1800); // IGST
    expect(d(inv, 8, 16), 202845); // total

    final items = excel.tables['Item Details']!;
    expect(items.rows.length, 4 + 1 + 4,
        reason: '4 item rows; freight is not an item');
    final hsns = [for (var r = 5; r < 9; r++) v(items, r, 4)];
    expect(hsns..sort(), ['25051000', '25232910', '72142010', '72142010']);

    final rates = excel.tables['By GST Rate']!;
    expect(rates.rows.length, 4 + 1 + 2 + 1);
    expect(d(rates, 7, 2), 169900);
    expect(d(rates, 7, 6), 29945);

    final sup = excel.tables['By Supplier']!;
    expect(v(sup, 5, 1), 'Ganesh Traders');
    expect(d(sup, 5, 6), 191045);
  });
}
