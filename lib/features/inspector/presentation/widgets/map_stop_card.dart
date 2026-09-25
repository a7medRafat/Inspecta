import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/enums/job_status.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../requests/domain/entities/inspection_request.dart';

/// One stop on the inspector's Map (list) tab (Feature 05): order number,
/// status, time, equipment, client and address, a "Directions" handoff
/// to the phone's maps app, and whatever action matches the stop's
/// status — the same Accept/Decline/Continue certificate the Tasks tab
/// offers. A stop that's done or returned is read-only here (see
/// [InspectionRequest.status]).
class MapStopCard extends StatelessWidget {
  final int order;
  final InspectionRequest stop;
  final bool submitting;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onContinueCertificate;
  final VoidCallback onDirections;

  const MapStopCard({
    super.key,
    required this.order,
    required this.stop,
    required this.submitting,
    required this.onAccept,
    required this.onDecline,
    required this.onContinueCertificate,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final scheduledAt = stop.scheduledAt;
    final bucket = _bucketFor(stop.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppColours.ink.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: bucket.dotColor, shape: BoxShape.circle),
                child: Text(
                  '$order',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                scheduledAt == null ? '—' : DateFormat('HH:mm', locale).format(scheduledAt),
                style: AppTextStyles.cardTitle.copyWith(fontSize: 16, color: AppColours.primaryDark),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: bucket.badgeBackground, borderRadius: BorderRadius.circular(999)),
                child: Text(bucket.label(t), style: AppTextStyles.badge.copyWith(color: bucket.badgeText)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(stop.equipmentTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
          const SizedBox(height: 2),
          Text(
            '${stop.clientName} · ${stop.location}',
            style: AppTextStyles.subtitle,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: onDirections,
                    icon: const Icon(Icons.near_me_outlined, size: 16),
                    label: Text(t.directionsAction),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColours.primaryDark,
                      side: const BorderSide(color: AppColours.primaryTint, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              if (stop.status == JobStatus.assigned) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: submitting ? null : onDecline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColours.dangerText,
                        side: const BorderSide(color: AppColours.dangerBorder, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(t.declineAction, style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: FilledButton(
                      onPressed: submitting ? null : onAccept,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColours.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(t.acceptAction, style: const TextStyle(fontSize: 13, color: Colors.white)),
                    ),
                  ),
                ),
              ] else if (stop.status == JobStatus.taskAccepted || stop.status == JobStatus.inProgress) ...[
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: FilledButton(
                      onPressed: submitting ? null : onContinueCertificate,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColours.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        t.continueCertificateAction,
                        style: const TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBucket {
  final Color dotColor;
  final Color badgeBackground;
  final Color badgeText;
  final String Function(AppLocalizations t) label;

  const _StatusBucket({
    required this.dotColor,
    required this.badgeBackground,
    required this.badgeText,
    required this.label,
  });
}

_StatusBucket _bucketFor(JobStatus status) => switch (status) {
  JobStatus.assigned => _StatusBucket(
    dotColor: AppColours.inkMuted,
    badgeBackground: AppColours.chipAmberBackground,
    badgeText: AppColours.chipAmberText,
    label: (t) => t.needsResponseBadge,
  ),
  JobStatus.taskAccepted => _StatusBucket(
    dotColor: AppColours.inkMuted,
    badgeBackground: AppColours.chipGreyBackground,
    badgeText: AppColours.chipGreyText,
    label: (t) => t.upcomingBadge,
  ),
  JobStatus.inProgress => _StatusBucket(
    dotColor: AppColours.primaryColor,
    badgeBackground: AppColours.chipBlueBackground,
    badgeText: AppColours.chipBlueText,
    label: (t) => t.taskInProgressBadge,
  ),
  JobStatus.certificateReturned => _StatusBucket(
    dotColor: AppColours.chipAmberTextStrong,
    badgeBackground: AppColours.chipAmberBackground,
    badgeText: AppColours.chipAmberText,
    label: (t) => t.returnedBadge,
  ),
  _ => _StatusBucket(
    dotColor: AppColours.successIcon,
    badgeBackground: AppColours.chipGreenBackground,
    badgeText: AppColours.chipGreenText,
    label: (t) => t.doneBadge,
  ),
};
