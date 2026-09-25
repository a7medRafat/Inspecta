import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../domain/inspector_day_summary.dart';
import 'schedule_timeline.dart';

/// One row of the Schedule tab's day view (Feature 04 §5, scope-cut #1):
/// the inspector, whether they're on leave, and their tasks for the
/// selected day as blocks on a timeline. Tapping the row opens their
/// detail screen — same target the Inspectors tab uses.
class ScheduleInspectorRow extends StatelessWidget {
  final AppUser inspector;
  final List<InspectionRequest> tasks;
  final bool onLeave;
  final VoidCallback onTap;

  const ScheduleInspectorRow({
    super.key,
    required this.inspector,
    required this.tasks,
    required this.onLeave,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final availability = onLeave
        ? InspectorAvailability.onLeave
        : (tasks.isEmpty ? InspectorAvailability.free : InspectorAvailability.busy);

    return MCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: onLeave ? AppColours.border.withValues(alpha: 0.4) : AppColours.primaryTint,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        inspector.initials,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: onLeave ? AppColours.inkMuted : AppColours.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        inspector.name,
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _AvailabilityBadge(availability: availability),
                  ],
                ),
                const SizedBox(height: 10),
                if (onLeave)
                  Text(
                    inspector.onLeaveUntil == null
                        ? t.onLeaveBadge
                        : t.onLeaveUntilLabel(
                            DateFormat.MMMd(Localizations.localeOf(context).languageCode).format(inspector.onLeaveUntil!),
                          ),
                    style: AppTextStyles.subtitle,
                  )
                else if (tasks.isEmpty)
                  Text(t.scheduleFreeAllDayLabel, style: AppTextStyles.caption)
                else
                  ScheduleTimeline(tasks: tasks),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final InspectorAvailability availability;

  const _AvailabilityBadge({required this.availability});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final (background, textColor, label) = switch (availability) {
      InspectorAvailability.free => (AppColours.chipGreenBackground, AppColours.chipGreenText, t.freeBadge),
      InspectorAvailability.busy => (AppColours.chipAmberBackground, AppColours.chipAmberText, t.busyBadge),
      InspectorAvailability.onLeave => (AppColours.chipGreyBackground, AppColours.chipGreyText, t.onLeaveBadge),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: AppTextStyles.badge.copyWith(color: textColor)),
    );
  }
}
