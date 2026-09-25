import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/qualification.dart';
import '../../domain/coordinator_consts.dart';

/// The inspector detail screen's "Qualifications" list: a coloured dot
/// per certificate, and its validity — highlighted when it's expiring
/// soon (Feature 04 §5).
class QualificationsCard extends StatelessWidget {
  final List<Qualification> qualifications;

  const QualificationsCard({super.key, required this.qualifications});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return MCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.qualificationsTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          if (qualifications.isEmpty)
            Text(t.noQualificationsListed, style: AppTextStyles.caption)
          else
            for (var i = 0; i < qualifications.length; i++) ...[
              if (i > 0) const SizedBox(height: 4),
              _QualificationRow(qualification: qualifications[i]),
            ],
        ],
      ),
    );
  }
}

class _QualificationRow extends StatelessWidget {
  final Qualification qualification;

  const _QualificationRow({required this.qualification});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final expiring = qualification.isExpiringWithin(CoordinatorConsts.qualificationExpiryWarning);
    final validUntil = qualification.validUntil;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: expiring ? AppColours.chipAmberBackground.withValues(alpha: 0.6) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: expiring ? AppColours.chipAmberTextStrong : AppColours.successIcon,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(qualification.name, style: AppTextStyles.emphasis.copyWith(fontSize: 14)),
          ),
          Text(
            validUntil == null
                ? t.notSet
                : expiring
                ? t.expiresOnLabel(DateFormat.MMMd(locale).format(validUntil))
                : t.validToLabel(DateFormat.yMMM(locale).format(validUntil)),
            style: AppTextStyles.caption.copyWith(
              color: expiring ? AppColours.chipAmberTextStrong : AppColours.inkMuted,
              fontWeight: expiring ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
