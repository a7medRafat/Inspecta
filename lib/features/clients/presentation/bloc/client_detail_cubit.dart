import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/job_status.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../../requests/domain/usecases/get_requests.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/clients_failure.dart';
import '../../domain/usecases/get_client_detail.dart';

part 'client_detail_state.dart';

/// Backs the client detail screen: the client itself (fetched once — a
/// company's own record doesn't change while you're looking at it) plus
/// its request history, filtered live from the same stream the inbox
/// uses.
class ClientDetailCubit extends Cubit<ClientDetailState> {
  final String clientId;
  final GetClientDetail _getClientDetail;
  final GetRequests _getRequests;

  StreamSubscription<List<InspectionRequest>>? _requestsSubscription;

  ClientDetailCubit({
    required this.clientId,
    required GetClientDetail getClientDetail,
    required GetRequests getRequests,
  }) : _getClientDetail = getClientDetail,
       _getRequests = getRequests,
       super(const ClientDetailState());

  Future<void> start() async {
    try {
      final client = await _getClientDetail(clientId);
      emit(
        client == null
            ? state.copyWith(
                status: ClientDetailStatus.error,
                failure: ClientsFailureCode.unknown,
              )
            : state.copyWith(status: ClientDetailStatus.ready, client: client),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ClientDetailStatus.error,
          failure: e is ClientsFailure ? e.code : ClientsFailureCode.unknown,
        ),
      );
    }

    _requestsSubscription = _getRequests().listen((all) {
      emit(state.copyWith(requests: all.where((r) => r.clientId == clientId).toList()));
    }, onError: (_) {});
  }

  void setTab(ClientHistoryTab tab) {
    if (tab != state.tab) emit(state.copyWith(tab: tab));
  }

  @override
  Future<void> close() async {
    await _requestsSubscription?.cancel();
    return super.close();
  }
}
