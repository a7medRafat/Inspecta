import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/client.dart';
import 'client_avatar.dart';

/// Picks which known client an unmatched sender belongs to — or hands
/// back "create a new one" for the caller to open [AddClientSheet] for.
class MatchClientSheet extends StatelessWidget {
  final String senderEmail;
  final List<Client> clients;
  final ValueChanged<Client> onSelectClient;
  final VoidCallback onNewClient;

  const MatchClientSheet({
    super.key,
    required this.senderEmail,
    required this.clients,
    required this.onSelectClient,
    required this.onNewClient,
  });

  static Future<void> show(
    BuildContext context, {
    required String senderEmail,
    required List<Client> clients,
    required ValueChanged<Client> onSelectClient,
    required VoidCallback onNewClient,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MatchClientSheet(
        senderEmail: senderEmail,
        clients: clients,
        onSelectClient: onSelectClient,
        onNewClient: onNewClient,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColours.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text(t.matchSheetTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
              const SizedBox(height: 2),
              Text(senderEmail, style: AppTextStyles.subtitle, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Material(
                      color: AppColours.surfaceMuted,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: onNewClient,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.add_circle_outline, color: AppColours.primaryDark),
                              const SizedBox(width: 10),
                              Text(
                                t.matchNewClientOption,
                                style: AppTextStyles.emphasis.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final client in clients)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => onSelectClient(client),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                ClientAvatar(companyName: client.companyName, size: 38),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    client.companyName,
                                    style: AppTextStyles.emphasis.copyWith(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
