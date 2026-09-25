part of 'coordinator_queue_cubit.dart';

enum CoordinatorQueueStatus { loading, ready, error }

class CoordinatorQueueState extends Equatable {
  final CoordinatorQueueStatus status;
  final List<InspectionRequest> requests;
  final List<AppUser> inspectors;
  final RequestsFailureCode? failure;

  const CoordinatorQueueState({
    this.status = CoordinatorQueueStatus.loading,
    this.requests = const [],
    this.inspectors = const [],
    this.failure,
  });

  /// Every job still on the coordinator's radar: waiting on an inspector,
  /// or already assigned/running — soonest due date first.
  List<InspectionRequest> get jobs {
    final visible = requests.where((r) => r.isReadyToAssign || r.isAssignedOrLater).toList()
      ..sort((a, b) => _dueKey(a).compareTo(_dueKey(b)));
    return visible;
  }

  /// Just the jobs waiting on an inspector — the "+ Assign a job" picker
  /// on an inspector's detail screen only offers these.
  List<InspectionRequest> get readyToAssign {
    final visible = requests.where((r) => r.isReadyToAssign).toList()
      ..sort((a, b) => _dueKey(a).compareTo(_dueKey(b)));
    return visible;
  }

  int get unassignedCount => requests.where((r) => r.isReadyToAssign).length;

  int get scheduledCount => requests.where((r) => r.status == JobStatus.assigned).length;

  int get inProgressCount => requests
      .where((r) => r.status == JobStatus.taskAccepted || r.status == JobStatus.inProgress)
      .length;

  /// The assigned inspector's name for a job's card, or `null` while the
  /// roster is still loading (or the id no longer matches anyone).
  String? inspectorName(String? inspectorId) {
    if (inspectorId == null) return null;
    for (final inspector in inspectors) {
      if (inspector.id == inspectorId) return inspector.name;
    }
    return null;
  }

  static final DateTime _farFuture = DateTime(9999);

  static DateTime _dueKey(InspectionRequest r) =>
      r.scheduledAt ?? r.preferredDate ?? _farFuture;

  CoordinatorQueueState copyWith({
    CoordinatorQueueStatus? status,
    List<InspectionRequest>? requests,
    List<AppUser>? inspectors,
    RequestsFailureCode? failure,
    bool clearFailure = false,
  }) {
    return CoordinatorQueueState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      inspectors: inspectors ?? this.inspectors,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, requests, inspectors, failure];
}
