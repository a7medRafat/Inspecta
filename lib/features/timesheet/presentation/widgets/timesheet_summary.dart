import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/utils/currency.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/timesheet_entry.dart';
import 'timesheet_figure.dart';
import 'timesheet_labels.dart';

/// The two numbers an entry comes down to: the net time worked, and what it
/// comes to in money. Everything behind them — each activity, each cost, the
/// rate — is in the breakdown, one tap away.
class TimesheetSummary extends StatelessWidget {
  final TimesheetEntry entry;

  const TimesheetSummary({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    // With costs the figure is the total and says how it's made up; without,
    // it's just the price, and says what it was worked out at.
    final String? moneyCaption = entry.hasExpenses
        ? t.timesheetPricePlusTransport(
            Currency.formatEgp(entry.pricePiastres),
            Currency.formatEgp(entry.expensesPiastres),
          )
        : entry.hourlyRatePiastres > 0
        ? t.hourlyRatePerHour(Currency.formatEgp(entry.hourlyRatePiastres))
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColours.surfaceMuted, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: TimesheetFigure(
              label: t.timeSpentLabel,
              value: formatMinutes(t, entry.minutes),
              // The headline is net of the break, so say so.
              caption: entry.unpaidBreakMinutes > 0
                  ? t.timesheetExcludingBreak(formatMinutes(t, entry.unpaidBreakMinutes))
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: TimesheetFigure(
              label: entry.hasExpenses ? t.timesheetTotalPriceLabel : t.priceLabel,
              value: entry.totalPiastres > 0 ? Currency.formatEgp(entry.totalPiastres) : '—',
              caption: moneyCaption,
            ),
          ),
        ],
      ),
    );
  }
}
