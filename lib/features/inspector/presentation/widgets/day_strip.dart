import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';

/// A 7-day picker, the selected day always in the middle, with an
/// optional dot under a day that has something on it — shared by the
/// Tasks and Map tabs (Feature 05).
class DayStrip extends StatelessWidget {
  final List<DateTime> weekDates;
  final DateTime selectedDate;
  final bool Function(DateTime day)? hasIndicator;
  final ValueChanged<DateTime> onSelectDate;

  const DayStrip({
    super.key,
    required this.weekDates,
    required this.selectedDate,
    required this.onSelectDate,
    this.hasIndicator,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Row(
      children: [
        for (final day in weekDates)
          Expanded(
            child: _DayPill(
              label: DateFormat.E(locale).format(day),
              dayNumber: day.day,
              selected: day == selectedDate,
              hasIndicator: hasIndicator?.call(day) ?? false,
              onTap: () => onSelectDate(day),
            ),
          ),
      ],
    );
  }
}

class _DayPill extends StatelessWidget {
  final String label;
  final int dayNumber;
  final bool selected;
  final bool hasIndicator;
  final VoidCallback onTap;

  const _DayPill({
    required this.label,
    required this.dayNumber,
    required this.selected,
    required this.hasIndicator,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: selected ? AppColours.primaryDark : AppColours.onPrimaryMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$dayNumber',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: selected ? AppColours.primaryDark : Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                SizedBox(
                  height: 4,
                  width: 4,
                  child: hasIndicator
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            color: selected ? AppColours.primaryDark : Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
