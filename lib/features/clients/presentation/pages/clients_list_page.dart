import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_layout.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/framework/mtoast.dart';
import '../../../../core/shared/loading.dart';
import '../../../../core/shared/m_notice.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../../requests/domain/entities/requests_failure.dart';
import '../../../requests/domain/usecases/assign_client.dart';
import '../../../requests/presentation/widgets/requests_labels.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/client_contact.dart';
import '../../domain/entities/clients_failure.dart' show ClientsFailure;
import '../../domain/usecases/create_client.dart';
import '../bloc/clients_list_cubit.dart';
import '../widgets/add_client_sheet.dart';
import '../widgets/client_card.dart';
import '../widgets/clients_filter_chips.dart';
import '../widgets/clients_labels.dart';
import '../widgets/clients_list_header.dart';
import '../widgets/match_client_sheet.dart';
import '../widgets/unmatched_sender_card.dart';
import 'client_detail_page.dart';

/// The Clients tab: the roster, who's due for a nudge, and unmatched
/// senders waiting to be tied to a known client (BR-02.4).
class ClientsListPage extends StatelessWidget {
  const ClientsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ClientsListCubit>()..start(),
      child: const _ClientsListView(),
    );
  }
}

class _ClientsListView extends StatefulWidget {
  const _ClientsListView();

  @override
  State<_ClientsListView> createState() => _ClientsListViewState();
}

class _ClientsListViewState extends State<_ClientsListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openClient(Client client) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ClientDetailPage(clientId: client.id)),
    );
  }

  Future<void> _addClient({Client? preselectRequest}) async {
    final t = AppLocalizations.of(context)!;
    await AddClientSheet.show(
      context,
      onSubmit: ({required companyName, required location, required mainContact}) async {
        try {
          await getIt<CreateClient>()(
            companyName: companyName,
            location: location,
            mainContact: mainContact,
          );
          if (mounted) MToast.showSuccess(message: t.clientCreated);
        } catch (e) {
          if (mounted) {
            MToast.showError(message: e is ClientsFailure ? e.code.message(t) : t.actionFailed);
          }
        }
      },
    );
  }

  Future<void> _matchRequest(InspectionRequest request, List<Client> clients) async {
    final t = AppLocalizations.of(context)!;

    Future<void> assign(String clientId) async {
      try {
        await getIt<AssignClient>()(request.id, clientId);
        if (mounted) MToast.showSuccess(message: t.clientMatched);
      } catch (e) {
        if (mounted) {
          MToast.showError(message: e is RequestsFailure ? e.code.message(t) : t.actionFailed);
        }
      }
    }

    await MatchClientSheet.show(
      context,
      senderEmail: request.emailFrom ?? request.clientName,
      clients: clients,
      onSelectClient: (client) {
        Navigator.of(context).pop();
        assign(client.id);
      },
      onNewClient: () async {
        Navigator.of(context).pop();
        await AddClientSheet.show(
          context,
          onSubmit: ({required companyName, required location, required mainContact}) async {
            try {
              final clientId = await getIt<CreateClient>()(
                companyName: companyName,
                location: location,
                mainContact: mainContact,
              );
              await assign(clientId);
            } catch (e) {
              if (mounted) {
                MToast.showError(
                  message: e is ClientsFailure ? e.code.message(t) : t.actionFailed,
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColours.background,
      body: Column(
        children: [
          BlocBuilder<ClientsListCubit, ClientsListState>(
            buildWhen: (previous, current) => previous.clients != current.clients,
            builder: (context, state) {
              return ClientsListHeader(
                searchController: _searchController,
                onSearchChanged: context.read<ClientsListCubit>().setQuery,
                onAddClient: _addClient,
              );
            },
          ),
          Expanded(
            child: BlocBuilder<ClientsListCubit, ClientsListState>(
              builder: (context, state) {
                if (state.status == ClientsListStatus.loading) {
                  return Loading.loader(context);
                }
                if (state.status == ClientsListStatus.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: MNotice(type: MNoticeType.error, message: state.failure!.message(t)),
                    ),
                  );
                }

                final visible = state.visible;
                final unmatched = state.unmatched;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    AppLayout.bottomNavClearance,
                  ),
                  children: [
                    ClientsFilterChips(
                      selected: state.filter,
                      allCount: state.clients.length,
                      openJobsCount: state.clients
                          .where((c) => state.openJobsCountFor(c.id) > 0)
                          .length,
                      dueSoonCount: state.clients.where((c) => c.dueSoonCount() > 0).length,
                      onChanged: context.read<ClientsListCubit>().setFilter,
                    ),
                    const SizedBox(height: 10),
                    Text(t.clientsSortedByActivity, style: AppTextStyles.caption),
                    const SizedBox(height: 14),
                    if (visible.isEmpty && unmatched.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            state.query.trim().isNotEmpty
                                ? t.emptySearch(state.query.trim())
                                : t.clientsEmpty,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.subtitle,
                          ),
                        ),
                      )
                    else ...[
                      for (final client in visible) ...[
                        ClientCard(
                          key: ValueKey(client.id),
                          client: client,
                          openJobsCount: state.openJobsCountFor(client.id),
                          onTap: () => _openClient(client),
                        ),
                        const SizedBox(height: 10),
                      ],
                      for (final request in unmatched) ...[
                        UnmatchedSenderCard(
                          key: ValueKey(request.id),
                          senderEmail: request.emailFrom ?? request.clientName,
                          onMatch: () => _matchRequest(request, state.clients),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
