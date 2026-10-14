import 'package:flutter/material.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/gst_calculator.dart';
import 'package:nex_ledger/features/purchase/data/purchase_invoice_repository.dart';

/// Filters for the GST Purchase Register. Every field is optional.
class GstRegisterFilter {
  final int? projectId;
  final int? vendorId;

  /// Inclusive range on the purchase date.
  final DateTimeRange? dateRange;

  const GstRegisterFilter({this.projectId, this.vendorId, this.dateRange});

  bool get isEmpty =>
      projectId == null && vendorId == null && dateRange == null;

  GstRegisterFilter copyWith({
    int? projectId,
    int? vendorId,
    DateTimeRange? dateRange,
    bool clearProject = false,
    bool clearVendor = false,
    bool clearDateRange = false,
  }) =>
      GstRegisterFilter(
        projectId: clearProject ? null : (projectId ?? this.projectId),
        vendorId: clearVendor ? null : (vendorId ?? this.vendorId),
        dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      );
}

/// Invoices matching [filter], newest first.
List<InvoiceDetail> applyGstFilter(
    List<InvoiceDetail> all, GstRegisterFilter filter) {
  DateTime? from;
  DateTime? toExclusive;
  if (filter.dateRange != null) {
    final r = filter.dateRange!;
    from = DateTime(r.start.year, r.start.month, r.start.day);
    toExclusive = DateTime(r.end.year, r.end.month, r.end.day)
        .add(const Duration(days: 1));
  }
  return all.where((d) {
    final i = d.invoice;
    if (filter.projectId != null && i.projectId != filter.projectId) {
      return false;
    }
    if (filter.vendorId != null && i.vendorId != filter.vendorId) return false;
    if (from != null && i.date.isBefore(from)) return false;
    if (toExclusive != null && !i.date.isBefore(toExclusive)) return false;
    return true;
  }).toList()
    ..sort((a, b) {
      final byDate = b.invoice.date.compareTo(a.invoice.date);
      return byDate != 0 ? byDate : b.invoice.id.compareTo(a.invoice.id);
    });
}

class GstRegisterTotals {
  final int invoices;
  final double taxable;
  final double cgst;
  final double sgst;
  final double igst;
  final double otherCharges;
  final double roundOff;
  final double total;

  const GstRegisterTotals({
    required this.invoices,
    required this.taxable,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.otherCharges,
    required this.roundOff,
    required this.total,
  });

  double get totalGst => cgst + sgst + igst;
}

/// Sums the invoice headers. Works in paise so the totals tie out exactly.
GstRegisterTotals gstRegisterTotals(List<InvoiceDetail> rows) {
  int taxable = 0,
      cgst = 0,
      sgst = 0,
      igst = 0,
      other = 0,
      round = 0,
      total = 0;
  for (final d in rows) {
    final i = d.invoice;
    taxable += toPaise(i.taxableValue);
    cgst += toPaise(i.cgstAmount);
    sgst += toPaise(i.sgstAmount);
    igst += toPaise(i.igstAmount);
    other += toPaise(i.otherCharges);
    round += toPaise(i.roundOff);
    total += toPaise(i.grandTotal);
  }
  return GstRegisterTotals(
    invoices: rows.length,
    taxable: fromPaise(taxable),
    cgst: fromPaise(cgst),
    sgst: fromPaise(sgst),
    igst: fromPaise(igst),
    otherCharges: fromPaise(other),
    roundOff: fromPaise(round),
    total: fromPaise(total),
  );
}

/// One GST rate's totals across all item rows (the "rate-wise summary" an
/// accountant needs for returns). Freight / loading rows are not items and
/// are left out.
class GstRateSummary {
  final double rate;
  final int items;
  final double taxable;
  final double cgst;
  final double sgst;
  final double igst;

  const GstRateSummary({
    required this.rate,
    required this.items,
    required this.taxable,
    required this.cgst,
    required this.sgst,
    required this.igst,
  });

  double get totalGst => cgst + sgst + igst;
}

List<GstRateSummary> summarizeByRate(List<InvoiceDetail> rows) {
  final byRate = <int, List<Purchase>>{}; // keyed by rate in basis points
  for (final d in rows) {
    for (final line in d.lines) {
      if (line.purchase.isOtherCharge) continue;
      final key = (line.purchase.gstRate * 100).round();
      byRate.putIfAbsent(key, () => []).add(line.purchase);
    }
  }
  final result = <GstRateSummary>[];
  byRate.forEach((key, list) {
    int t = 0, c = 0, s = 0, i = 0;
    for (final p in list) {
      t += toPaise(p.taxableAmount);
      c += toPaise(p.cgstAmount);
      s += toPaise(p.sgstAmount);
      i += toPaise(p.igstAmount);
    }
    result.add(GstRateSummary(
      rate: key / 100,
      items: list.length,
      taxable: fromPaise(t),
      cgst: fromPaise(c),
      sgst: fromPaise(s),
      igst: fromPaise(i),
    ));
  });
  result.sort((a, b) => a.rate.compareTo(b.rate));
  return result;
}

/// One supplier's totals, grouped by supplier GSTIN as on the invoices.
class GstSupplierSummary {
  final String name;
  final String? gstin;
  final int invoices;
  final double taxable;
  final double gst;
  final double total;

  const GstSupplierSummary({
    required this.name,
    required this.gstin,
    required this.invoices,
    required this.taxable,
    required this.gst,
    required this.total,
  });
}

/// Groups by supplier (name + GSTIN). Biggest total first.
List<GstSupplierSummary> summarizeBySupplier(List<InvoiceDetail> rows) {
  final groups = <String, List<InvoiceDetail>>{};
  for (final d in rows) {
    final key = '${d.vendor.id}|${d.invoice.supplierGstin ?? ''}';
    groups.putIfAbsent(key, () => []).add(d);
  }
  final result = <GstSupplierSummary>[];
  for (final list in groups.values) {
    final t = gstRegisterTotals(list);
    result.add(GstSupplierSummary(
      name: list.first.vendor.name,
      gstin: list.first.invoice.supplierGstin,
      invoices: list.length,
      taxable: t.taxable,
      gst: t.totalGst,
      total: t.total,
    ));
  }
  result.sort((a, b) {
    final byTotal = b.total.compareTo(a.total);
    return byTotal != 0
        ? byTotal
        : a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return result;
}

/// Plain-words description of the active filters (printed in the Excel file).
String describeGstFilter(
  GstRegisterFilter f, {
  String? projectName,
  String? vendorName,
  required String Function(DateTime) formatDate,
}) =>
    [
      'Project: ${f.projectId == null ? 'All' : (projectName ?? '#${f.projectId}')}',
      'Supplier: ${f.vendorId == null ? 'All' : (vendorName ?? '#${f.vendorId}')}',
      f.dateRange == null
          ? 'Period: All time'
          : 'Period: ${formatDate(f.dateRange!.start)} to ${formatDate(f.dateRange!.end)}',
    ].join('  |  ');
