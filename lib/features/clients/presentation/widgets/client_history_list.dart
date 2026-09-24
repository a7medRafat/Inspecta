import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../../requests/presentation/widgets/status_chip.dart';
import '../../domain/entities/client_equipment_item.dart';

/// One request row in the client detail's Requests tab: quote-style
/// mono id + date, the equipment title, and a status chip — the same
/// language as [QuoteBoardCard] and [RequestCard], just compact enough
/// for a history list.
class ClientRequestRow extends StatelessWidget {
  final InspectionRequest request;
  final VoidCallback onTap;

  const ClientRequestRow({super.key, required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColours.ink.withValues(alpha: 0.05), blurRadius: 6),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${request.id} · ${dateFormat.format(request.receivedAt)}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: AppColours.inkMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.equipmentTitle,
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                StatusChip(status: request.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ClientEquipmentRow extends StatelessWidget {
  final ClientEquipmentItem item;

  const ClientEquipmentRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    final dueSoon = item.isDueSoon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColours.ink.withValues(alpha: 0.05), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.type,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  [
                    if (item.serialNumber != null) item.serialNumber,
                    if (item.location != null) item.location,
                  ].join(' · '),
                  style: AppTextStyles.subtitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (item.nextDueDate != null) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: dueSoon ? AppColours.chipAmberBackground : AppColours.surfaceMuted,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                dateFormat.format(item.nextDueDate!),
                style: AppTextStyles.badge.copyWith(
                  fontSize: 11,
                  color: dueSoon ? AppColours.chipAmberText : AppColours.inkBody,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ClientHistoryEmptyState extends StatelessWidget {
  final String message;

  const ClientHistoryEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(message, textAlign: TextAlign.center, style: AppTextStyles.subtitle),
      ),
    );
  }
}
