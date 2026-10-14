import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/simple_gst.dart';
import 'package:nex_ledger/features/cash_book/data/cash_book_repository.dart';
import 'package:nex_ledger/features/equipment/data/equipment_repository.dart';
import 'package:nex_ledger/features/reports/data/ledger_repository.dart';
import 'package:nex_ledger/features/reports/data/report_repository.dart';
import 'package:nex_ledger/features/subcontract/data/subcontract_repository.dart';

void main() {
  late AppDatabase db;
  late CashBookRepository cashBook;
  late SubcontractRepository sub;
  late EquipmentRepository equipment;
  late ReportRepository reports;
  late int project;

  Future<double> cash() => db.transactionDao.watchCashBalance().first;
  Future<ProjectPnl> pnl() => reports.getProjectPnl(project);
  Future<List<Transaction>> txns() => db.select(db.transactions).get();

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    cashBook = CashBookRepository(db.transactionDao);
    sub = SubcontractRepository(db.subcontractDao, db.transactionDao, db);
    equipment = EquipmentRepository(db.equipmentDao, db.transactionDao, db);
    reports = ReportRepository(
        db.transactionDao, db.projectDao, db.depositDao, db.expenseCategoryDao);
    project = await db.projectDao.insertProject(ProjectsCompanion.insert(
        code: 'PRJ-1',
        name: 'Villa',
        type: ProjectType.project,
        status: ProjectStatus.active,
        startDate: DateTime(2026, 1, 1)));
  });

  tearDown(() async => db.close());

  group('SimpleGst', () {
    test('taxable + rate gives the split and the total', () {
      final local = calcSimpleGst(taxable: 10000, rate: 18, interState: false);
      expect([local.cgst, local.sgst, local.igst, local.gst, local.total],
          [900, 900, 0, 1800, 11800]);
      final inter = calcSimpleGst(taxable: 10000, rate: 18, interState: true);
      expect([inter.cgst, inter.sgst, inter.igst, inter.total],
          [0, 0, 1800, 11800]);
      expect(calcSimpleGst(taxable: 1000, rate: 5, interState: false).cgst, 25);
    });

    test('no rate means no GST', () {
      final none = calcSimpleGst(taxable: 500, rate: 0, interState: false);
      expect([none.hasGst, none.total], [false, 500]);
      expect(calcSimpleGst(taxable: -5, rate: 18, interState: false).total, 0);
    });
  });

  group('Cash Book expense with optional GST', () {
    test('GST on: amount is the value before GST, posted = value + GST',
        () async {
      await cashBook.addExpense(
        projectId: project,
        date: DateTime(2026, 9, 1),
        amount: 10000,
        gst: const ExpenseGstInput(
            rate: 18,
            partyName: 'Sri Hardware',
            partyGstin: '32aaaaa0000a1z5',
            billNo: 'B-9'),
      );
      final t = (await txns()).single;
      expect(t.amount, 11800);
      expect(await cash(), -11800);
      expect((await pnl()).expenses, 11800, reason: 'GST is part of the cost');

      final g = (await cashBook.getGstDetail(t.id))!;
      expect([
        g.taxableAmount,
        g.gstRate,
        g.cgstAmount,
        g.sgstAmount,
        g.igstAmount
      ], [
        10000,
        18,
        900,
        900,
        0
      ]);
      expect([g.kind, g.partyName, g.partyGstin, g.billNo],
          [TxnGstKind.expense, 'Sri Hardware', '32AAAAA0000A1Z5', 'B-9']);
    });

    test('inter-state is all IGST', () async {
      await cashBook.addExpense(
          projectId: project,
          date: DateTime(2026, 9, 1),
          amount: 10000,
          gst: const ExpenseGstInput(rate: 18, interState: true));
      final g = (await db.select(db.transactionGsts).get()).single;
      expect([g.cgstAmount, g.sgstAmount, g.igstAmount, g.isInterState],
          [0, 0, 1800, true]);
    });

    test('GST off (or rate 0): exactly as before, no detail row', () async {
      await cashBook.addExpense(
          projectId: project, date: DateTime(2026, 9, 1), amount: 5000);
      await cashBook.addExpense(
          projectId: project,
          date: DateTime(2026, 9, 2),
          amount: 700,
          gst: const ExpenseGstInput(rate: 0));
      expect((await txns()).map((t) => t.amount).toList(), [5000, 700]);
      expect(await db.select(db.transactionGsts).get(), isEmpty);
      expect(await cash(), -5700);
    });

    test('edit: change the rate, then switch GST off, then delete cleans up',
        () async {
      await cashBook.addExpense(
          projectId: project,
          date: DateTime(2026, 9, 1),
          amount: 10000,
          gst: const ExpenseGstInput(rate: 18));
      final id = (await txns()).single.id;

      Future<void> edit({required double amount, ExpenseGstInput? gst}) =>
          cashBook.updateTransaction(
              id: id,
              projectId: project,
              date: DateTime(2026, 9, 1),
              type: TransactionType.expense,
              amount: amount,
              gst: gst);

      await edit(amount: 10000, gst: const ExpenseGstInput(rate: 12));
      expect((await txns()).single.amount, 11200);
      expect((await db.select(db.transactionGsts).get()).single.gstRate, 12);
      expect(await cash(), -11200);

      await edit(amount: 8000); // GST switched off: 8,000 as typed
      expect((await txns()).single.amount, 8000);
      expect(await db.select(db.transactionGsts).get(), isEmpty);

      await edit(
          amount: 8000, gst: const ExpenseGstInput(rate: 5)); // and back on
      expect((await txns()).single.amount, 8400);

      await cashBook.deleteTransaction(id);
      expect(await txns(), isEmpty);
      expect(await db.select(db.transactionGsts).get(), isEmpty);
      expect(await cash(), 0);
    });

    test('GST detail is only kept for expenses', () async {
      await cashBook.addIncome(
          projectId: project, date: DateTime(2026, 9, 1), amount: 1000);
      final id = (await txns()).single.id;
      await cashBook.updateTransaction(
          id: id,
          projectId: project,
          date: DateTime(2026, 9, 1),
          type: TransactionType.income,
          amount: 1000,
          gst: const ExpenseGstInput(rate: 18));
      expect((await txns()).single.amount, 1000);
      expect(await db.select(db.transactionGsts).get(), isEmpty);
    });
  });

  group('Machinery rent with optional GST', () {
    test('rent of ₹50,000 + 18% posts ₹59,000 as an expense with a GST detail',
        () async {
      final id = await equipment.recordEquipmentRentalPayment(
        projectId: project,
        equipmentId: 1,
        paymentAmount: 50000,
        paymentDate: DateTime(2026, 9, 10),
        paymentMode: PaymentMode.bank,
        gstRate: 18,
        partyName: 'Balaji Earthmovers',
        partyGstin: '33AAAAA0000A1Z5',
        referenceNo: 'RENT-77',
      );
      final t = (await txns()).single;
      expect([t.id, t.amount, t.type], [id, 59000, TransactionType.expense]);
      expect(await cash(), -59000);
      expect((await pnl()).expenses, 59000);
      final g = (await db.select(db.transactionGsts).get()).single;
      expect([g.kind, g.taxableAmount, g.cgstAmount, g.sgstAmount, g.billNo],
          [TxnGstKind.equipment, 50000, 4500, 4500, 'RENT-77']);
    });

    test('without GST it posts exactly what it did before', () async {
      await equipment.recordEquipmentRentalPayment(
          projectId: project,
          equipmentId: 1,
          paymentAmount: 50000,
          paymentDate: DateTime(2026, 9, 10),
          paymentMode: PaymentMode.cash);
      expect((await txns()).single.amount, 50000);
      expect(await db.select(db.transactionGsts).get(), isEmpty);
    });
  });

  group('Subcontract bill with optional GST', () {
    late int woId, subId;

    setUp(() async {
      subId =
          await sub.addSubcontractor(name: 'Murugan Gang', trade: 'Plastering');
      woId = await sub.createWorkOrder(
        orderNumber: 'WO-1',
        projectId: project,
        subcontractorId: subId,
        title: 'Plastering',
        trade: 'Plastering',
        unit: 'Sq.ft',
        agreedRate: 50,
        estimatedQuantity: 5000,
        retentionPercentage: 5,
        startDate: DateTime(2026, 8, 1),
      );
    });

    test(
        'GST 18%: cost = bill + GST, retention on the bill only, payable includes GST',
        () async {
      // 1,000 sq.ft × ₹50 = ₹50,000; retention 5% = 2,500; GST 18% = 9,000
      await sub.recordMeasurementBill(
          workOrderId: woId,
          billNumber: 'MB-01',
          date: DateTime(2026, 9, 1),
          measuredQuantity: 1000,
          unitRate: 50,
          gstRate: 18,
          partyGstin: '33aaaaa0000a1z5');

      final bill = (await db.select(db.measurementBills).get()).single;
      expect([
        bill.grossAmount,
        bill.retentionAmount,
        bill.cgstAmount,
        bill.sgstAmount,
        bill.igstAmount
      ], [
        50000,
        2500,
        4500,
        4500,
        0
      ]);
      expect(bill.netAmount, 56500); // 50,000 - 2,500 + 9,000
      expect([bill.gstRate, bill.partyGstin], [18, '33AAAAA0000A1Z5']);

      final t = (await txns()).single;
      expect([t.amount, t.type, t.affectsPnl, t.affectsCash],
          [59000, TransactionType.subcontractBill, true, false]);
      expect((await pnl()).expenses, 59000,
          reason: 'a subcontract bill is a COST, never income');
      expect((await pnl()).income, 0);
      expect(await cash(), 0);

      var wo = (await sub.watchWorkOrderFinancialSummary(woId).first)!;
      expect([
        wo.totalGrossCertified,
        wo.totalRetentionHeld,
        wo.totalNetBillable,
        wo.currentNetDue
      ], [
        50000,
        2500,
        56500,
        56500
      ]);

      await sub.recordSubcontractPayment(
          subcontractorId: subId,
          workOrderId: woId,
          projectId: project,
          amount: 20000,
          paymentDate: DateTime(2026, 9, 5),
          paymentMode: PaymentMode.bank);
      wo = (await sub.watchWorkOrderFinancialSummary(woId).first)!;
      expect([wo.totalPaid, wo.currentNetDue], [20000, 36500]);
      expect(await cash(), -20000);

      final summary = (await sub.watchAllSubcontractorSummaries().first).single;
      expect([summary.totalNetBillable, summary.currentNetDue], [56500, 36500]);

      final ledger =
          await LedgerRepository(db).watchSubcontractorLedger(subId).first;
      expect(ledger.summary.totalCredit, 56500);
      expect(ledger.summary.closingBalance, 36500);
    });

    test('inter-state is IGST; the payable is the same', () async {
      await sub.recordMeasurementBill(
          workOrderId: woId,
          billNumber: 'MB-01',
          date: DateTime(2026, 9, 1),
          measuredQuantity: 1000,
          unitRate: 50,
          gstRate: 18,
          interState: true);
      final bill = (await db.select(db.measurementBills).get()).single;
      expect([
        bill.cgstAmount,
        bill.sgstAmount,
        bill.igstAmount,
        bill.isInterState,
        bill.netAmount
      ], [
        0,
        0,
        9000,
        true,
        56500
      ]);
    });

    test('without GST nothing changes (old behaviour, old numbers)', () async {
      await sub.recordMeasurementBill(
          workOrderId: woId,
          billNumber: 'MB-01',
          date: DateTime(2026, 9, 1),
          measuredQuantity: 1000,
          unitRate: 50);
      final bill = (await db.select(db.measurementBills).get()).single;
      expect([bill.netAmount, bill.gstRate, bill.cgstAmount, bill.partyGstin],
          [47500, 0, 0, null]);
      expect((await txns()).single.amount, 50000);
      final wo = (await sub.watchWorkOrderFinancialSummary(woId).first)!;
      expect(wo.currentNetDue, 47500);
    });

    test('a GST bill and a plain bill on the same work order add up', () async {
      await sub.recordMeasurementBill(
          workOrderId: woId,
          billNumber: 'MB-01',
          date: DateTime(2026, 9, 1),
          measuredQuantity: 1000,
          unitRate: 50,
          gstRate: 18);
      await sub.recordMeasurementBill(
          workOrderId: woId,
          billNumber: 'MB-02',
          date: DateTime(2026, 9, 15),
          measuredQuantity: 400,
          unitRate: 50);
      final wo = (await sub.watchWorkOrderFinancialSummary(woId).first)!;
      // bill 1: 50,000 - 2,500 + 9,000 = 56,500 ; bill 2: 20,000 - 1,000 = 19,000
      expect(
          [wo.totalGrossCertified, wo.totalRetentionHeld, wo.totalNetBillable],
          [70000, 3500, 75500]);
      expect((await pnl()).expenses, 59000 + 20000);
    });
  });
}
