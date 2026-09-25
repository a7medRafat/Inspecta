import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../../requests/domain/entities/requests_failure.dart';
import '../../../requests/domain/usecases/get_requests.dart';
import '../../domain/usecases/get_inspectors.dart';

part 'schedule_state.dart';

/// Backs the coordinator's Schedule tab (Feature 04 §5, scope-cut #1): a
/// day view, one row per inspector — same underlying requests/inspector
/// streams as [CoordinatorQueueCubit], just sliced by the selected day
/// instead of by status.
class ScheduleCubit extends Cubit<ScheduleState> {
  final GetRequests _getRequests;
  final GetInspectors _getInspectors;

  StreamSubscription<List<InspectionRequest>>? _requestsSubscription;
  StreamSubscription<List<AppUser>>? _inspectorsSubscription;

  ScheduleCubit(this._getRequests, this._getInspectors) : super(ScheduleState());

  void start() {
    if (_requestsSubscription != null) return;
    _requestsSubscription = _getRequests().listen(
      (requests) => emit(
        state.copyWith(status: ScheduleStatus.ready, requests: requests, clearFailure: true),
      ),
      onError: (Object error) => emit(
        state.copyWith(
          status: ScheduleStatus.error,
          failure: error is RequestsFailure ? error.code : RequestsFailureCode.unknown,
        ),
      ),
    );

    _inspectorsSubscription = _getInspectors().listen(
      (inspectors) => emit(state.copyWith(inspectors: inspectors)),
      onError: (_) {},
    );
  }

  Future<void> retry() async {
    await _requestsSubscription?.cancel();
    _requestsSubscription = null;
    emit(state.copyWith(status: ScheduleStatus.loading, clearFailure: true));
    start();
  }

  void selectDate(DateTime date) => emit(state.copyWith(selectedDate: date));

  void goToPreviousDay() => selectDate(state.selectedDate.subtract(const Duration(days: 1)));

  void goToNextDay() => selectDate(state.selectedDate.add(const Duration(days: 1)));

  void goToToday() => selectDate(DateTime.now());

  @override
  Future<void> close() async {
    await _requestsSubscription?.cancel();
    await _inspectorsSubscription?.cancel();
    return super.close();
  }
}
