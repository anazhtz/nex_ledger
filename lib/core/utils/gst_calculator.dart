/// Purchase-invoice maths, done in whole paise so totals always add up to the
/// last paisa (no floating-point drift).
///
/// Rules (standard Indian invoice practice):
///  * taxable  = qty × rate − discount%
///  * GST      = taxable × rate%, rounded to the paisa per line
///  * local    = half as CGST and half as SGST; inter-state = all IGST
///  * charges  = freight / loading / other, added without GST
///  * round-off = grand total rounded to the nearest rupee
library;

int toPaise(double rupees) => (rupees * 100).round();
double fromPaise(int paise) => paise / 100.0;

/// What the user typed for one item row.
class GstLineInput {
  final double qty;
  final double rate;
  final double discountPercent;
  final double gstRate;
  const GstLineInput({
    required this.qty,
    required this.rate,
    this.discountPercent = 0,
    this.gstRate = 0,
  });
}

/// Calculated amounts for one item row, in rupees.
class GstLineResult {
  final double gross; // qty × rate
  final double discount;
  final double taxable;
  final double cgst;
  final double sgst;
  final double igst;
  final double total; // taxable + GST

  const GstLineResult({
    required this.gross,
    required this.discount,
    required this.taxable,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.total,
  });

  double get gst => cgst + sgst + igst;
}

/// One row, calculated.
GstLineResult calcGstLine(GstLineInput input, {required bool interState}) {
  final qty = input.qty < 0 ? 0.0 : input.qty;
  final rate = input.rate < 0 ? 0.0 : input.rate;
  final discPct = input.discountPercent.clamp(0.0, 100.0);
  final gstRate = input.gstRate < 0 ? 0.0 : input.gstRate;

  final grossP = toPaise(qty * rate);
  final discP = (grossP * discPct / 100).round();
  final taxableP = grossP - discP;

  int cgstP = 0, sgstP = 0, igstP = 0;
  if (interState) {
    igstP = (taxableP * gstRate / 100).round();
  } else {
    cgstP = (taxableP * gstRate / 200).round();
    sgstP = cgstP;
  }
  final totalP = taxableP + cgstP + sgstP + igstP;

  return GstLineResult(
    gross: fromPaise(grossP),
    discount: fromPaise(discP),
    taxable: fromPaise(taxableP),
    cgst: fromPaise(cgstP),
    sgst: fromPaise(sgstP),
    igst: fromPaise(igstP),
    total: fromPaise(totalP),
  );
}

/// Whole-invoice totals, in rupees.
class GstInvoiceTotals {
  final double gross;
  final double discount;
  final double taxable; // items only (after discount)
  final double cgst;
  final double sgst;
  final double igst;
  final double otherCharges; // freight + loading + other (no GST)
  final double roundOff;
  final double grandTotal;

  const GstInvoiceTotals({
    required this.gross,
    required this.discount,
    required this.taxable,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.otherCharges,
    required this.roundOff,
    required this.grandTotal,
  });

  double get totalGst => cgst + sgst + igst;

  /// Items + GST, before charges and round-off.
  double get itemsTotal => taxable + totalGst;
}

/// Totals for a set of already-calculated rows plus extra [charges]
/// (freight, loading, other). [roundOff] true rounds the grand total to the
/// nearest rupee.
GstInvoiceTotals calcGstInvoice(
  List<GstLineResult> lines, {
  List<double> charges = const [],
  bool roundOff = true,
}) {
  int gross = 0, disc = 0, taxable = 0, cgst = 0, sgst = 0, igst = 0;
  for (final l in lines) {
    gross += toPaise(l.gross);
    disc += toPaise(l.discount);
    taxable += toPaise(l.taxable);
    cgst += toPaise(l.cgst);
    sgst += toPaise(l.sgst);
    igst += toPaise(l.igst);
  }
  var chargesP = 0;
  for (final c in charges) {
    chargesP += toPaise(c < 0 ? 0 : c);
  }
  final exact = taxable + cgst + sgst + igst + chargesP;
  var roundP = 0;
  if (roundOff) {
    final rupees = (exact / 100).round();
    roundP = rupees * 100 - exact;
  }
  return GstInvoiceTotals(
    gross: fromPaise(gross),
    discount: fromPaise(disc),
    taxable: fromPaise(taxable),
    cgst: fromPaise(cgst),
    sgst: fromPaise(sgst),
    igst: fromPaise(igst),
    otherCharges: fromPaise(chargesP),
    roundOff: fromPaise(roundP),
    grandTotal: fromPaise(exact + roundP),
  );
}

/// Spreads [paid] over bill lines in order: the first line is filled first,
/// then the next. Result has one entry per line and never exceeds a line total.
List<double> allocatePaidInOrder(double paid, List<double> lineTotals) {
  var remaining = toPaise(paid < 0 ? 0 : paid);
  final result = <double>[];
  for (final t in lineTotals) {
    final cap = toPaise(t < 0 ? 0 : t);
    final take = remaining < cap ? remaining : cap;
    result.add(fromPaise(take));
    remaining -= take;
  }
  return result;
}
