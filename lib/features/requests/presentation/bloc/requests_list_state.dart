part of 'requests_list_cubit.dart';

enum RequestsListStatus { loading, ready, error }

class RequestsListState extends Equatable {
  final RequestsListStatus status;
  final List<InspectionRequest> requests;
  final RequestsTab tab;
  final String query;
  final RequestsFailureCode? failure;

  const RequestsListState({
    this.status = RequestsListStatus.loading,
    this.requests = const [],
    this.tab = RequestsTab.newTab,
    this.query = '',
    this.failure,
  });

  /// [requests] filtered to [tab] — "New" narrows to unquoted requests,
  /// "All" shows everything — then to [query] (client, equipment
  /// type/title, or request ID — acceptance criterion 4), newest first
  /// (the repository already sorts; filtering preserves that order).
  List<InspectionRequest> get visible {
    final needle = query.trim().toLowerCase();
    return requests.where((r) {
      if (tab == RequestsTab.newTab && !r.isNew) return false;
      if (needle.isEmpty) return true;
      return r.clientName.toLowerCase().contains(needle) ||
          r.equipmentTitle.toLowerCase().contains(needle) ||
          r.id.toLowerCase().contains(needle);
    }).toList();
  }

  /// Tab counts ignore [query], matching the mockup's "New · 2" badges.
  int countOf(RequestsTab t) =>
      t == RequestsTab.newTab ? requests.where((r) => r.isNew).length : requests.length;

  RequestsListState copyWith({
    RequestsListStatus? status,
    List<InspectionRequest>? requests,
    RequestsTab? tab,
    String? query,
    RequestsFailureCode? failure,
    bool clearFailure = false,
  }) {
    return RequestsListState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      tab: tab ?? this.tab,
      query: query ?? this.query,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, requests, tab, query, failure];
}
