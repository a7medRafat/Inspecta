import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/qualification.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/coordinator_consts.dart';
import '../../domain/inspector_day_summary.dart';

/// One roster row (Feature 04 §5): busy/free inspectors get a solid card
/// with today's slot count and, when busy, a "Now / Next" line; an
/// inspector on leave gets the mockup's muted, outlined card instead.
class InspectorListCard extends StatelessWidget {
  final AppUser inspector;
  final InspectorDaySummary summary;
  final VoidCallback onTap;

  const InspectorListCard({super.key, required this.inspector, required this.summary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final onLeave = summary.availability == InspectorAvailability.onLeave;
    return Container(
      decoration: BoxDecoration(
        color: onLeave ? AppColours.surfaceMuted : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: onLeave ? Border.all(color: AppColours.border) : null,
        boxShadow: onLeave
            ? null
            : [
                BoxShadow(color: AppColours.ink.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
                BoxShadow(color: AppColours.ink.withValues(alpha: 0.04), blurRadius: 2),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: onLeave ? _OnLeaveContent(inspector: inspector) : _ActiveContent(inspector: inspector, summary: summary),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final AppUser inspector;
  final InspectorAvailability availability;

  const _Avatar({required this.inspector, required this.availability});

  @override
  Widget build(BuildContext context) {
    final dotColor = switch (availability) {
      InspectorAvailability.free => AppColours.successIcon,
      InspectorAvailability.busy => AppColours.chipAmberTextStrong,
      InspectorAvailability.onLeave => null,
    };
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: availability == InspectorAvailability.onLeave ? AppColours.border.withValues(alpha: 0.4) : AppColours.primaryTint,
            shape: BoxShape.circle,
          ),
          child: Text(
            inspector.initials,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: availability == InspectorAvailability.onLeave ? AppColours.inkMuted : AppColours.primaryDark,
            ),
          ),
        ),
        if (dotColor != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final InspectorAvailability availability;

  const _StatusBadge({required this.availability});

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

class _ActiveContent extends StatelessWidget {
  final AppUser inspector;
  final InspectorDaySummary summary;

  const _ActiveContent({required this.inspector, required this.summary});

  Qualification? _expiringQualification() {
    for (final q in inspector.qualifications) {
      if (q.isExpiringWithin(CoordinatorConsts.qualificationExpiryWarning)) return q;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final expiring = _expiringQualification();
    final fraction = (summary.todaySlots / CoordinatorConsts.dailySlotCapacity).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(inspector: inspector, availability: summary.availability),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(inspector.name, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
                  Text(
                    inspector.qualifications.isEmpty
                        ? t.noQualificationsListed
                        : inspector.qualifications.map((q) => q.name).join(' · '),
                    style: AppTextStyles.subtitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _StatusBadge(availability: summary.availability),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(t.todayLabel, style: AppTextStyles.subtitle),
            Text(
              t.slotsOfCapacity(summary.todaySlots, CoordinatorConsts.dailySlotCapacity),
              style: AppTextStyles.emphasis.copyWith(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: AppColours.surfaceMuted,
            valueColor: const AlwaysStoppedAnimation(AppColours.primaryColor),
          ),
        ),
        if (summary.availability == InspectorAvailability.busy) ...[
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${t.nowLabel} ', style: AppTextStyles.emphasis.copyWith(fontSize: 13)),
                TextSpan(
                  text: summary.nowTask == null
                      ? t.notSet
                      : '${summary.nowTask!.equipmentTitle}, ${summary.nowTask!.location}',
                  style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                ),
                if (summary.nextTask?.scheduledAt != null) ...[
                  TextSpan(text: '  ·  ${t.nextLabel} ', style: AppTextStyles.emphasis.copyWith(fontSize: 13)),
                  TextSpan(
                    text: DateFormat('HH:mm').format(summary.nextTask!.scheduledAt!),
                    style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ] else if (expiring != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 16, color: AppColours.chipAmberTextStrong),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  t.licenseExpiresInDays(expiring.name, expiring.validUntil!.difference(DateTime.now()).inDays),
                  style: AppTextStyles.caption.copyWith(color: AppColours.chipAmberTextStrong, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _OnLeaveContent extends StatelessWidget {
  final AppUser inspector;

  const _OnLeaveContent({required this.inspector});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final until = inspector.onLeaveUntil!;
    return Row(
      children: [
        _Avatar(inspector: inspector, availability: InspectorAvailability.onLeave),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(inspector.name, style: AppTextStyles.cardTitle.copyWith(fontSize: 16, color: AppColours.inkSecondary)),
              Text(
                t.onLeaveUntilLabel(DateFormat.MMMd(Localizations.localeOf(context).languageCode).format(until)),
                style: AppTextStyles.subtitle,
              ),
            ],
          ),
        ),
        const _StatusBadge(availability: InspectorAvailability.onLeave),
      ],
    );
  }
}
