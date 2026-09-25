part of 'schedule_cubit.dart';

enum ScheduleStatus { loading, ready, error }

class ScheduleState extends Equatable {
  final ScheduleStatus status;
  final List<InspectionRequest> requests;
  final List<AppUser> inspectors;
  final DateTime selectedDate;
  final RequestsFailureCode? failure;

  ScheduleState({
    this.status = ScheduleStatus.loading,
    this.requests = const [],
    this.inspectors = const [],
    DateTime? selectedDate,
    this.failure,
  }) : selectedDate = _dateOnly(selectedDate ?? DateTime.now());

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool get isToday => selectedDate == _dateOnly(DateTime.now());

  /// The roster this screen lays out one row per, alphabetical — the
  /// same active inspectors [GetInspectors] already scopes to.
  List<AppUser> get activeInspectors {
    final sorted = [...inspectors]..sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  /// This inspector's tasks on [selectedDate], earliest first — the
  /// timeline blocks drawn on their row.
  List<InspectionRequest> tasksFor(String inspectorId) {
    final tasks = requests.where((r) {
      final at = r.scheduledAt;
      return r.inspectorId == inspectorId && at != null && _dateOnly(at) == selectedDate;
    }).toList()
      ..sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));
    return tasks;
  }

  bool isOnLeave(AppUser inspector) => inspector.isOnLeave(now: selectedDate);

  /// Every task across the whole roster on [selectedDate] — the header's
  /// "Scheduled" tile.
  int get totalTasksOnDate => requests.where((r) {
    final at = r.scheduledAt;
    return at != null && _dateOnly(at) == selectedDate;
  }).length;

  int get onLeaveCountOnDate => inspectors.where(isOnLeave).length;

  ScheduleState copyWith({
    ScheduleStatus? status,
    List<InspectionRequest>? requests,
    List<AppUser>? inspectors,
    DateTime? selectedDate,
    RequestsFailureCode? failure,
    bool clearFailure = false,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      inspectors: inspectors ?? this.inspectors,
      selectedDate: selectedDate ?? this.selectedDate,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, requests, inspectors, selectedDate, failure];
}
