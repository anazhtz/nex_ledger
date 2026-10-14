import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/utils/gst_calculator.dart';
import 'package:nex_ledger/core/utils/gst_utils.dart';

void main() {
  group('line calculation (hand-checked)', () {
    test('TMT steel 2,500 kg @ ₹62, 18% GST, local', () {
      final r = calcGstLine(
          const GstLineInput(qty: 2500, rate: 62, gstRate: 18),
          interState: false);
      expect(r.gross, 155000);
      expect(r.taxable, 155000);
      expect(r.cgst, 13950);
      expect(r.sgst, 13950);
      expect(r.igst, 0);
      expect(r.total, 182900);
    });

    test('same item inter-state is all IGST', () {
      final r = calcGstLine(
          const GstLineInput(qty: 2500, rate: 62, gstRate: 18),
          interState: true);
      expect([r.cgst, r.sgst, r.igst], [0, 0, 27900]);
      expect(r.total, 182900);
    });

    test('discount comes off before GST', () {
      // 200 bags × 410 = 82,000; 10% discount = 73,800; 28% GST = 20,664
      final r = calcGstLine(
          const GstLineInput(
              qty: 200, rate: 410, discountPercent: 10, gstRate: 28),
          interState: false);
      expect(r.discount, 8200);
      expect(r.taxable, 73800);
      expect(r.cgst, 10332);
      expect(r.sgst, 10332);
      expect(r.total, 94464);
    });

    test('5% splits to 2.5% + 2.5%', () {
      final r = calcGstLine(const GstLineInput(qty: 15, rate: 60, gstRate: 5),
          interState: false);
      expect(r.taxable, 900);
      expect([r.cgst, r.sgst], [22.5, 22.5]);
      expect(r.total, 945);
    });

    test('zero-rated line has no GST', () {
      final r =
          calcGstLine(const GstLineInput(qty: 3, rate: 100), interState: false);
      expect([r.gst, r.total], [0, 300]);
    });

    test('fractions round to the paisa, never drift', () {
      // 7 × 33.33 = 233.31; 12% = 27.9972 -> 28.00 total GST (14.00 + 14.00)
      final r = calcGstLine(
          const GstLineInput(qty: 7, rate: 33.33, gstRate: 12),
          interState: false);
      expect(r.taxable, 233.31);
      expect(r.cgst, 14.0);
      expect(r.sgst, 14.0);
      expect(r.total, 261.31);
    });

    test('bad input is treated safely', () {
      final r = calcGstLine(
          const GstLineInput(
              qty: -5, rate: -1, discountPercent: 250, gstRate: -3),
          interState: false);
      expect(r.total, 0);
    });
  });

  group('invoice totals', () {
    GstLineResult line(double q, double r, double g, {bool inter = false}) =>
        calcGstLine(GstLineInput(qty: q, rate: r, gstRate: g),
            interState: inter);

    test('4 materials + freight, checked line by line', () {
      final lines = [
        line(2500, 62, 18), // 155,000 + 27,900 = 182,900
        line(200, 410, 18), // 82,000 + 14,760 = 96,760
        line(15, 60, 5), // 900 + 45 = 945
        line(5000, 6.8, 18), // 34,000 + 6,120 = 40,120
      ];
      final t = calcGstInvoice(lines, charges: [3000, 1000, 0]);
      expect(t.taxable, 271900);
      // GST: 27,900 + 14,760 + 45 + 6,120 = 48,825 -> CGST 24,412.50 = SGST
      expect(t.totalGst, 48825);
      expect(t.cgst, 24412.5);
      expect(t.sgst, 24412.5);
      expect(t.igst, 0);
      expect(t.otherCharges, 4000);
      // 271,900 + 48,825 + 4,000 = 324,725 exactly
      expect(t.grandTotal, 324725);
      expect(t.roundOff, 0);
      expect(t.itemsTotal, 320725);
    });

    test('round-off goes to the nearest rupee and is under one rupee', () {
      final t = calcGstInvoice([line(1, 100.40, 0)]);
      expect(t.roundOff, -0.40);
      expect(t.grandTotal, 100);
      final up = calcGstInvoice([line(1, 100.60, 0)]);
      expect(up.roundOff, 0.40);
      expect(up.grandTotal, 101);
      final half = calcGstInvoice([line(1, 100.50, 0)]);
      expect(half.grandTotal, 101);
    });

    test('round-off can be switched off', () {
      final t = calcGstInvoice([line(1, 100.40, 0)], roundOff: false);
      expect([t.roundOff, t.grandTotal], [0, 100.4]);
    });

    test('inter-state invoice carries everything as IGST', () {
      final t = calcGstInvoice([line(10, 100, 18, inter: true)]);
      expect([t.cgst, t.sgst, t.igst], [0, 0, 180]);
      expect(t.grandTotal, 1180);
    });

    test('empty invoice is zero', () {
      final t = calcGstInvoice(const []);
      expect([t.taxable, t.totalGst, t.grandTotal, t.roundOff], [0, 0, 0, 0]);
    });

    test('negative charges are ignored', () {
      final t = calcGstInvoice(const [], charges: [-50, 20]);
      expect(t.otherCharges, 20);
    });

    test('GST total equals the sum of the rows to the paisa', () {
      final rows = [for (var i = 1; i <= 25; i++) line(i * 1.3, 17.77, 12)];
      final t = calcGstInvoice(rows, roundOff: false);
      final rowSum = rows.fold<int>(0, (s, r) => s + toPaise(r.total));
      expect(toPaise(t.grandTotal), rowSum);
    });
  });

  group('allocating a payment over lines', () {
    test('fills the first line, then the next', () {
      expect(allocatePaidInOrder(150, [100, 100, 100]), [100, 50, 0]);
    });
    test('pays everything when paid >= total', () {
      expect(allocatePaidInOrder(500, [100, 100, 100]), [100, 100, 100]);
    });
    test('nothing paid', () {
      expect(allocatePaidInOrder(0, [100, 50]), [0, 0]);
    });
    test('allocations always add back up to the amount paid (paise-safe)', () {
      final lines = [0.07, 33.33, 100.01, 9.99];
      final alloc = allocatePaidInOrder(100.10, lines);
      expect(toPaise(alloc.fold<double>(0, (a, b) => a + b)), toPaise(100.10));
    });
  });

  group('GSTIN', () {
    test('a known valid GSTIN passes format, state and checksum', () {
      const g = '27AAPFU0939F1ZV';
      expect(GstUtils.hasValidFormat(g), isTrue);
      expect(GstUtils.checkCharacter(g.substring(0, 14)), 'V');
      expect(GstUtils.isValid(g), isTrue);
      expect(GstUtils.stateNameOf(g), 'Maharashtra');
    });

    test('a wrong check character or shape fails', () {
      expect(GstUtils.isValid('27AAPFU0939F1ZX'), isFalse);
      expect(GstUtils.isValid('27AAPFU0939F1Z'), isFalse); // 14 chars
      expect(GstUtils.isValid('XXAAPFU0939F1ZV'), isFalse);
      expect(GstUtils.isValid(''), isFalse);
      expect(GstUtils.isValid(null), isFalse);
    });

    test('case and spaces are forgiven', () {
      expect(GstUtils.isValid(' 27aapfu0939f1zv '), isTrue);
    });

    test('state comes from the first two digits', () {
      expect(GstUtils.stateNameOf('32AABFS1234A1Z5'), 'Kerala');
      expect(GstUtils.stateNameOf('33AAAAA0000A1Z5'), 'Tamil Nadu');
      expect(GstUtils.stateNameOf('99AAAAA0000A1Z5'), isNull);
      expect(GstUtils.stateNameOf('3'), isNull);
    });

    test('local vs inter-state is decided from both GSTINs', () {
      expect(
          GstUtils.isInterState(
              companyGstin: '32AABFS1234A1Z5',
              supplierGstin: '32AAAAA0000A1Z5'),
          isFalse);
      expect(
          GstUtils.isInterState(
              companyGstin: '32AABFS1234A1Z5',
              supplierGstin: '33AAAAA0000A1Z5'),
          isTrue);
      // unknown on either side -> treated as local
      expect(
          GstUtils.isInterState(
              companyGstin: null, supplierGstin: '33AAAAA0000A1Z5'),
          isFalse);
      expect(
          GstUtils.isInterState(
              companyGstin: '32AABFS1234A1Z5', supplierGstin: ''),
          isFalse);
    });
  });

  group('state helpers for the form', () {
    test('state name maps back to its code', () {
      expect(GstUtils.codeOfStateName('Kerala'), '32');
      expect(GstUtils.codeOfStateName(' tamil nadu '), '33');
      expect(GstUtils.codeOfStateName('Atlantis'), isNull);
      expect(GstUtils.codeOfStateName(null), isNull);
    });

    test('supplier state: GSTIN wins, else the chosen state name', () {
      expect(
          GstUtils.supplierStateCode(
              gstin: '33AAAAA0000A1Z5', stateName: 'Kerala'),
          '33');
      expect(GstUtils.supplierStateCode(gstin: '', stateName: 'Kerala'), '32');
      expect(GstUtils.supplierStateCode(gstin: null, stateName: null), isNull);
    });

    test('inter-state only when both codes are known and differ', () {
      expect(GstUtils.isInterStateByCode('32', '33'), isTrue);
      expect(GstUtils.isInterStateByCode('32', '32'), isFalse);
      expect(GstUtils.isInterStateByCode(null, '33'), isFalse);
      expect(GstUtils.isInterStateByCode('32', null), isFalse);
    });
  });
}
