import 'package:flutter/material.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/financial_year.dart';

export 'package:nex_ledger/core/utils/financial_year.dart';

/// Filters for the Purchase Register. Every field is optional (null = all).
class PurchaseFilter {
  final int? projectId;
  final int? vendorId;
  final PaymentStatus? status;

  /// Inclusive date range on the bill date.
  final DateTimeRange? dateRange;

  const PurchaseFilter({
    this.projectId,
    this.vendorId,
    this.status,
    this.dateRange,
  });

  bool get isEmpty =>
      projectId == null &&
      vendorId == null &&
      status == null &&
      dateRange == null;

  PurchaseFilter copyWith({
    int? projectId,
    int? vendorId,
    PaymentStatus? status,
    DateTimeRange? dateRange,
    bool clearProject = false,
    bool clearVendor = false,
    bool clearStatus = false,
    bool clearDateRange = false,
  }) =>
      PurchaseFilter(
        projectId: clearProject ? null : (projectId ?? this.projectId),
        vendorId: clearVendor ? null : (vendorId ?? this.vendorId),
        status: clearStatus ? null : (status ?? this.status),
        dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      );
}

/// Amount still to be paid on a bill (never negative).
double purchaseBalance(PurchaseDetail d) {
  final due = d.transaction.amount - d.purchase.paidAmount;
  return due > 0.005 ? due : 0.0;
}

/// Bills matching [filter], newest first.
List<PurchaseDetail> applyPurchaseFilter(
    List<PurchaseDetail> all, PurchaseFilter filter) {
  DateTime? from;
  DateTime? toExclusive;
  if (filter.dateRange != null) {
    final r = filter.dateRange!;
    from = DateTime(r.start.year, r.start.month, r.start.day);
    toExclusive = DateTime(r.end.year, r.end.month, r.end.day)
        .add(const Duration(days: 1));
  }
  final result = all.where((d) {
    if (filter.projectId != null && d.project.id != filter.projectId) {
      return false;
    }
    if (filter.vendorId != null && d.vendor.id != filter.vendorId) {
      return false;
    }
    if (filter.status != null && d.purchase.paymentStatus != filter.status) {
      return false;
    }
    if (from != null && d.transaction.date.isBefore(from)) return false;
    if (toExclusive != null && !d.transaction.date.isBefore(toExclusive)) {
      return false;
    }
    return true;
  }).toList()
    ..sort((a, b) {
      final byDate = b.transaction.date.compareTo(a.transaction.date);
      return byDate != 0 ? byDate : b.purchase.id.compareTo(a.purchase.id);
    });
  return result;
}

class PurchaseTotals {
  final int count;
  final double total;
  final double paid;
  final double balance;
  const PurchaseTotals({
    required this.count,
    required this.total,
    required this.paid,
    required this.balance,
  });
}

PurchaseTotals purchaseTotals(List<PurchaseDetail> rows) {
  double total = 0, paid = 0, balance = 0;
  for (final d in rows) {
    total += d.transaction.amount;
    paid += d.purchase.paidAmount;
    balance += purchaseBalance(d);
  }
  return PurchaseTotals(
      count: rows.length, total: total, paid: paid, balance: balance);
}

/// One shop's totals in the shop-wise view.
class ShopSummary {
  final Vendor vendor;
  final int bills;
  final double total;
  final double paid;
  final double balance;
  final DateTime lastBillDate;
  const ShopSummary({
    required this.vendor,
    required this.bills,
    required this.total,
    required this.paid,
    required this.balance,
    required this.lastBillDate,
  });
}

/// Groups [rows] by shop. Biggest buying first.
List<ShopSummary> summarizeByShop(List<PurchaseDetail> rows) {
  final byVendor = <int, List<PurchaseDetail>>{};
  for (final d in rows) {
    byVendor.putIfAbsent(d.vendor.id, () => []).add(d);
  }
  final result = <ShopSummary>[];
  byVendor.forEach((_, list) {
    final t = purchaseTotals(list);
    final last = list
        .map((d) => d.transaction.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    result.add(ShopSummary(
      vendor: list.first.vendor,
      bills: t.count,
      total: t.total,
      paid: t.paid,
      balance: t.balance,
      lastBillDate: last,
    ));
  });
  result.sort((a, b) {
    final byTotal = b.total.compareTo(a.total);
    return byTotal != 0
        ? byTotal
        : a.vendor.name.toLowerCase().compareTo(b.vendor.name.toLowerCase());
  });
  return result;
}

/// Plain-words description of the active filters (used in the Excel header).
String describePurchaseFilter(
  PurchaseFilter f, {
  String? projectName,
  String? vendorName,
  required String Function(DateTime) formatDate,
}) {
  final parts = <String>[
    'Project: ${f.projectId == null ? 'All' : (projectName ?? '#${f.projectId}')}',
    'Shop: ${f.vendorId == null ? 'All' : (vendorName ?? '#${f.vendorId}')}',
    'Status: ${f.status == null ? 'All' : f.status!.displayName}',
    f.dateRange == null
        ? 'Period: All time'
        : 'Period: ${formatDate(f.dateRange!.start)} to ${formatDate(f.dateRange!.end)}',
  ];
  return parts.join('  |  ');
}
