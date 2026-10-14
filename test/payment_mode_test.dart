import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';

void main() {
  test('users can only pick Cash or Bank', () {
    expect(kSelectablePaymentModes, [PaymentMode.cash, PaymentMode.bank]);
  });

  test('legacy cheque / online records map to Bank, cash stays cash', () {
    expect(PaymentMode.cash.normalized, PaymentMode.cash);
    expect(PaymentMode.bank.normalized, PaymentMode.bank);
    expect(PaymentMode.cheque.normalized, PaymentMode.bank);
    expect(PaymentMode.online.normalized, PaymentMode.bank);
    // every normalized value is always a valid dropdown item
    for (final m in PaymentMode.values) {
      expect(kSelectablePaymentModes, contains(m.normalized));
    }
  });

  test('old stored values still parse and display', () {
    for (final name in ['cash', 'bank', 'cheque', 'online']) {
      final m = PaymentMode.values.byName(name);
      expect(m.displayName, isNotEmpty);
    }
  });
}
