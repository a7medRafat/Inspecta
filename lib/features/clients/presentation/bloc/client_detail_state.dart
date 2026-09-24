part of 'client_detail_cubit.dart';

enum ClientDetailStatus { loading, ready, error }

bool _isClosedStatus(JobStatus status) =>
    status == JobStatus.quoteRejected ||
    status == JobStatus.clientDeclined ||
    status == JobStatus.sentToClient;

enum ClientHistoryTab { requests, equipment, certificates }

class ClientDetailState extends Equatable {
  final ClientDetailStatus status;
  final Client? client;

  /// This client's requests, in whatever order [GetRequests] provides
  /// (newest first).
  final List<InspectionRequest> requests;
  final ClientHistoryTab tab;
  final ClientsFailureCode? failure;

  const ClientDetailState({
    this.status = ClientDetailStatus.loading,
    this.client,
    this.requests = const [],
    this.tab = ClientHistoryTab.requests,
    this.failure,
  });

  int get openJobsCount => requests.where((r) => !_isClosedStatus(r.status)).length;

  ClientDetailState copyWith({
    ClientDetailStatus? status,
    Client? client,
    List<InspectionRequest>? requests,
    ClientHistoryTab? tab,
    ClientsFailureCode? failure,
  }) {
    return ClientDetailState(
      status: status ?? this.status,
      client: client ?? this.client,
      requests: requests ?? this.requests,
      tab: tab ?? this.tab,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, client, requests, tab, failure];
}
