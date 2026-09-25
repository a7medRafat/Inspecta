import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/coordinator_consts.dart';

/// The inspector detail screen's "This week" mini-calendar: a task count
/// per day, today highlighted, the weekend always "off", and a fully
/// booked day in red (Feature 04 §5).
class WeeklyScheduleCard extends StatelessWidget {
  final List<DateTime> weekDates;
  final List<int> taskCounts;

  const WeeklyScheduleCard({super.key, required this.weekDates, required this.taskCounts});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final today = DateTime.now();
    final locale = Localizations.localeOf(context).languageCode;

    return MCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.thisWeekTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < weekDates.length; i++)
                Expanded(
                  child: _DayCell(
                    label: DateFormat.E(locale).format(weekDates[i]),
                    count: taskCounts[i],
                    isToday:
                        weekDates[i].year == today.year && weekDates[i].month == today.month && weekDates[i].day == today.day,
                    isWeekend: CoordinatorConsts.weekendWeekdays.contains(weekDates[i].weekday),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(t.tasksPerDayCaption, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String label;
  final int count;
  final bool isToday;
  final bool isWeekend;

  const _DayCell({required this.label, required this.count, required this.isToday, required this.isWeekend});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final fullyBooked = count >= CoordinatorConsts.dailySlotCapacity;

    final Color background;
    Border? border;
    final Color textColor;
    if (isWeekend) {
      background = Colors.transparent;
      textColor = AppColours.inkMuted;
    } else if (isToday) {
      background = AppColours.primaryColor;
      textColor = Colors.white;
    } else if (fullyBooked) {
      background = AppColours.chipRedBackground;
      textColor = AppColours.chipRedText;
    } else if (count == 0) {
      background = Colors.transparent;
      border = Border.all(color: AppColours.border);
      textColor = AppColours.inkMuted;
    } else {
      background = AppColours.primaryTint;
      textColor = AppColours.primaryDark;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
          const SizedBox(height: 6),
          Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: background, border: border, borderRadius: BorderRadius.circular(12)),
            child: Text(
              isWeekend ? t.offLabel : '$count',
              style: TextStyle(
                fontSize: isWeekend ? 12 : 15,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
