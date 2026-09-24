import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/client_contact.dart';

/// The client detail's Contacts card: every contact, who's main, and
/// where certificates get sent.
class ClientContactsSection extends StatelessWidget {
  final List<ClientContact> contacts;
  final String? certificatesEmail;
  final VoidCallback onAddContact;
  final VoidCallback onChangeCertificatesEmail;

  const ClientContactsSection({
    super.key,
    required this.contacts,
    required this.certificatesEmail,
    required this.onAddContact,
    required this.onChangeCertificatesEmail,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.contactsTitle,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: onAddContact,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  backgroundColor: AppColours.surfaceMuted,
                  foregroundColor: AppColours.primaryDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(t.addContactAction, style: AppTextStyles.badge.copyWith(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final contact in contacts) _ContactRow(contact: contact, t: t),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColours.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, color: AppColours.primaryDark, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.certificatesSentToLabel,
                        style: AppTextStyles.caption.copyWith(color: const Color(0xFF1E3A8A)),
                      ),
                      Text(
                        certificatesEmail?.isNotEmpty == true
                            ? certificatesEmail!
                            : t.noCertificatesEmail,
                        style: AppTextStyles.emphasis.copyWith(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onChangeCertificatesEmail,
                  child: Text(
                    t.changeAction,
                    style: AppTextStyles.link.copyWith(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final ClientContact contact;
  final AppLocalizations t;

  const _ContactRow({required this.contact, required this.t});

  String get _initials {
    final words = contact.name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      contact.role,
      contact.email,
    ].where((s) => s != null && s.isNotEmpty).join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColours.surfaceMuted,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: AppTextStyles.badge.copyWith(fontSize: 13, color: AppColours.inkBody),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        contact.name,
                        style: AppTextStyles.emphasis.copyWith(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (contact.isMain) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColours.chipBlueBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          t.mainContactBadge,
                          style: AppTextStyles.badge.copyWith(
                            fontSize: 10.5,
                            color: AppColours.chipBlueText,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: AppTextStyles.subtitle,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
