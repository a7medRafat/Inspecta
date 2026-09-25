import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../../requests/domain/usecases/get_requests.dart';
import '../../domain/entities/coordinator_failure.dart';
import '../../domain/inspector_day_summary.dart';
import '../../domain/usecases/get_inspectors.dart';

part 'inspectors_list_state.dart';

/// Backs the coordinator's Inspectors tab (Feature 04 §5): the roster,
/// the jobs needed to work out who's free/busy/on leave today, and the
/// search/category filter over it.
class InspectorsListCubit extends Cubit<InspectorsListState> {
  final GetInspectors _getInspectors;
  final GetRequests _getRequests;

  StreamSubscription<List<AppUser>>? _inspectorsSubscription;
  StreamSubscription<List<InspectionRequest>>? _requestsSubscription;

  InspectorsListCubit(this._getInspectors, this._getRequests) : super(const InspectorsListState());

  void start() {
    if (_inspectorsSubscription != null) return;
    _inspectorsSubscription = _getInspectors().listen(
      (inspectors) => emit(
        state.copyWith(status: InspectorsListStatus.ready, inspectors: inspectors, clearFailure: true),
      ),
      onError: (Object error) => emit(
        state.copyWith(
          status: InspectorsListStatus.error,
          failure: error is CoordinatorFailure ? error.code : CoordinatorFailureCode.unknown,
        ),
      ),
    );

    // Supplementary — today's slots/Busy-Now-Next just read as empty
    // until this arrives, rather than blocking the roster.
    _requestsSubscription = _getRequests().listen(
      (requests) => emit(state.copyWith(requests: requests)),
      onError: (_) {},
    );
  }

  void setQuery(String query) {
    if (query != state.query) emit(state.copyWith(query: query));
  }

  void setCategory(String? category) {
    if (category != state.categoryFilter) emit(state.copyWith(categoryFilter: category, clearCategory: category == null));
  }

  Future<void> retry() async {
    await _inspectorsSubscription?.cancel();
    _inspectorsSubscription = null;
    emit(state.copyWith(status: InspectorsListStatus.loading, clearFailure: true));
    start();
  }

  @override
  Future<void> close() async {
    await _inspectorsSubscription?.cancel();
    await _requestsSubscription?.cancel();
    return super.close();
  }
}
