import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/gst_calculator.dart';

/// Where an input-GST entry came from.
enum InputGstSource {
  purchases('Purchases'),
  subcontract('Subcontractors'),
  machinery('Machinery Rent'),
  expenses('Other Expenses');

  final String label;
  const InputGstSource(this.label);
}

/// One bill that carried GST, from any of the four sources.
class InputGstEntry {
  final DateTime date;
  final int projectId;
  final String projectCode;
  final String projectName;
  final InputGstSource source;

  /// Who charged the GST (supplier, subcontractor, lessor…).
  final String party;
  final String? gstin;

  /// Our document number and/or the party's bill number.
  final String docNo;

  /// Extra context: category, work order title…
  final String? detail;

  final double taxable;
  final double cgst;
  final double sgst;
  final double igst;

  const InputGstEntry({
    required this.date,
    required this.projectId,
    required this.projectCode,
    required this.projectName,
    required this.source,
    required this.party,
    required this.gstin,
    required this.docNo,
    required this.detail,
    required this.taxable,
    required this.cgst,
    required this.sgst,
    required this.igst,
  });

  double get gst => fromPaise(toPaise(cgst) + toPaise(sgst) + toPaise(igst));
  double get total => fromPaise(toPaise(taxable) + toPaise(gst));
}

/// The expense category whose bills are treated as machinery rent.
const String kMachineryRentCategory = 'Equipment Rental';

/// Collects every bill that carries GST: purchase invoices, subcontract
/// bills, and expenses / rent saved with a GST detail.
class InputGstRepository {
  final AppDatabase _db;
  InputGstRepository(this._db);

  Stream<List<InputGstEntry>> watchEntries() => _db
      .customSelect('SELECT 1', readsFrom: {
        _db.purchaseInvoices,
        _db.purchases,
        _db.measurementBills,
        _db.workOrders,
        _db.subcontractors,
        _db.transactionGsts,
        _db.transactions,
        _db.projects,
        _db.vendors,
        _db.expenseCategories,
      })
      .watch()
      .asyncMap((_) => loadEntries());

