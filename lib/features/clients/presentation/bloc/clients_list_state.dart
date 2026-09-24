part of 'clients_list_cubit.dart';

enum ClientsListStatus { loading, ready, error }

enum ClientsFilter { all, openJobs, dueSoon }

class ClientsListState extends Equatable {
  final ClientsListStatus status;
  final List<Client> clients;
  final List<InspectionRequest> requests;
  final ClientsFilter filter;
  final String query;
  final ClientsFailureCode? failure;

  const ClientsListState({
    this.status = ClientsListStatus.loading,
    this.clients = const [],
    this.requests = const [],
    this.filter = ClientsFilter.all,
    this.query = '',
    this.failure,
  });

  static bool _isClosed(JobStatus status) =>
      status == JobStatus.quoteRejected ||
      status == JobStatus.clientDeclined ||
      status == JobStatus.sentToClient;

  int openJobsCountFor(String clientId) =>
      requests.where((r) => r.clientId == clientId && !_isClosed(r.status)).length;

  /// Requests from a sender the app couldn't match to a known client
  /// (BR-02.4) — each needs a "Match" action on the list screen.
  List<InspectionRequest> get unmatched =>
      requests.where((r) => r.clientId == null).toList();

  /// [clients] filtered to [filter], then to [query] (company name or any
  /// contact's name/email), alphabetical (the repository already sorts;
  /// filtering preserves that order).
  List<Client> get visible {
    final needle = query.trim().toLowerCase();
    return clients.where((c) {
      if (filter == ClientsFilter.openJobs && openJobsCountFor(c.id) == 0) {
        return false;
      }
      if (filter == ClientsFilter.dueSoon && c.dueSoonCount() == 0) {
        return false;
      }
      if (needle.isEmpty) return true;
      if (c.companyName.toLowerCase().contains(needle)) return true;
      return c.contacts.any(
        (contact) =>
            contact.name.toLowerCase().contains(needle) ||
            (contact.email?.toLowerCase().contains(needle) ?? false),
      );
    }).toList();
  }

  ClientsListState copyWith({
    ClientsListStatus? status,
    List<Client>? clients,
    List<InspectionRequest>? requests,
    ClientsFilter? filter,
    String? query,
    ClientsFailureCode? failure,
    bool clearFailure = false,
  }) {
    return ClientsListState(
      status: status ?? this.status,
      clients: clients ?? this.clients,
      requests: requests ?? this.requests,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, clients, requests, filter, query, failure];
}
