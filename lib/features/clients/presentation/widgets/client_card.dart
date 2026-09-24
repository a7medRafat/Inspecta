import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/client.dart';
import 'client_avatar.dart';

/// One row on the client roster: who they are, their main contact, and
/// the counts that matter — equipment on file, jobs still open, and
/// anything due soon.
class ClientCard extends StatelessWidget {
  final Client client;
  final int openJobsCount;
  final VoidCallback onTap;

  const ClientCard({
    super.key,
    required this.client,
    required this.openJobsCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final contact = client.mainContact;
    final dueSoon = client.dueSoonCount();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColours.ink.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClientAvatar(companyName: client.companyName),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            client.companyName,
                            style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (contact != null)
                            Text(
                              [
                                contact.name,
                                if (contact.role != null) contact.role,
                              ].join(' · '),
                              style: AppTextStyles.subtitle,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColours.inkMuted),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tag(
                      label: t.equipmentCountChip(client.equipmentCount),
                      background: AppColours.surfaceMuted,
                      text: AppColours.inkBody,
                    ),
                    if (openJobsCount > 0)
                      _Tag(
                        label: t.openJobsCountChip(openJobsCount),
                        background: AppColours.chipBlueBackground,
                        text: AppColours.chipBlueText,
                        bold: true,
                      ),
                    if (dueSoon > 0)
                      _Tag(
                        label: t.dueSoonCountChip(dueSoon),
                        background: AppColours.chipAmberBackground,
                        text: AppColours.chipAmberText,
                        bold: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color background;
  final Color text;
  final bool bold;

  const _Tag({
    required this.label,
    required this.background,
    required this.text,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(
          fontSize: 12,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}
