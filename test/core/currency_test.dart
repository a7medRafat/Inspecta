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

    test('toInputText gives an editable amount that parses back unchanged', () {
      expect(Currency.toInputText(450000), '4500');
      expect(Currency.toInputText(450050), '4500.50');
      expect(Currency.toInputText(5), '0.05');
      for (final piastres in [450000, 450050, 5, 100, 99, 1234567]) {
        expect(Currency.parsePiastres(Currency.toInputText(piastres)), piastres);
      }
    });
  });
}
