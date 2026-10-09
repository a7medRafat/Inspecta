import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../coordinator/domain/usecases/get_inspectors.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../../requests/domain/usecases/get_requests.dart';
import '../../domain/entities/timesheet_entry.dart';
import '../../domain/entities/timesheet_entry_status.dart';
import '../../domain/entities/timesheet_failure.dart';
import '../../domain/usecases/approve_timesheet_entry.dart';
import '../../domain/usecases/return_timesheet_entry.dart';
import '../../domain/usecases/watch_all_timesheets.dart';

part 'timesheet_review_state.dart';

/// Backs the coordinator's Timesheets tab: every inspector's logged time
/// and price, bucketed by where the review stands, with approve and
/// return-with-a-note.
class TimesheetReviewCubit extends Cubit<TimesheetReviewState> {
  final String reviewerId;
  final String reviewerName;
  final WatchAllTimesheets _watchAll;
  final GetRequests _getRequests;
  final GetInspectors _getInspectors;
  final ApproveTimesheetEntry _approve;
  final ReturnTimesheetEntry _return;

  StreamSubscription<List<TimesheetEntry>>? _entriesSubscription;
  StreamSubscription<List<InspectionRequest>>? _requestsSubscription;
  StreamSubscription<List<AppUser>>? _inspectorsSubscription;

  TimesheetReviewCubit({
    required this.reviewerId,
    required this.reviewerName,
    required WatchAllTimesheets watchAllTimesheets,
    required GetRequests getRequests,
    required GetInspectors getInspectors,
    required ApproveTimesheetEntry approveEntry,
    required ReturnTimesheetEntry returnEntry,
  }) : _watchAll = watchAllTimesheets,
       _getRequests = getRequests,
       _getInspectors = getInspectors,
       _approve = approveEntry,
       _return = returnEntry,
       super(TimesheetReviewState());

  void start() {
    if (_entriesSubscription != null) return;
    _entriesSubscription = _watchAll().listen(
      (entries) => emit(
        state.copyWith(status: TimesheetReviewStatus.ready, entries: entries, clearFailure: true),
      ),
      onError: (Object error) => emit(
        state.copyWith(
          status: TimesheetReviewStatus.error,
          failure: error is TimesheetFailure ? error.code : TimesheetFailureCode.unknown,
        ),
      ),
    );

    // Supplementary — a card falls back to the job id and a blank
    // inspector name until these arrive (or if they never do), rather
    // than holding up the list.
    _requestsSubscription = _getRequests().listen(
      (requests) => emit(state.copyWith(requests: requests)),
      onError: (_) {},
    );
    _inspectorsSubscription = _getInspectors().listen(
      (inspectors) => emit(state.copyWith(inspectors: inspectors)),
      onError: (_) {},
    );
  }

  Future<void> retry() async {
    await _entriesSubscription?.cancel();
    _entriesSubscription = null;
    emit(state.copyWith(status: TimesheetReviewStatus.loading, clearFailure: true));
    start();
  }

  void setFilter(TimesheetEntryStatus filter) => emit(state.copyWith(filter: filter));

  /// Returns `null` on success, or why it failed so the caller can show it.
  Future<TimesheetFailureCode?> approve(String requestId) => _decide(
    requestId,
    () => _approve(requestId: requestId, reviewerId: reviewerId, reviewerName: reviewerName),
  );

  Future<TimesheetFailureCode?> sendBack(String requestId, String note) => _decide(
    requestId,
    () => _return(requestId: requestId, reviewerId: reviewerId, reviewerName: reviewerName, note: note),
  );

  /// Marks [requestId] busy while [action] runs so its card can disable
  /// its buttons. Callers check [TimesheetReviewState.busyRequestId] first
  /// — a call made while another is in flight would otherwise be easy to
  /// mistake for a success.
  Future<TimesheetFailureCode?> _decide(String requestId, Future<void> Function() action) async {
    emit(state.copyWith(busyRequestId: requestId));
    try {
      await action();
      return null;
    } catch (e) {
      return e is TimesheetFailure ? e.code : TimesheetFailureCode.unknown;
    } finally {
      if (!isClosed) emit(state.copyWith(clearBusy: true));
    }
  }

  @override
  Future<void> close() async {
    await _entriesSubscription?.cancel();
    await _requestsSubscription?.cancel();
    await _inspectorsSubscription?.cancel();
    return super.close();
  }
}
