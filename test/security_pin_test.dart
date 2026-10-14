import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/services/security_service.dart';

void main() {
  group('SecurityService.validateNewPin', () {
    test('rejects short PINs', () {
      expect(SecurityService.validateNewPin('12'), isNotNull);
      expect(SecurityService.validateNewPin(''), isNotNull);
    });

    test('rejects the legacy default PIN', () {
      expect(SecurityService.validateNewPin('1234'), isNotNull);
    });

    test('accepts a custom PIN', () {
      expect(SecurityService.validateNewPin('4821'), isNull);
      expect(SecurityService.validateNewPin('  4821 '), isNull);
    });
  });

  group('recovery key', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('nex_sec_test');
      SecurityService.directoryOverride = dir;
      await SecurityService.updatePin('4821');
    });

    tearDown(() async {
      SecurityService.directoryOverride = null;
      await dir.delete(recursive: true);
    });

    test('key is 4 groups of 4 from the readable alphabet and is random',
        () async {
      final a = await SecurityService.createRecoveryKey();
      expect(
          a, matches(RegExp(r'^[A-HJKMNP-Z2-9]{4}(-[A-HJKMNP-Z2-9]{4}){3}$')));
      final b = await SecurityService.createRecoveryKey();
      expect(b, isNot(a));
    });

    test('nothing is recoverable until a key exists', () async {
      expect(await SecurityService.hasRecoveryKey(), isFalse);
      expect(await SecurityService.verifyRecoveryKey('AAAA-AAAA-AAAA-AAAA'),
          isFalse);
      expect(
          await SecurityService.resetPinWithRecoveryKey(
              'AAAA-AAAA-AAAA-AAAA', '9999'),
          isNull);
    });

    test('only a hash is stored, never the key itself', () async {
      final key = await SecurityService.createRecoveryKey();
      final stored =
          await File('${dir.path}/security_recovery.dat').readAsString();
      expect(stored.contains(key.replaceAll('-', '')), isFalse);
      expect(stored.length, 64); // sha-256 hex
    });

    test('key matches regardless of case, dashes and spaces', () async {
      final key = await SecurityService.createRecoveryKey();
      expect(await SecurityService.verifyRecoveryKey(key), isTrue);
      expect(
          await SecurityService.verifyRecoveryKey(key.toLowerCase()), isTrue);
      expect(await SecurityService.verifyRecoveryKey(key.replaceAll('-', ' ')),
          isTrue);
      expect(await SecurityService.verifyRecoveryKey('${key}X'), isFalse);
      expect(await SecurityService.verifyRecoveryKey('WRONG-KEY'), isFalse);
    });

    test('reset sets the new PIN, retires the old key and issues a new one',
        () async {
      final key = await SecurityService.createRecoveryKey();
      final newKey = await SecurityService.resetPinWithRecoveryKey(key, '7392');
      expect(newKey, isNotNull);
      expect(await SecurityService.verifyPin('7392'), isTrue);
      expect(await SecurityService.verifyPin('4821'), isFalse);
      // old key is dead, new one works
      expect(await SecurityService.verifyRecoveryKey(key), isFalse);
      expect(await SecurityService.verifyRecoveryKey(newKey!), isTrue);
    });

    test('wrong key or weak new PIN changes nothing', () async {
      final key = await SecurityService.createRecoveryKey();
      expect(
          await SecurityService.resetPinWithRecoveryKey(
              'AAAA-AAAA-AAAA-AAAA', '7392'),
          isNull);
      expect(
          await SecurityService.resetPinWithRecoveryKey(key, '1234'), isNull);
      expect(await SecurityService.resetPinWithRecoveryKey(key, '12'), isNull);
      expect(await SecurityService.verifyPin('4821'), isTrue);
      expect(await SecurityService.verifyRecoveryKey(key), isTrue);
    });
  });
}
