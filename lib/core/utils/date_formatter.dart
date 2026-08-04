import 'package:intl/intl.dart';

/// Date and datetime formatting helpers for NexLedger.
class DateFormatter {
  DateFormatter._();

  static final _dateFormatter = DateFormat('dd MMM yyyy'); // 04 Aug 2026
  static final _dateTimeFormatter = DateFormat('dd MMM yyyy, hh:mm a');
  static final _shortDateFormatter = DateFormat('dd/MM/yyyy');
  static final _monthYearFormatter = DateFormat('MMM yyyy');
  static final _dbDateFormatter = DateFormat('yyyy-MM-dd');

  /// Display date: 04 Aug 2026
  static String format(DateTime date) => _dateFormatter.format(date);

  /// Display datetime: 04 Aug 2026, 02:30 PM
  static String formatDateTime(DateTime dt) => _dateTimeFormatter.format(dt);

  /// Short date: 04/08/2026
  static String formatShort(DateTime date) => _shortDateFormatter.format(date);

  /// Month + year: Aug 2026
  static String formatMonthYear(DateTime date) =>
      _monthYearFormatter.format(date);

  /// ISO date for DB queries: 2026-08-04
  static String toDbString(DateTime date) => _dbDateFormatter.format(date);

  /// Parse a db date string back to DateTime
  static DateTime fromDbString(String s) => _dbDateFormatter.parse(s);

  /// Returns true if two DateTimes refer to the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
