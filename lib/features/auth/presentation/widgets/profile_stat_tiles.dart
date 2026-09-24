import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_card.dart';
import '../../../../l10n/app_localizations.dart';

/// The Profile screen's "This month" card: up to three stat tiles. A
/// `null` value means this role has no data source for that tile yet
/// (its feature isn't built) — it renders as a placeholder dash rather
/// than a misleading zero.
class ProfileStatTiles extends StatelessWidget {
  final List<(int? value, String label)> stats;

  const ProfileStatTiles({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return MCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.profileThisMonth,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _Stat(value: stats[i].$1, label: stats[i].$2)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final int? value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value?.toString() ?? '—',
          style: AppTextStyles.cardTitle.copyWith(fontSize: 22, color: AppColours.primaryDark),
        ),
        Text(
          label,
          style: AppTextStyles.subtitle.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
