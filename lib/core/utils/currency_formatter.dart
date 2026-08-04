import 'package:intl/intl.dart';

/// Formats monetary amounts for display in NexLedger.
/// Uses Indian locale (₹) with 2 decimal places.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _compactFormatter = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 1,
  );

  /// Returns formatted string: ₹1,23,456.00
  static String format(double amount) => _formatter.format(amount);

  /// Returns compact string: ₹1.2L, ₹45K, etc.
  static String compact(double amount) => _compactFormatter.format(amount);

  /// Returns formatted string with sign: +₹1,000.00 / -₹500.00
  static String formatSigned(double amount) {
    final formatted = _formatter.format(amount.abs());
    return amount >= 0 ? '+$formatted' : '-$formatted';
  }
}
