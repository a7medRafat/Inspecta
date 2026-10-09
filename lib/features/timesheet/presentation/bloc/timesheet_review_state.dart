part of 'timesheet_review_cubit.dart';

enum TimesheetReviewStatus { loading, ready, error }

/// One entry on the coordinator's list, with the job and inspector it
/// belongs to when those have loaded.
class TimesheetReviewItem extends Equatable {
  final TimesheetEntry entry;
  final InspectionRequest? request;
  final AppUser? inspector;

  const TimesheetReviewItem({required this.entry, this.request, this.inspector});

  @override
  List<Object?> get props => [entry, request, inspector];
}

class TimesheetReviewState extends Equatable {
  final TimesheetReviewStatus status;
  final List<TimesheetEntry> entries;
  final List<InspectionRequest> requests;
  final List<AppUser> inspectors;
  final TimesheetEntryStatus filter;
  final TimesheetFailureCode? failure;

  /// The job whose approve/return is in flight, if any.
  final String? busyRequestId;

  const TimesheetReviewState({
    this.status = TimesheetReviewStatus.loading,
    this.entries = const [],
    this.requests = const [],
    this.inspectors = const [],
    this.filter = TimesheetEntryStatus.pending,
    this.failure,
    this.busyRequestId,
  });

  int countOf(TimesheetEntryStatus status) => entries.where((e) => e.status == status).length;

  /// What's waiting on a decision, in piastres: the prices and the costs
  /// together, since both are money to be approved.
  int get pendingValuePiastres =>
      entries.where((e) => e.isPending).fold(0, (sum, e) => sum + e.totalPiastres);

  /// The entries under [filter]. What's waiting is oldest job first, so
  /// nothing sits unnoticed at the bottom; approved and returned are
  /// newest first, like a history.
  List<TimesheetReviewItem> get items {
    final requestById = {for (final r in requests) r.id: r};
    final inspectorById = {for (final i in inspectors) i.id: i};
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);

    DateTime when(TimesheetReviewItem item) =>
        item.request?.scheduledAt ?? item.entry.reviewedAt ?? epoch;

    final result = [
      for (final entry in entries)
        if (entry.status == filter)
          TimesheetReviewItem(
            entry: entry,
            request: requestById[entry.requestId],
            inspector: inspectorById[entry.inspectorId],
          ),
    ]..sort((a, b) => filter == TimesheetEntryStatus.pending ? when(a).compareTo(when(b)) : when(b).compareTo(when(a)));
    return result;
  }

  TimesheetReviewState copyWith({
    TimesheetReviewStatus? status,
    List<TimesheetEntry>? entries,
    List<InspectionRequest>? requests,
    List<AppUser>? inspectors,
    TimesheetEntryStatus? filter,
    TimesheetFailureCode? failure,
    bool clearFailure = false,
    String? busyRequestId,
    bool clearBusy = false,
  }) {
    return TimesheetReviewState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      requests: requests ?? this.requests,
      inspectors: inspectors ?? this.inspectors,
      filter: filter ?? this.filter,
      failure: clearFailure ? null : (failure ?? this.failure),
      busyRequestId: clearBusy ? null : (busyRequestId ?? this.busyRequestId),
    );
  }

  @override
  List<Object?> get props => [status, entries, requests, inspectors, filter, failure, busyRequestId];
}
