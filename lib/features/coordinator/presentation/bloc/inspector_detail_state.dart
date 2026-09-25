part of 'inspector_detail_cubit.dart';

enum InspectorDetailStatus { loading, ready, error }

class InspectorDetailState extends Equatable {
  final InspectorDetailStatus status;
  final List<InspectionRequest> requests;

  final bool isSubmitting;
  final int actionSeq;
  final bool lastActionSuccess;
  final CoordinatorFailureCode? lastActionFailure;

  const InspectorDetailState({
    this.status = InspectorDetailStatus.loading,
    this.requests = const [],
    this.isSubmitting = false,
    this.actionSeq = 0,
    this.lastActionSuccess = false,
    this.lastActionFailure,
  });

  InspectorDetailState copyWith({
    InspectorDetailStatus? status,
    List<InspectionRequest>? requests,
    bool? isSubmitting,
    int? actionSeq,
    bool? lastActionSuccess,
    CoordinatorFailureCode? lastActionFailure,
    bool clearFailure = false,
  }) {
    return InspectorDetailState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionSeq: actionSeq ?? this.actionSeq,
      lastActionSuccess: lastActionSuccess ?? this.lastActionSuccess,
      lastActionFailure: clearFailure ? null : (lastActionFailure ?? this.lastActionFailure),
    );
  }

  @override
  List<Object?> get props => [status, requests, isSubmitting, actionSeq, lastActionSuccess, lastActionFailure];
}