  Future<List<InputGstEntry>> loadEntries() async {
    final projects = {
      for (final p in await _db.select(_db.projects).get()) p.id: p
    };
    final entries = <InputGstEntry>[];

    InputGstEntry make({
      required DateTime date,
      required int projectId,
      required InputGstSource source,
      required String party,
      String? gstin,
      required String docNo,
      String? detail,
      required double taxable,
      required double cgst,
      required double sgst,
      required double igst,
    }) {
      final p = projects[projectId];
      return InputGstEntry(
        date: date,
        projectId: projectId,
        projectCode: p?.code ?? '—',
        projectName: p?.name ?? 'Project #$projectId',
        source: source,
        party: party,
        gstin: gstin,
        docNo: docNo,
        detail: detail,
        taxable: taxable,
        cgst: cgst,
        sgst: sgst,
        igst: igst,
      );
    }

    // ── 1. Purchase invoices: one entry per invoice, GST-bearing items only ──
    final vendors = {
      for (final v in await _db.select(_db.vendors).get()) v.id: v
    };
    final invoices = await _db.select(_db.purchaseInvoices).get();
    final lines = await (_db.select(_db.purchases)
          ..where((p) => p.invoiceId.isNotNull())
          ..where((p) => p.isOtherCharge.equals(false)))
        .get();
    final byInvoice = <int, List<Purchase>>{};
    for (final l in lines) {
      byInvoice.putIfAbsent(l.invoiceId!, () => []).add(l);
    }
    for (final inv in invoices) {
      int t = 0, c = 0, s = 0, i = 0;
      var any = false;
      for (final l in byInvoice[inv.id] ?? const <Purchase>[]) {
        if (l.cgstAmount + l.sgstAmount + l.igstAmount <= 0) continue;
        any = true;
        t += toPaise(l.taxableAmount);
        c += toPaise(l.cgstAmount);
        s += toPaise(l.sgstAmount);
        i += toPaise(l.igstAmount);
      }
      if (!any) continue;
      entries.add(make(
        date: inv.date,
        projectId: inv.projectId,
        source: InputGstSource.purchases,
        party: vendors[inv.vendorId]?.name ?? 'Supplier',
        gstin: inv.supplierGstin,
        docNo: [
          inv.purchaseNo,
          if ((inv.invoiceNo ?? '').isNotEmpty) inv.invoiceNo!
        ].join(' · '),
        taxable: fromPaise(t),
        cgst: fromPaise(c),
        sgst: fromPaise(s),
        igst: fromPaise(i),
      ));
    }

    // ── 2. Subcontractor bills ──
    final wos = {
      for (final w in await _db.select(_db.workOrders).get()) w.id: w
    };
    final subs = {
      for (final s in await _db.select(_db.subcontractors).get()) s.id: s
    };
    final bills = await _db.select(_db.measurementBills).get();
    for (final b in bills) {
      if (b.cgstAmount + b.sgstAmount + b.igstAmount <= 0) continue;
      final wo = wos[b.workOrderId];
      if (wo == null) continue;
      entries.add(make(
        date: b.date,
        projectId: wo.projectId,
        source: InputGstSource.subcontract,
        party: subs[wo.subcontractorId]?.name ?? 'Subcontractor',
        gstin: b.partyGstin,
        docNo: b.billNumber,
        detail: wo.title,
        taxable: b.grossAmount,
        cgst: b.cgstAmount,
        sgst: b.sgstAmount,
        igst: b.igstAmount,
      ));
    }

    // ── 3 + 4. Expenses and machinery rent saved with a GST detail ──
    final gsts = await _db.select(_db.transactionGsts).get();
    if (gsts.isNotEmpty) {
      final txns = {
        for (final t in await _db.select(_db.transactions).get()) t.id: t
      };
      final cats = {
        for (final c in await _db.select(_db.expenseCategories).get())
          c.id: c.subCategory
      };
      for (final g in gsts) {
        final t = txns[g.transactionId];
        if (t == null) continue;
        final category =
            t.expenseCategoryId != null ? cats[t.expenseCategoryId] : null;
        final isRent = g.kind == TxnGstKind.equipment ||
            category == kMachineryRentCategory;
        entries.add(make(
          date: t.date,
          projectId: t.projectId,
          source: isRent ? InputGstSource.machinery : InputGstSource.expenses,
          party: (g.partyName ?? '').isNotEmpty
              ? g.partyName!
              : (category ?? 'Expense'),
          gstin: g.partyGstin,
          docNo: g.billNo ?? t.referenceNo ?? '—',
          detail: category,
          taxable: g.taxableAmount,
          cgst: g.cgstAmount,
          sgst: g.sgstAmount,
          igst: g.igstAmount,
        ));
      }
    }

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }
}

// ─── Filtering and totals (pure) ─────────────────────────────────────────────

class InputGstFilter {
  final int? projectId;
  final InputGstSource? source;
  final DateTimeRange? dateRange;
  const InputGstFilter({this.projectId, this.source, this.dateRange});

  bool get isEmpty => projectId == null && source == null && dateRange == null;

  InputGstFilter copyWith({
    int? projectId,
    InputGstSource? source,
    DateTimeRange? dateRange,
    bool clearProject = false,
    bool clearSource = false,
    bool clearDateRange = false,
  }) =>
      InputGstFilter(
        projectId: clearProject ? null : (projectId ?? this.projectId),
        source: clearSource ? null : (source ?? this.source),
        dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      );
}

