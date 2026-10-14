import 'package:flutter/material.dart';

/// Indian financial year (1 Apr – 31 Mar) that contains [now].
DateTimeRange financialYearRange(DateTime now) {
  final startYear = now.month >= 4 ? now.year : now.year - 1;
  return DateTimeRange(
    start: DateTime(startYear, 4, 1),
    end: DateTime(startYear + 1, 3, 31),
  );
}

/// "2026-27" for the financial year that contains [now].
String financialYearLabel(DateTime now) {
  final r = financialYearRange(now);
  final endShort = (r.end.year % 100).toString().padLeft(2, '0');
  return '${r.start.year}-$endShort';
}

/// "26-27", the short form used inside document numbers.
String financialYearShort(DateTime now) {
  final r = financialYearRange(now);
  String two(int y) => (y % 100).toString().padLeft(2, '0');
  return '${two(r.start.year)}-${two(r.end.year)}';
}
