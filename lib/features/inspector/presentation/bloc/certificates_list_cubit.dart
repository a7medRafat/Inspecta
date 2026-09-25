import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/job_status.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../../requests/domain/entities/requests_failure.dart';
import '../../../certificate/domain/certificate_number.dart';
import '../../../requests/domain/usecases/get_my_tasks.dart';

part 'certificates_list_state.dart';

/// Backs the inspector's Certificates tab (Feature 05): every job past
/// intake that has (or needs) a certificate, bucketed into Action /
/// Submitted / Sent / All, with a search box over client, equipment and
/// the display cert number.
class CertificatesListCubit extends Cubit<CertificatesListState> {
  final String inspectorId;
  final GetMyTasks _getMyTasks;

  StreamSubscription<List<InspectionRequest>>? _subscription;

  CertificatesListCubit({required this.inspectorId, required GetMyTasks getMyTasks})
    : _getMyTasks = getMyTasks,
      super(const CertificatesListState());

  void start() {
    if (_subscription != null) return;
    _subscription = _getMyTasks(inspectorId).listen(
      (requests) => emit(
        state.copyWith(status: CertificatesListStatus.ready, requests: requests, clearFailure: true),
      ),
      onError: (Object error) => emit(
        state.copyWith(
          status: CertificatesListStatus.error,
          failure: error is RequestsFailure ? error.code : RequestsFailureCode.unknown,
        ),
      ),
    );
  }

  Future<void> retry() async {
    await _subscription?.cancel();
    _subscription = null;
    emit(state.copyWith(status: CertificatesListStatus.loading, clearFailure: true));
    start();
  }

  void setQuery(String query) => emit(state.copyWith(query: query));

  void setFilter(CertificatesFilter filter) => emit(state.copyWith(filter: filter));

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
