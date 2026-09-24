import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/job_status.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../../requests/domain/usecases/get_requests.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/clients_failure.dart';
import '../../domain/usecases/get_clients.dart';

part 'clients_list_state.dart';

/// Backs the Clients tab: the client roster plus every request, so a
/// client's open-job count, and the roster's unmatched-sender reminders,
/// can be computed live instead of denormalized onto the client doc.
class ClientsListCubit extends Cubit<ClientsListState> {
  final GetClients _getClients;
  final GetRequests _getRequests;

  StreamSubscription<List<Client>>? _clientsSubscription;
  StreamSubscription<List<InspectionRequest>>? _requestsSubscription;

  ClientsListCubit(this._getClients, this._getRequests) : super(const ClientsListState());

  void start() {
    if (_clientsSubscription != null) return;
    _clientsSubscription = _getClients().listen(
      (clients) => emit(
        state.copyWith(status: ClientsListStatus.ready, clients: clients, clearFailure: true),
      ),
      onError: (Object error) => emit(
        state.copyWith(
          status: ClientsListStatus.error,
          failure: error is ClientsFailure ? error.code : ClientsFailureCode.unknown,
        ),
      ),
    );

    // Supplementary — open-job counts and unmatched senders just read as
    // zero/empty until this arrives, rather than blocking the roster.
    _requestsSubscription = _getRequests().listen(
      (requests) => emit(state.copyWith(requests: requests)),
      onError: (_) {},
    );
  }

  void setFilter(ClientsFilter filter) {
    if (filter != state.filter) emit(state.copyWith(filter: filter));
  }

  void setQuery(String query) {
    if (query != state.query) emit(state.copyWith(query: query));
  }

  @override
  Future<void> close() async {
    await _clientsSubscription?.cancel();
    await _requestsSubscription?.cancel();
    return super.close();
  }
}
