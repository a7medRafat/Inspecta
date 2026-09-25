import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/user.dart';

/// One inspector choice on the "Choose inspector" step: a radio tile with
/// their initials, name, qualifications, and a "Best match" tag when
/// [isBestMatch] (their qualifications cover the job's equipment). An
/// inspector on leave shows instead — greyed out, not selectable — like
/// the mockup's disabled "On leave until ..." option.
class InspectorOptionTile extends StatelessWidget {
  final AppUser inspector;
  final bool selected;
  final bool isBestMatch;
  final VoidCallback onTap;

  const InspectorOptionTile({
    super.key,
    required this.inspector,
    required this.selected,
    required this.isBestMatch,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final onLeave = inspector.isOnLeave();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onLeave ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: onLeave ? AppColours.surfaceMuted : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColours.primaryColor : AppColours.border,
            width: selected ? 2 : 1.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: AppColours.primaryColor.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6))]
              : null,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: inspector.id,
              groupValue: selected ? inspector.id : null,
              onChanged: onLeave ? null : (_) => onTap(),
              activeColor: AppColours.primaryColor,
            ),
            const SizedBox(width: 4),
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: onLeave ? AppColours.border.withValues(alpha: 0.4) : AppColours.primaryTint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                inspector.initials,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: onLeave ? AppColours.inkMuted : AppColours.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(inspector.name, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
                  Text(
                    onLeave
                        ? t.onLeaveUntilLabel(DateFormat.MMMd(Localizations.localeOf(context).languageCode).format(inspector.onLeaveUntil!))
                        : (inspector.qualifications.isEmpty
                              ? t.noQualificationsListed
                              : inspector.qualifications.map((q) => q.name).join(', ')),
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 13,
                      color: onLeave ? AppColours.inkMuted : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isBestMatch && !onLeave) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColours.primaryColor, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  t.bestMatchTag,
                  style: AppTextStyles.badge.copyWith(fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
