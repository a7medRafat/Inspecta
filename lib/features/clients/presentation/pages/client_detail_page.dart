import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_layout.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/framework/mtoast.dart';
import '../../../../core/shared/loading.dart';
import '../../../../core/shared/m_back_button.dart';
import '../../../../core/shared/m_notice.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../requests/presentation/pages/request_detail_page.dart';
import '../../domain/entities/client_contact.dart';
import '../../domain/entities/clients_failure.dart';
import '../../domain/usecases/add_contact.dart';
import '../../domain/usecases/set_certificates_email.dart';
import '../bloc/client_detail_cubit.dart';
import '../widgets/add_contact_sheet.dart';
import '../widgets/client_avatar.dart';
import '../widgets/client_contacts_section.dart';
import '../widgets/client_history_list.dart';
import '../widgets/client_history_tab_bar.dart';
import '../widgets/client_stat_tiles.dart';
import '../widgets/clients_labels.dart';

/// The client detail screen: who they are, their contacts, and their
/// history across requests, equipment and certificates.
class ClientDetailPage extends StatelessWidget {
  final String clientId;

  const ClientDetailPage({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ClientDetailCubit>(param1: clientId)..start(),
      child: const _ClientDetailView(),
    );
  }
}

class _ClientDetailView extends StatelessWidget {
  const _ClientDetailView();

  void _comingSoon(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(t.comingSoon), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _call(BuildContext context, ClientContact? contact) async {
    final t = AppLocalizations.of(context)!;
    final phone = contact?.phone;
    if (phone == null || phone.isEmpty) {
      MToast.showError(message: t.noPhoneNumber);
      return;
    }
    await Clipboard.setData(ClipboardData(text: phone));
    if (context.mounted) MToast.showSuccess(message: t.phoneCopied);
  }

  Future<void> _email(BuildContext context, ClientContact? contact) async {
    final t = AppLocalizations.of(context)!;
    final email = contact?.email;
    if (email == null || email.isEmpty) {
      MToast.showError(message: t.noEmailOnFile);
      return;
    }
    await Clipboard.setData(ClipboardData(text: email));
    if (context.mounted) MToast.showSuccess(message: t.emailCopied);
  }

  Future<void> _addContact(BuildContext context, String clientId) async {
    final t = AppLocalizations.of(context)!;
    await AddContactSheet.show(
      context,
      onSubmit: (contact) async {
        try {
          await getIt<AddContact>()(clientId, contact);
          if (context.mounted) MToast.showSuccess(message: t.contactAdded);
        } catch (e) {
          if (context.mounted) {
            MToast.showError(message: e is ClientsFailure ? e.code.message(t) : t.actionFailed);
          }
        }
      },
    );
  }

  Future<void> _changeCertificatesEmail(BuildContext context, String clientId, String? current) async {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: current);
    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.certificatesSentToLabel),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(t.changeAction),
          ),
        ],
      ),
    );
    if (email == null || email.isEmpty) return;
    try {
      await getIt<SetCertificatesEmail>()(clientId, email);
      if (context.mounted) MToast.showSuccess(message: t.certificatesEmailUpdated);
    } catch (e) {
      if (context.mounted) {
        MToast.showError(message: e is ClientsFailure ? e.code.message(t) : t.actionFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: BlocBuilder<ClientDetailCubit, ClientDetailState>(
          builder: (context, state) {
            if (state.status == ClientDetailStatus.loading) {
              return Loading.loader(context);
            }
            final client = state.client;
            if (state.status == ClientDetailStatus.error || client == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: MNotice(
                    type: MNoticeType.error,
                    message: state.failure?.message(t) ?? t.actionFailed,
                  ),
                ),
              );
            }

            final contact = client.mainContact;
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: AppColours.border)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const MBackButton(),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () => _comingSoon(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 44),
                              foregroundColor: AppColours.inkBody,
                              side: const BorderSide(color: Color(0xFFD6E0F2), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(t.clientDetailEdit),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          ClientAvatar(companyName: client.companyName, size: 60),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  client.companyName,
                                  style: AppTextStyles.pageTitle.copyWith(fontSize: 22),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  client.location,
                                  style: AppTextStyles.subtitle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () => _comingSoon(context),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: Text(t.newRequestButton),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColours.primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  textStyle: AppTextStyles.buttonLabel.copyWith(fontSize: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: () => _call(context, contact),
                                icon: const Icon(Icons.call_outlined, size: 16),
                                label: Text(t.callAction),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColours.primaryDark,
                                  side: const BorderSide(color: AppColours.primaryTint, width: 1.5),
                                  textStyle: AppTextStyles.buttonLabel.copyWith(fontSize: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: () => _email(context, contact),
                                icon: const Icon(Icons.mail_outline_rounded, size: 16),
                                label: Text(t.emailAction),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColours.primaryDark,
                                  side: const BorderSide(color: AppColours.primaryTint, width: 1.5),
                                  textStyle: AppTextStyles.buttonLabel.copyWith(fontSize: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, AppLayout.bottomNavClearance),
                    children: [
                      ClientStatTiles(
                        equipmentCount: client.equipmentCount,
                        openJobsCount: state.openJobsCount,
                        dueSoonCount: client.dueSoonCount(),
                      ),
                      const SizedBox(height: 14),
                      ClientContactsSection(
                        contacts: client.contacts,
                        certificatesEmail: client.certificatesEmail,
                        onAddContact: () => _addContact(context, client.id),
                        onChangeCertificatesEmail: () => _changeCertificatesEmail(
                          context,
                          client.id,
                          client.certificatesEmail,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClientHistoryTabBar(
                        selected: state.tab,
                        onChanged: context.read<ClientDetailCubit>().setTab,
                      ),
                      const SizedBox(height: 12),
                      switch (state.tab) {
                        ClientHistoryTab.requests when state.requests.isEmpty =>
                          ClientHistoryEmptyState(message: t.clientHistoryEmptyRequests),
                        ClientHistoryTab.requests => Column(
                          children: [
                            for (final request in state.requests) ...[
                              ClientRequestRow(
                                key: ValueKey(request.id),
                                request: request,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => RequestDetailPage(request: request),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ],
                        ),
                        ClientHistoryTab.equipment when client.equipment.isEmpty =>
                          ClientHistoryEmptyState(message: t.clientHistoryEmptyEquipment),
                        ClientHistoryTab.equipment => Column(
                          children: [
                            for (final item in client.equipment) ...[
                              ClientEquipmentRow(key: ValueKey(item.id), item: item),
                              const SizedBox(height: 10),
                            ],
                          ],
                        ),
                        ClientHistoryTab.certificates => ClientHistoryEmptyState(
                          message: t.clientHistoryEmptyCertificates,
                        ),
                      },
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
