part of 'assign_inspector_cubit.dart';

enum InspectorsStatus { loading, ready, error }

class AssignInspectorState extends Equatable {
  final InspectorsStatus inspectorsStatus;
  final List<AppUser> inspectors;
  final Set<String> matchedInspectorIds;
  final CoordinatorFailureCode? inspectorsFailure;

  final String? selectedInspectorId;
  final DateTime scheduledAt;
  final String note;
  final bool submitted;

  final bool isSubmitting;
  final int actionSeq;
  final bool lastActionSuccess;
  final CoordinatorFailureCode? lastActionFailure;

  const AssignInspectorState({
    required this.scheduledAt,
    this.inspectorsStatus = InspectorsStatus.loading,
    this.inspectors = const [],
    this.matchedInspectorIds = const {},
    this.inspectorsFailure,
    this.selectedInspectorId,
    this.note = '',
    this.submitted = false,
    this.isSubmitting = false,
    this.actionSeq = 0,
    this.lastActionSuccess = false,
    this.lastActionFailure,
  });

  AppUser? get selectedInspector {
    for (final inspector in inspectors) {
      if (inspector.id == selectedInspectorId) return inspector;
    }
    return null;
  }

  AssignInspectorState copyWith({
    InspectorsStatus? inspectorsStatus,
    List<AppUser>? inspectors,
    Set<String>? matchedInspectorIds,
    CoordinatorFailureCode? inspectorsFailure,
    String? selectedInspectorId,
    DateTime? scheduledAt,
    String? note,
    bool? submitted,
    bool? isSubmitting,
    int? actionSeq,
    bool? lastActionSuccess,
    CoordinatorFailureCode? lastActionFailure,
    bool clearFailure = false,
  }) {
    return AssignInspectorState(
      inspectorsStatus: inspectorsStatus ?? this.inspectorsStatus,
      inspectors: inspectors ?? this.inspectors,
      matchedInspectorIds: matchedInspectorIds ?? this.matchedInspectorIds,
      inspectorsFailure: inspectorsFailure ?? this.inspectorsFailure,
      selectedInspectorId: selectedInspectorId ?? this.selectedInspectorId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      note: note ?? this.note,
      submitted: submitted ?? this.submitted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionSeq: actionSeq ?? this.actionSeq,
      lastActionSuccess: lastActionSuccess ?? this.lastActionSuccess,
      lastActionFailure: clearFailure ? null : (lastActionFailure ?? this.lastActionFailure),
    );
  }

  @override
  List<Object?> get props => [
    inspectorsStatus,
    inspectors,
    matchedInspectorIds,
    inspectorsFailure,
    selectedInspectorId,
    scheduledAt,
    note,
    submitted,
    isSubmitting,
    actionSeq,
    lastActionSuccess,
    lastActionFailure,
  ];
}
