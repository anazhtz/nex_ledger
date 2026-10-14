import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Local Master Security PIN & Passcode Storage Service.
/// Stores SHA-256 hashed PIN in OS Application Support directory.
class SecurityService {
  SecurityService._();

  static const String _defaultPin = '1234';

  static Future<File> _getSecurityFile() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'security_pin.dat'));
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    return file;
  }

  static String _hashPin(String pin) {
    final bytes = utf8.encode('NEX_LEDGER_SALT_$pin');
    return sha256.convert(bytes).toString();
  }

  /// Minimum PIN length accepted when creating or changing the PIN.
  static const int minPinLength = 4;

  /// True once the user has chosen their own PIN. A missing file, or a file
  /// still holding the legacy default '1234', counts as NOT configured.
  static Future<bool> isPasscodeConfigured() async {
    final file = await _getSecurityFile();
    if (!await file.exists()) return false;
    final saved = (await file.readAsString()).trim();
    return saved.isNotEmpty && saved != _hashPin(_defaultPin);
  }

  /// Returns an error message if [pin] is not acceptable, otherwise null.
  static String? validateNewPin(String pin) {
    final p = pin.trim();
    if (p.length < minPinLength) {
      return 'PIN must be at least $minPinLength digits.';
    }
    if (p == _defaultPin) {
      return 'Please choose a PIN other than 1234.';
    }
    return null;
  }

  /// Verify user input PIN against stored SHA-256 hash.
  /// Always false until the user has created their own PIN.
  static Future<bool> verifyPin(String inputPin) async {
    if (!await isPasscodeConfigured()) return false;
    final file = await _getSecurityFile();
    final savedHash = (await file.readAsString()).trim();
    return savedHash == _hashPin(inputPin.trim());
  }

  /// Change/Set new master security PIN.
  static Future<void> updatePin(String newPin) async {
    final file = await _getSecurityFile();
    await file.writeAsString(_hashPin(newPin.trim()));
  }
}
