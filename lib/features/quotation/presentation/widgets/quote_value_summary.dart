import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/utils/currency.dart';
import '../../../../l10n/app_localizations.dart';

/// The board's total open value, and the current sort order — a plain
/// row above the list, not a boxed panel.
class QuoteValueSummary extends StatelessWidget {
  final int openTotalPiastres;

  const QuoteValueSummary({super.key, required this.openTotalPiastres});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              style: AppTextStyles.subtitle,
              children: [
                TextSpan(text: '${t.openValueLabel} '),
                TextSpan(
                  text: Currency.formatEgp(openTotalPiastres),
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColours.ink),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Text(t.sortOldestFirstLabel, style: AppTextStyles.caption),
      ],
    );
  }
}
