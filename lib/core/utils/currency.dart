import 'package:intl/intl.dart';

/// EGP amounts are stored as integer piastres to avoid rounding errors
/// (00-overview.md §8, BR-03.10) and displayed as e.g. "EGP 12,500.00".
class Currency {
  Currency._();

  static final _format = NumberFormat('#,##0.00', 'en');

  static String formatEgp(int piastres) => 'EGP ${_format.format(piastres / 100)}';

  /// Parses a price typed in EGP pounds (e.g. "4500" or "4,500.50") into
  /// integer piastres. Returns `null` for empty or unparsable input.
  static int? parsePiastres(String input) {
    final cleaned = input.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return null;
    final pounds = double.tryParse(cleaned);
    if (pounds == null) return null;
    return (pounds * 100).round();
  }

  /// The text a price field should start with for a saved amount — "4500"
  /// or "4500.50", no separators or trailing ".00" — so it reads back
  /// through [parsePiastres] unchanged.
  static String toInputText(int piastres) =>
      piastres % 100 == 0 ? '${piastres ~/ 100}' : (piastres / 100).toStringAsFixed(2);
}
