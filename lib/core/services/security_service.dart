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

  /// Check if custom passcode has been set, initialize default '1234' if fresh.
  static Future<bool> isPasscodeConfigured() async {
    final file = await _getSecurityFile();
    return file.existsSync();
  }

  /// Initialize default PIN '1234' if no PIN file exists yet.
  static Future<void> ensureInitialized() async {
    final file = await _getSecurityFile();
    if (!await file.exists()) {
      await file.writeAsString(_hashPin(_defaultPin));
    }
  }

  /// Verify user input PIN against stored SHA-256 hash.
  static Future<bool> verifyPin(String inputPin) async {
    await ensureInitialized();
    final file = await _getSecurityFile();
    final savedHash = (await file.readAsString()).trim();
    final inputHash = _hashPin(inputPin.trim());
    return savedHash == inputHash;
  }

  /// Change/Set new master security PIN.
  static Future<void> updatePin(String newPin) async {
    final file = await _getSecurityFile();
    await file.writeAsString(_hashPin(newPin.trim()));
  }
}
