part of 'inspector_tasks_cubit.dart';

enum InspectorTasksStatus { loading, ready, error }

enum InspectorTaskAction { accept, decline, start }

class InspectorTasksState extends Equatable {
  final InspectorTasksStatus status;
  final List<InspectionRequest> requests;
  final DateTime selectedDate;
  final RequestsFailureCode? failure;

  final bool isSubmitting;
  final int actionSeq;
  final InspectorTaskAction? lastAction;
  final bool lastActionSuccess;
  final RequestsFailureCode? lastActionFailure;

  InspectorTasksState({
    this.status = InspectorTasksStatus.loading,
    this.requests = const [],
    DateTime? selectedDate,
    this.failure,
    this.isSubmitting = false,
    this.actionSeq = 0,
    this.lastAction,
    this.lastActionSuccess = false,
    this.lastActionFailure,
  }) : selectedDate = _dateOnly(selectedDate ?? DateTime.now());

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool get isToday => selectedDate == _dateOnly(DateTime.now());

  /// The day strip's 7 dates, the selected day always in the middle.
  List<DateTime> get weekDates => List.generate(7, (i) => selectedDate.add(Duration(days: i - 3)));

  /// This job is still open work for the inspector — not yet certified.
  static bool _isOpen(InspectionRequest r) =>
      r.status == JobStatus.assigned ||
      r.status == JobStatus.taskAccepted ||
      r.status == JobStatus.inProgress;

  /// Open jobs scheduled on [selectedDate], earliest first.
  List<InspectionRequest> get tasksForSelectedDate {
    final tasks = requests.where((r) {
      final at = r.scheduledAt;
      return _isOpen(r) && at != null && _dateOnly(at) == selectedDate;
    }).toList()
      ..sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));
    return tasks;
  }

  /// A task count per day for the day strip's pills.
  int taskCountFor(DateTime day) {
    final key = _dateOnly(day);
    return requests.where((r) {
      final at = r.scheduledAt;
      return _isOpen(r) && at != null && _dateOnly(at) == key;
    }).length;
  }

  /// The coordinator just assigned something the inspector hasn't
  /// responded to yet — the "New task" banner's trigger.
  InspectionRequest? get firstNeedsResponse {
    for (final r in tasksForSelectedDate) {
      if (r.status == JobStatus.assigned) return r;
    }
    return null;
  }

  InspectorTasksState copyWith({
    InspectorTasksStatus? status,
    List<InspectionRequest>? requests,
    DateTime? selectedDate,
    RequestsFailureCode? failure,
    bool clearFailure = false,
    bool? isSubmitting,
    int? actionSeq,
    InspectorTaskAction? lastAction,
    bool? lastActionSuccess,
    RequestsFailureCode? lastActionFailure,
    bool clearActionFailure = false,
  }) {
    return InspectorTasksState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      selectedDate: selectedDate ?? this.selectedDate,
      failure: clearFailure ? null : (failure ?? this.failure),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionSeq: actionSeq ?? this.actionSeq,
      lastAction: lastAction ?? this.lastAction,
      lastActionSuccess: lastActionSuccess ?? this.lastActionSuccess,
      lastActionFailure: clearActionFailure ? null : (lastActionFailure ?? this.lastActionFailure),
    );
  }

  @override
  List<Object?> get props => [
    status,
    requests,
    selectedDate,
    failure,
    isSubmitting,
    actionSeq,
    lastAction,
    lastActionSuccess,
    lastActionFailure,
  ];
}
