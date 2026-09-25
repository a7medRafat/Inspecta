import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/enums/job_status.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../requests/domain/entities/inspection_request.dart';

/// One row of an inspector's task list: a date/time badge, the job, and
/// whether they've accepted it yet (Feature 04 §5's "Not accepted" /
/// "Accepted" state — distinct from the certificate-side [JobStatus]
/// chip used elsewhere).
class InspectorTaskRow extends StatelessWidget {
  final InspectionRequest task;

  const InspectorTaskRow({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final scheduledAt = task.scheduledAt;
    final locale = Localizations.localeOf(context).languageCode;
    final accepted = task.status != JobStatus.assigned;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColours.ink.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: AppColours.primarySoft, borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  scheduledAt == null ? '—' : DateFormat.E(locale).format(scheduledAt).toUpperCase(),
                  style: AppTextStyles.badge.copyWith(fontSize: 11, color: AppColours.primaryDark),
                ),
                Text(
                  scheduledAt == null ? '' : DateFormat('HH:mm').format(scheduledAt),
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 14, color: AppColours.primaryDark),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(task.equipmentTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
                Text('${task.clientName}, ${task.location}', style: AppTextStyles.subtitle.copyWith(fontSize: 13), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: accepted ? AppColours.chipGreenBackground : AppColours.chipAmberBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              accepted ? t.taskAcceptedBadge : t.taskNotAcceptedBadge,
              style: AppTextStyles.badge.copyWith(
                color: accepted ? AppColours.chipGreenText : AppColours.chipAmberText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
