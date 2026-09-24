import 'package:flutter_test/flutter_test.dart';
import 'package:inspecta/core/utils/currency.dart';

void main() {
  group('Currency', () {
    test('formatEgp shows two decimals with thousands separators (BR-03.10)', () {
      expect(Currency.formatEgp(1250000), 'EGP 12,500.00');
      expect(Currency.formatEgp(50), 'EGP 0.50');
    });

    test('parsePiastres converts EGP pounds to integer piastres', () {
      expect(Currency.parsePiastres('4500'), 450000);
      expect(Currency.parsePiastres('4,500.5'), 450050);
      expect(Currency.parsePiastres(''), isNull);
      expect(Currency.parsePiastres('not a number'), isNull);
    });
  });
}
