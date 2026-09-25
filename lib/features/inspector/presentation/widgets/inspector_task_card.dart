import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/enums/job_status.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../requests/domain/entities/inspection_request.dart';

/// One task card on the inspector's Tasks tab (Feature 05): a job that's
/// [JobStatus.assigned] still needs an Accept/Decline response; one
/// that's been accepted or started offers "Continue certificate" and a
/// way to navigate to the site instead.
class InspectorTaskCard extends StatelessWidget {
  final InspectionRequest task;
  final bool submitting;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onContinueCertificate;
  final VoidCallback onNavigate;

  const InspectorTaskCard({
    super.key,
    required this.task,
    required this.submitting,
    required this.onAccept,
    required this.onDecline,
    required this.onContinueCertificate,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final scheduledAt = task.scheduledAt;
    final needsResponse = task.status == JobStatus.assigned;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppColours.ink.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
          BoxShadow(color: AppColours.ink.withValues(alpha: 0.04), blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                scheduledAt == null ? '—' : DateFormat('HH:mm', locale).format(scheduledAt),
                style: AppTextStyles.cardTitle.copyWith(fontSize: 18, color: AppColours.primaryDark),
              ),
              _StatusBadge(status: task.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(task.equipmentTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 15, color: AppColours.inkMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(task.location, style: AppTextStyles.subtitle, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (needsResponse)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: submitting ? null : onDecline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColours.dangerText,
                        side: const BorderSide(color: AppColours.dangerBorder, width: 1.5),
                        textStyle: AppTextStyles.buttonLabel.copyWith(fontSize: 14, color: AppColours.dangerText),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(t.declineAction),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: submitting ? null : onAccept,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColours.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(t.acceptAction, style: AppTextStyles.buttonLabel.copyWith(fontSize: 14)),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onNavigate,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: AppColours.primaryDark,
                      side: const BorderSide(color: AppColours.primaryTint, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.near_me_outlined, size: 18),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: submitting ? null : onContinueCertificate,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColours.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        t.continueCertificateAction,
                        style: AppTextStyles.buttonLabel.copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final JobStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final (background, textColor, label) = switch (status) {
      JobStatus.assigned => (AppColours.chipAmberBackground, AppColours.chipAmberText, t.needsResponseBadge),
      JobStatus.taskAccepted => (AppColours.chipGreenBackground, AppColours.chipGreenText, t.taskAcceptedBadge),
      _ => (AppColours.chipBlueBackground, AppColours.chipBlueText, t.taskInProgressBadge),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: AppTextStyles.badge.copyWith(color: textColor)),
    );
  }
}
