part of 'inspectors_list_cubit.dart';

enum InspectorsListStatus { loading, ready, error }

class InspectorsListState extends Equatable {
  final InspectorsListStatus status;
  final List<AppUser> inspectors;
  final List<InspectionRequest> requests;
  final String query;

  /// A qualification name, or `null` for "All".
  final String? categoryFilter;
  final CoordinatorFailureCode? failure;

  const InspectorsListState({
    this.status = InspectorsListStatus.loading,
    this.inspectors = const [],
    this.requests = const [],
    this.query = '',
    this.categoryFilter,
    this.failure,
  });

  /// Distinct qualification names across the roster, for the filter
  /// chips — adapts to whatever's on file instead of a hardcoded list.
  List<String> get categories {
    final names = <String>{};
    for (final inspector in inspectors) {
      for (final q in inspector.qualifications) {
        if (q.name.isNotEmpty) names.add(q.name);
      }
    }
    return names.toList()..sort();
  }

  List<AppUser> get visible {
    final needle = query.trim().toLowerCase();
    final category = categoryFilter;
    return inspectors.where((inspector) {
      if (category != null && !inspector.qualifications.any((q) => q.name == category)) return false;
      if (needle.isEmpty) return true;
      return inspector.name.toLowerCase().contains(needle);
    }).toList();
  }

  InspectorDaySummary summaryFor(AppUser inspector) => InspectorDaySummary.compute(inspector, requests);

  int get freeTodayCount =>
      inspectors.where((i) => summaryFor(i).availability == InspectorAvailability.free).length;

  int get busyCount =>
      inspectors.where((i) => summaryFor(i).availability == InspectorAvailability.busy).length;

  int get onLeaveCount => inspectors.where((i) => i.isOnLeave()).length;

  InspectorsListState copyWith({
    InspectorsListStatus? status,
    List<AppUser>? inspectors,
    List<InspectionRequest>? requests,
    String? query,
    String? categoryFilter,
    bool clearCategory = false,
    CoordinatorFailureCode? failure,
    bool clearFailure = false,
  }) {
    return InspectorsListState(
      status: status ?? this.status,
      inspectors: inspectors ?? this.inspectors,
      requests: requests ?? this.requests,
      query: query ?? this.query,
      categoryFilter: clearCategory ? null : (categoryFilter ?? this.categoryFilter),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, inspectors, requests, query, categoryFilter, failure];
}
