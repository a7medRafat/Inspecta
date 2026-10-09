import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/utils/currency.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/timesheet_activity.dart';
import '../../domain/entities/timesheet_entry.dart';
import '../../domain/entities/timesheet_expense.dart';
import 'timesheet_labels.dart';

/// How an entry's time and money add up, as a ledger: each activity with
/// minutes, each cost with an amount, then the price with the rate it was
/// worked out at, and the total. Labels on the left and amounts on the right
/// so a column of figures reads straight down.
///
/// Meant to sit behind a "Details" toggle: the card's summary carries the
/// headline numbers, and this is the working.
class TimesheetBreakdown extends StatelessWidget {
  final TimesheetEntry entry;

  const TimesheetBreakdown({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final activities = [
      for (final activity in TimesheetActivity.values)
        if (entry.minutesOf(activity) > 0) activity,
    ];
    final expenses = [
      for (final expense in TimesheetExpense.values)
        if (entry.expenseOf(expense) > 0) expense,
    ];

    // Worked out from a rate; entries typed in before rates existed have
    // none, so there's no working to show.
    final priceWorking = entry.hourlyRatePiastres > 0 && entry.minutes > 0
        ? t.timesheetPriceFormula(formatMinutes(t, entry.minutes), Currency.formatEgp(entry.hourlyRatePiastres))
        : null;
    final reviewer = entry.reviewerName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activities.isNotEmpty) ...[
          _SectionLabel(t.timesheetActivitiesLabel),
          for (final activity in activities)
            _Line(
              label: activity.label(t),
              // The break comes off the time rather than adding to it.
              value: activity.isPaid
                  ? formatMinutes(t, entry.minutesOf(activity))
                  : '− ${formatMinutes(t, entry.minutesOf(activity))}',
              muted: !activity.isPaid,
            ),
        ],
        if (expenses.isNotEmpty) ...[
          if (activities.isNotEmpty) const SizedBox(height: 12),
          _SectionLabel(t.timesheetExpensesLabel),
          for (final expense in expenses)
            _Line(label: expense.label(t), value: Currency.formatEgp(entry.expenseOf(expense))),
        ],
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1, color: AppColours.border),
        ),
        _Line(
          label: t.priceLabel,
          caption: priceWorking,
          value: entry.hasPrice ? Currency.formatEgp(entry.pricePiastres) : '—',
        ),
        if (entry.hasExpenses)
          _Line(label: t.timesheetTotalPriceLabel, value: Currency.formatEgp(entry.totalPiastres), strong: true),
        if (entry.isApproved && reviewer != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColours.successIcon),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  t.timesheetApprovedBy(reviewer),
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: AppColours.successText),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: AppTextStyles.caption.copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;

  /// A smaller line under the label — the working behind the value.
  final String? caption;
  final bool strong;
  final bool muted;

  const _Line({required this.label, required this.value, this.caption, this.strong = false, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final color = strong ? AppColours.ink : (muted ? AppColours.inkMuted : AppColours.inkBody);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 14,
                    color: color,
                    fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
                if (caption != null) Text(caption!, style: AppTextStyles.caption.copyWith(fontSize: 12, height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: AppTextStyles.subtitle.copyWith(
              fontSize: 14,
              color: color,
              fontWeight: strong ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
