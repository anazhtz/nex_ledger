import 'package:nex_ledger/core/utils/gst_calculator.dart';

/// GST on a single amount (a subcontract bill, an expense, a rent settlement):
/// one taxable value and one rate, split as CGST + SGST or all IGST.
///
/// Same rounding as purchase invoices (whole paise, GST rounded per bill).
class SimpleGst {
  final double taxable;
  final double rate;
  final bool interState;
  final double cgst;
  final double sgst;
  final double igst;

  const SimpleGst({
    required this.taxable,
    required this.rate,
    required this.interState,
    required this.cgst,
    required this.sgst,
    required this.igst,
  });

  double get gst => fromPaise(toPaise(cgst) + toPaise(sgst) + toPaise(igst));

  /// Taxable value plus GST.
  double get total => fromPaise(toPaise(taxable) + toPaise(gst));

  bool get hasGst => rate > 0 && gst > 0;
}

SimpleGst calcSimpleGst({
  required double taxable,
  required double rate,
  required bool interState,
}) {
  final base = taxable < 0 ? 0.0 : taxable;
  final r = rate < 0 ? 0.0 : rate;
  final line = calcGstLine(
    GstLineInput(qty: 1, rate: base, gstRate: r),
    interState: interState,
  );
  return SimpleGst(
    taxable: line.taxable,
    rate: r,
    interState: interState,
    cgst: line.cgst,
    sgst: line.sgst,
    igst: line.igst,
  );
}
