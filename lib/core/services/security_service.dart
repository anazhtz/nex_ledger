import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Local Master Security PIN & Passcode Storage Service.
/// Stores SHA-256 hashed PIN in OS Application Support directory.
class SecurityService {
  SecurityService._();

  static const String _defaultPin = '1234';

  /// Tests point this at a temp folder instead of the real app-support dir.
  @visibleForTesting
  static Directory? directoryOverride;

  static Future<Directory> _supportDir() async =>
      directoryOverride ?? await getApplicationSupportDirectory();

  static Future<File> _getRecoveryFile() async {
    final dir = await _supportDir();
    final file = File(p.join(dir.path, 'security_recovery.dat'));
    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }
    return file;
  }

  static Future<File> _getSecurityFile() async {
    final dir = await _supportDir();
    final file = File(p.join(dir.path, 'security_pin.dat'));
    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
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
    if (!file.existsSync()) return false;
    final saved = file.readAsStringSync().trim();
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
    final savedHash = file.readAsStringSync().trim();
    return savedHash == _hashPin(inputPin.trim());
  }

  /// Change/Set new master security PIN.
  static Future<void> updatePin(String newPin) async {
    final file = await _getSecurityFile();
    file.writeAsStringSync(_hashPin(newPin.trim()));
  }

  // ─── Recovery key (for a forgotten PIN) ────────────────────────────────────

  /// No 0/O/1/I/L so a key is easy to read out and type from paper.
  static const String _keyAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const int _keyLength = 16;

  static String _hashRecoveryKey(String normalizedKey) => sha256
      .convert(utf8.encode('NEX_LEDGER_RECOVERY_$normalizedKey'))
      .toString();

  /// Upper-cases and strips spaces / dashes so "abcd-efgh ..." still matches.
  static String normalizeRecoveryKey(String input) =>
      input.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

  /// "ABCD-EFGH-JKMN-PQRS"
  static String _formatKey(String raw) => [
        for (var i = 0; i < raw.length; i += 4) raw.substring(i, i + 4),
      ].join('-');

  /// True when a recovery key has been created on this computer.
  static Future<bool> hasRecoveryKey() async =>
      (await _getRecoveryFile()).existsSync();

  /// Creates a NEW recovery key, replacing any earlier one, and returns it.
  /// Only a hash is stored, so the key can never be shown again.
  static Future<String> createRecoveryKey() async {
    final rnd = Random.secure();
    final raw = String.fromCharCodes(
      List.generate(
        _keyLength,
        (_) => _keyAlphabet.codeUnitAt(rnd.nextInt(_keyAlphabet.length)),
      ),
    );
    final file = await _getRecoveryFile();
    file.writeAsStringSync(_hashRecoveryKey(raw));
    return _formatKey(raw);
  }

  static Future<bool> verifyRecoveryKey(String input) async {
    final file = await _getRecoveryFile();
    if (!file.existsSync()) return false;
    final normalized = normalizeRecoveryKey(input);
    if (normalized.length != _keyLength) return false;
    return file.readAsStringSync().trim() == _hashRecoveryKey(normalized);
  }

  /// Sets a new PIN when the recovery key is correct. On success returns the
  /// replacement recovery key (the old one stops working); otherwise null.
  static Future<String?> resetPinWithRecoveryKey(
      String recoveryKey, String newPin) async {
    if (validateNewPin(newPin) != null) return null;
    if (!await verifyRecoveryKey(recoveryKey)) return null;
    await updatePin(newPin);
    return createRecoveryKey();
  }
}
