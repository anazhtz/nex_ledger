/// GSTIN helpers: format and checksum validation, and state-code lookup.
///
/// A GSTIN is 15 characters: 2-digit state code, 10-character PAN, 1 entity
/// number, the letter Z, and a check character.
class GstUtils {
  GstUtils._();

  /// GST state / UT codes (first two digits of every GSTIN).
  static const Map<String, String> stateByCode = {
    '01': 'Jammu & Kashmir',
    '02': 'Himachal Pradesh',
    '03': 'Punjab',
    '04': 'Chandigarh',
    '05': 'Uttarakhand',
    '06': 'Haryana',
    '07': 'Delhi',
    '08': 'Rajasthan',
    '09': 'Uttar Pradesh',
    '10': 'Bihar',
    '11': 'Sikkim',
    '12': 'Arunachal Pradesh',
    '13': 'Nagaland',
    '14': 'Manipur',
    '15': 'Mizoram',
    '16': 'Tripura',
    '17': 'Meghalaya',
    '18': 'Assam',
    '19': 'West Bengal',
    '20': 'Jharkhand',
    '21': 'Odisha',
    '22': 'Chhattisgarh',
    '23': 'Madhya Pradesh',
    '24': 'Gujarat',
    '26': 'Dadra & Nagar Haveli and Daman & Diu',
    '27': 'Maharashtra',
    '29': 'Karnataka',
    '30': 'Goa',
    '31': 'Lakshadweep',
    '32': 'Kerala',
    '33': 'Tamil Nadu',
    '34': 'Puducherry',
    '35': 'Andaman & Nicobar Islands',
    '36': 'Telangana',
    '37': 'Andhra Pradesh',
    '38': 'Ladakh',
    '97': 'Other Territory',
  };

  static const String _alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static final RegExp _format =
      RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$');

  /// Upper-cases and removes spaces so "32aabfs1234a1z5 " compares cleanly.
  static String normalize(String? gstin) =>
      (gstin ?? '').toUpperCase().replaceAll(RegExp(r'\s'), '');

  /// True when [gstin] has the correct 15-character shape.
  static bool hasValidFormat(String? gstin) =>
      _format.hasMatch(normalize(gstin));

  /// The check character the 14 leading characters should be followed by.
  static String checkCharacter(String first14) {
    var sum = 0;
    for (var i = 0; i < 14; i++) {
      final value = _alphabet.indexOf(first14[i]);
      final weighted = value * (i.isEven ? 1 : 2);
      sum += (weighted ~/ 36) + (weighted % 36);
    }
    return _alphabet[(36 - (sum % 36)) % 36];
  }

  /// Format is right and the check character matches.
  static bool isValid(String? gstin) {
    final g = normalize(gstin);
    if (!hasValidFormat(g)) return false;
    if (!stateByCode.containsKey(g.substring(0, 2))) return false;
    return checkCharacter(g.substring(0, 14)) == g[14];
  }

  /// Two-digit state code from a GSTIN, or null if the start is not a
  /// known code.
  static String? stateCodeOf(String? gstin) {
    final g = normalize(gstin);
    if (g.length < 2) return null;
    final code = g.substring(0, 2);
    return stateByCode.containsKey(code) ? code : null;
  }

  /// State name for a GSTIN, e.g. "32…" -> "Kerala".
  static String? stateNameOf(String? gstin) {
    final code = stateCodeOf(gstin);
    return code == null ? null : stateByCode[code];
  }

  /// State code for a state name such as "Kerala" (case-insensitive).
  static String? codeOfStateName(String? name) {
    final n = (name ?? '').trim().toLowerCase();
    if (n.isEmpty) return null;
    for (final e in stateByCode.entries) {
      if (e.value.toLowerCase() == n) return e.key;
    }
    return null;
  }

  /// The supplier's state code: from the GSTIN when it has one, otherwise
  /// from the state name chosen on the form.
  static String? supplierStateCode({String? gstin, String? stateName}) =>
      stateCodeOf(gstin) ?? codeOfStateName(stateName);

  /// Inter-state when both state codes are known and differ; unknown on
  /// either side means local (the user can override on the form).
  static bool isInterStateByCode(String? companyCode, String? supplierCode) {
    if (companyCode == null || supplierCode == null) return false;
    return companyCode != supplierCode;
  }

  /// Inter-state when both sides are known and differ. If either state is
  /// unknown the purchase is treated as local (the user can override).
  static bool isInterState({String? companyGstin, String? supplierGstin}) {
    final a = stateCodeOf(companyGstin);
    final b = stateCodeOf(supplierGstin);
    if (a == null || b == null) return false;
    return a != b;
  }
}
