part of 'review_queue_cubit.dart';

enum ReviewQueueStatus { loading, ready, error }

class ReviewQueueState extends Equatable {
  final ReviewQueueStatus status;
  final List<InspectionRequest> requests;
  final Map<String, String> inspectorNames;
  final RequestsFailureCode? failure;

  const ReviewQueueState({
    this.status = ReviewQueueStatus.loading,
    this.requests = const [],
    this.inspectorNames = const {},
    this.failure,
  });

  List<InspectionRequest> _with(JobStatus status) {
    final list = requests.where((r) => r.status == status).toList()
      ..sort((a, b) => _sortKey(b).compareTo(_sortKey(a)));
    return list;
  }

  static DateTime _sortKey(InspectionRequest r) => r.scheduledAt ?? r.receivedAt;

  List<InspectionRequest> get toReview => _with(JobStatus.certificateSubmitted);

  List<InspectionRequest> get returned => _with(JobStatus.certificateReturned);

  List<InspectionRequest> get sent => _with(JobStatus.sentToClient);

  String? inspectorName(InspectionRequest request) => inspectorNames[request.inspectorId];

  ReviewQueueState copyWith({
    ReviewQueueStatus? status,
    List<InspectionRequest>? requests,
    Map<String, String>? inspectorNames,
    RequestsFailureCode? failure,
    bool clearFailure = false,
  }) {
    return ReviewQueueState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      inspectorNames: inspectorNames ?? this.inspectorNames,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, requests, inspectorNames, failure];
}
