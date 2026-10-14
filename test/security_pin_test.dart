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
}
