import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/request_item.dart';

/// The equipment on a request (BR-02.6: each item is quoted and certified
/// separately), plus the request's preferred date.
class EquipmentGrid extends StatelessWidget {
  final List<RequestItem> items;
  final DateTime? preferredDate;

  const EquipmentGrid({super.key, required this.items, this.preferredDate});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return MCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.equipmentLabel, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
          const SizedBox(height: 14),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColours.surfaceMuted),
              const SizedBox(height: 14),
            ],
            _ItemFields(item: items[i], t: t),
          ],
          if (preferredDate != null) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColours.surfaceMuted),
            const SizedBox(height: 14),
            _Field(
              label: t.preferredDateLabel,
              value: DateFormat.yMMMd(
                Localizations.localeOf(context).languageCode,
              ).format(preferredDate!),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemFields extends StatelessWidget {
  final RequestItem item;
  final AppLocalizations t;

  const _ItemFields({required this.item, required this.t});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _Field(label: t.equipmentLabel, value: item.type),
        if (item.capacity != null && item.capacity!.isNotEmpty)
          _Field(label: t.capacityLabel, value: item.capacity!),
        _Field(label: t.quantityLabel, value: t.unitsCount(item.quantity)),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;

  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTextStyles.emphasis.copyWith(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