List<InputGstEntry> applyInputGstFilter(
    List<InputGstEntry> all, InputGstFilter f) {
  DateTime? from;
  DateTime? toExclusive;
  if (f.dateRange != null) {
    final r = f.dateRange!;
    from = DateTime(r.start.year, r.start.month, r.start.day);
    toExclusive = DateTime(r.end.year, r.end.month, r.end.day)
        .add(const Duration(days: 1));
  }
  return all.where((e) {
    if (f.projectId != null && e.projectId != f.projectId) return false;
    if (f.source != null && e.source != f.source) return false;
    if (from != null && e.date.isBefore(from)) return false;
    if (toExclusive != null && !e.date.isBefore(toExclusive)) return false;
    return true;
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}

class InputGstTotals {
  final int entries;
  final double taxable;
  final double cgst;
  final double sgst;
  final double igst;
  const InputGstTotals({
    required this.entries,
    required this.taxable,
    required this.cgst,
    required this.sgst,
    required this.igst,
  });

  double get gst => fromPaise(toPaise(cgst) + toPaise(sgst) + toPaise(igst));
  double get total => fromPaise(toPaise(taxable) + toPaise(gst));
}

InputGstTotals inputGstTotals(Iterable<InputGstEntry> rows) {
  int t = 0, c = 0, s = 0, i = 0, n = 0;
  for (final e in rows) {
    n++;
    t += toPaise(e.taxable);
    c += toPaise(e.cgst);
    s += toPaise(e.sgst);
    i += toPaise(e.igst);
  }
  return InputGstTotals(
    entries: n,
    taxable: fromPaise(t),
    cgst: fromPaise(c),
    sgst: fromPaise(s),
    igst: fromPaise(i),
  );
}

/// One project's input GST, with the split by source.
class ProjectGstSummary {
  final int projectId;
  final String projectCode;
  final String projectName;
  final InputGstTotals totals;
  final Map<InputGstSource, double> gstBySource;

  const ProjectGstSummary({
    required this.projectId,
    required this.projectCode,
    required this.projectName,
    required this.totals,
    required this.gstBySource,
  });
}

/// Input GST for each project, biggest GST first.
List<ProjectGstSummary> summarizeByProject(List<InputGstEntry> rows) {
  final groups = <int, List<InputGstEntry>>{};
  for (final e in rows) {
    groups.putIfAbsent(e.projectId, () => []).add(e);
  }
  final result = <ProjectGstSummary>[];
  groups.forEach((id, list) {
    final bySource = <InputGstSource, double>{};
    for (final s in InputGstSource.values) {
      final part = inputGstTotals(list.where((e) => e.source == s));
      if (part.entries > 0) bySource[s] = part.gst;
    }
    result.add(ProjectGstSummary(
      projectId: id,
      projectCode: list.first.projectCode,
      projectName: list.first.projectName,
      totals: inputGstTotals(list),
      gstBySource: bySource,
    ));
  });
  result.sort((a, b) {
    final byGst = b.totals.gst.compareTo(a.totals.gst);
    return byGst != 0 ? byGst : a.projectCode.compareTo(b.projectCode);
  });
  return result;
}

class SourceGstSummary {
  final InputGstSource source;
  final InputGstTotals totals;
  const SourceGstSummary(this.source, this.totals);
}

/// Totals per source (only sources that have entries), in a fixed order.
List<SourceGstSummary> summarizeBySource(List<InputGstEntry> rows) => [
      for (final s in InputGstSource.values)
        if (rows.any((e) => e.source == s))
          SourceGstSummary(s, inputGstTotals(rows.where((e) => e.source == s))),
    ];

/// Plain-words description of the active filters (printed in the Excel file).
String describeInputGstFilter(
  InputGstFilter f, {
  String? projectName,
  required String Function(DateTime) formatDate,
}) =>
    [
      'Project: ${f.projectId == null ? 'All' : (projectName ?? '#${f.projectId}')}',
      'Source: ${f.source?.label ?? 'All'}',
      f.dateRange == null
          ? 'Period: All time'
          : 'Period: ${formatDate(f.dateRange!.start)} to ${formatDate(f.dateRange!.end)}',
    ].join('  |  ');
