import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/job_status.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../coordinator/domain/usecases/get_inspectors.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../../requests/domain/entities/requests_failure.dart';
import '../../../requests/domain/usecases/get_requests.dart';

part 'review_queue_state.dart';

/// Backs the technical manager's Review and Sent tabs (Feature 06): every
/// job whose certificate is waiting for a signature, was sent back, or has
/// gone out to the client.
class ReviewQueueCubit extends Cubit<ReviewQueueState> {
  final GetRequests _getRequests;
  final GetInspectors _getInspectors;

  StreamSubscription<List<InspectionRequest>>? _requestsSubscription;
  StreamSubscription<List<AppUser>>? _inspectorsSubscription;

  ReviewQueueCubit(this._getRequests, this._getInspectors) : super(const ReviewQueueState());

  void start() {
    if (_requestsSubscription != null) return;
    _requestsSubscription = _getRequests().listen(
      (requests) => emit(state.copyWith(status: ReviewQueueStatus.ready, requests: requests, clearFailure: true)),
      onError: (Object error) => emit(
        state.copyWith(
          status: ReviewQueueStatus.error,
          failure: error is RequestsFailure ? error.code : RequestsFailureCode.unknown,
        ),
      ),
    );
    // Names are a nicety for the cards — if this read is refused the
    // queue still works, it just can't say who the inspector was.
    _inspectorsSubscription = _getInspectors().listen(
      (inspectors) => emit(state.copyWith(inspectorNames: {for (final i in inspectors) i.id: i.name})),
      onError: (_) {},
    );
  }

  Future<void> retry() async {
    await _requestsSubscription?.cancel();
    await _inspectorsSubscription?.cancel();
    _requestsSubscription = null;
    _inspectorsSubscription = null;
    emit(state.copyWith(status: ReviewQueueStatus.loading, clearFailure: true));
    start();
  }

  @override
  Future<void> close() async {
    await _requestsSubscription?.cancel();
    await _inspectorsSubscription?.cancel();
    return super.close();
  }
}
