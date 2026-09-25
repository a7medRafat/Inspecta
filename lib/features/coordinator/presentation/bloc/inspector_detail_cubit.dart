import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/job_status.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../../requests/domain/entities/requests_failure.dart';
import '../../domain/entities/coordinator_failure.dart';
import '../../domain/inspector_day_summary.dart';
import '../../domain/usecases/mark_inspector_leave.dart';
import '../../../requests/domain/usecases/get_requests.dart';

part 'inspector_detail_state.dart';

/// Feature 04 §5's inspector detail screen: this inspector's today,
/// this week, this month, and their upcoming tasks — all derived from
/// the shared requests stream, filtered to jobs assigned to them.
class InspectorDetailCubit extends Cubit<InspectorDetailState> {
  final AppUser inspector;
  final GetRequests _getRequests;
  final MarkInspectorLeave _markInspectorLeave;

  StreamSubscription<List<InspectionRequest>>? _subscription;

  InspectorDetailCubit({
    required this.inspector,
    required GetRequests getRequests,
    required MarkInspectorLeave markInspectorLeave,
  }) : _getRequests = getRequests,
       _markInspectorLeave = markInspectorLeave,
       super(const InspectorDetailState());

  void start() {
    if (_subscription != null) return;
    _subscription = _getRequests().listen(
      (requests) => emit(
        state.copyWith(
          status: InspectorDetailStatus.ready,
          requests: requests.where((r) => r.inspectorId == inspector.id).toList(),
        ),
      ),
      onError: (Object error) => emit(state.copyWith(status: InspectorDetailStatus.error)),
    );
  }

  InspectorDaySummary get todaySummary => InspectorDaySummary.compute(inspector, state.requests);

  static DateTime _startOfWeek(DateTime day) {
    // Week starts Sunday (weekday 7 in Dart), matching the mockup.
    final daysSinceSunday = day.weekday % 7;
    final date = DateTime(day.year, day.month, day.day);
    return date.subtract(Duration(days: daysSinceSunday));
  }

  /// The current week's dates, Sunday first.
  List<DateTime> get weekDates {
    final start = _startOfWeek(DateTime.now());
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  /// Task counts for each day of the current week, Sunday first.
  List<int> get weekTaskCounts => weekDates.map((day) {
    return state.requests.where((r) {
      final at = r.scheduledAt;
      return at != null && at.year == day.year && at.month == day.month && at.day == day.day;
    }).length;
  }).toList();

  /// Jobs still ahead of this inspector — assigned but not yet certified.
  List<InspectionRequest> get upcomingTasks {
    final upcoming = state.requests.where((r) => r.isAssignedOrLater).toList()
      ..sort((a, b) => (a.scheduledAt ?? DateTime(9999)).compareTo(b.scheduledAt ?? DateTime(9999)));
    return upcoming;
  }

  /// This calendar month's completed/returned counts and a defensible
  /// "on time" proxy (completed without being sent back for rework) —
  /// there's no tracked completion-vs-deadline timestamp to measure
  /// on-time-ness more precisely than that.
  ({int done, int returned, int? onTimePercent}) get monthlyStats {
    final now = DateTime.now();
    final thisMonth = state.requests.where((r) {
      final at = r.scheduledAt;
      return at != null && at.year == now.year && at.month == now.month;
    });
    const doneStatuses = {
      JobStatus.certificateSubmitted,
      JobStatus.certificateReturned,
      JobStatus.certificateApproved,
      JobStatus.sentToClient,
    };
    final done = thisMonth.where((r) => doneStatuses.contains(r.status)).length;
    final returned = thisMonth.where((r) => r.status == JobStatus.certificateReturned).length;
    final onTimePercent = done == 0 ? null : (((done - returned) / done) * 100).round();
    return (done: done, returned: returned, onTimePercent: onTimePercent);
  }

  Future<void> markLeave(DateTime until) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true));
    try {
      await _markInspectorLeave(inspector.id, until);
      _complete(success: true);
    } catch (e) {
      _complete(success: false, failure: _mapFailure(e));
    }
  }

  CoordinatorFailureCode _mapFailure(Object error) {
    if (error is CoordinatorFailure) return error.code;
    if (error is RequestsFailure) {
      return switch (error.code) {
        RequestsFailureCode.permissionDenied => CoordinatorFailureCode.permissionDenied,
        RequestsFailureCode.network => CoordinatorFailureCode.network,
        RequestsFailureCode.unknown => CoordinatorFailureCode.unknown,
      };
    }
    return CoordinatorFailureCode.unknown;
  }

  void _complete({required bool success, CoordinatorFailureCode? failure}) {
    if (isClosed) return;
    emit(
      state.copyWith(
        isSubmitting: false,
        actionSeq: state.actionSeq + 1,
        lastActionSuccess: success,
        lastActionFailure: failure,
        clearFailure: failure == null,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
