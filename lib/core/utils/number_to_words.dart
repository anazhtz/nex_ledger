/// Converts numeric monetary amounts to Indian English words.
/// Example: 12500.50 -> "Twelve Thousand Five Hundred Rupees and Fifty Paise Only"
class NumberToWordsIndian {
  NumberToWordsIndian._();

  static const List<String> _units = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];

  static const List<String> _tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];

  static String convert(double amount) {
    if (amount == 0) return 'Zero Rupees Only';

    final isNegative = amount < 0;
    final absAmount = amount.abs();

    final rupees = absAmount.floor();
    final paise = ((absAmount - rupees) * 100).round();

    final rupeesWords = _convertRupees(rupees);
    final paiseWords = paise > 0 ? _convertTwoDigits(paise) : '';

    final buffer = StringBuffer();
    if (isNegative) buffer.write('Minus ');

    if (rupees > 0) {
      buffer.write('$rupeesWords Rupees');
    }

    if (paise > 0) {
      if (rupees > 0) buffer.write(' and ');
      buffer.write('$paiseWords Paise');
    }

    buffer.write(' Only');
    return buffer.toString().trim();
  }

  static String _convertRupees(int n) {
    if (n == 0) return '';

    final parts = <String>[];

    // Crores (1,00,00,000)
    final crores = n ~/ 10000000;
    var rem = n % 10000000;
    if (crores > 0) {
      parts.add('${_convertRupees(crores)} Crore');
    }

    // Lakhs (1,00,000)
    final lakhs = rem ~/ 100000;
    rem = rem % 100000;
    if (lakhs > 0) {
      parts.add('${_convertTwoDigits(lakhs)} Lakh');
    }

    // Thousands (1,000)
    final thousands = rem ~/ 1000;
    rem = rem % 1000;
    if (thousands > 0) {
      parts.add('${_convertTwoDigits(thousands)} Thousand');
    }

    // Hundreds (100)
    final hundreds = rem ~/ 100;
    rem = rem % 100;
    if (hundreds > 0) {
      parts.add('${_units[hundreds]} Hundred');
    }

    // Remainder (1-99)
    if (rem > 0) {
      parts.add(_convertTwoDigits(rem));
    }

    return parts.join(' ');
  }

  static String _convertTwoDigits(int n) {
    if (n < 20) {
      return _units[n];
    }
    final ten = n ~/ 10;
    final unit = n % 10;
    if (unit == 0) {
      return _tens[ten];
    }
    return '${_tens[ten]} ${_units[unit]}';
  }
}
