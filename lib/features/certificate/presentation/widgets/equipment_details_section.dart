import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../requests/domain/entities/inspection_request.dart';

/// Step 1 of the certificate (Feature 05): the equipment came from the
/// original request, so it's always a done, read-only summary here —
/// not something the inspector fills in on this screen.
class EquipmentDetailsSection extends StatelessWidget {
  final InspectionRequest request;

  const EquipmentDetailsSection({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return MCard(
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColours.successBackground, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, size: 18, color: AppColours.successIcon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t.equipmentDetailsTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
                Text(
                  '${request.equipmentTitle} · ${request.location}',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColours.inkMuted),
        ],
      ),
    );
  }
}
