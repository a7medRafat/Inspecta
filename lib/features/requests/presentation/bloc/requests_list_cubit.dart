import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/inspection_request.dart';
import '../../domain/entities/requests_failure.dart';
import '../../domain/entities/requests_tab.dart';
import '../../domain/usecases/get_requests.dart';

part 'requests_list_state.dart';

/// Backs the requests inbox: the live list plus the tab and search filter
/// applied to it.
class RequestsListCubit extends Cubit<RequestsListState> {
  final GetRequests _getRequests;

  StreamSubscription<List<InspectionRequest>>? _subscription;

  RequestsListCubit(this._getRequests) : super(const RequestsListState());

  /// Starts listening to the inbox. Safe to call more than once.
  void start() {
    if (_subscription != null) return;
    _subscription = _getRequests().listen(
      (requests) => emit(
        state.copyWith(
          status: RequestsListStatus.ready,
          requests: requests,
          clearFailure: true,
        ),
      ),
      onError: (Object error) => emit(
        state.copyWith(
          status: RequestsListStatus.error,
          failure: error is RequestsFailure
              ? error.code
              : RequestsFailureCode.unknown,
        ),
      ),
    );
  }

  void setTab(RequestsTab tab) {
    if (tab != state.tab) emit(state.copyWith(tab: tab));
  }

  void setQuery(String query) {
    if (query != state.query) emit(state.copyWith(query: query));
  }

  Future<void> retry() async {
    await _subscription?.cancel();
    _subscription = null;
    emit(state.copyWith(status: RequestsListStatus.loading, clearFailure: true));
    start();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
