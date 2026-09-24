import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

/// The client detail's three stat tiles: equipment, open jobs, due soon.
class ClientStatTiles extends StatelessWidget {
  final int equipmentCount;
  final int openJobsCount;
  final int dueSoonCount;

  const ClientStatTiles({
    super.key,
    required this.equipmentCount,
    required this.openJobsCount,
    required this.dueSoonCount,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _Tile(value: '$equipmentCount', label: t.equipmentStatLabel),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Tile(
            value: '$openJobsCount',
            label: t.openJobsStatLabel,
            valueColor: AppColours.primaryDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Tile(
            value: '$dueSoonCount',
            label: t.dueSoonStatLabel,
            valueColor: AppColours.chipAmberText,
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _Tile({required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: AppColours.ink.withValues(alpha: 0.06), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 20, color: valueColor),
          ),
          Text(
            label,
            style: AppTextStyles.subtitle.copyWith(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
