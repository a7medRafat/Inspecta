part of 'timesheet_cubit.dart';

enum TimesheetStatus { loading, ready, error }

class TimesheetState extends Equatable {
  final TimesheetStatus status;
  final List<InspectionRequest> requests;
  final List<TimesheetEntry> entries;

  /// The inspector's hourly rate, in piastres; 0 until they set one. New
  /// entries are priced with it.
  final int hourlyRatePiastres;

  /// The first day of the month being shown.
  final DateTime selectedMonth;
  final TimesheetFailureCode? failure;

  TimesheetState({
    this.status = TimesheetStatus.loading,
    this.requests = const [],
    this.entries = const [],
    this.hourlyRatePiastres = 0,
    DateTime? selectedMonth,
    this.failure,
  }) : selectedMonth = _monthOf(selectedMonth ?? DateTime.now());

  static DateTime _monthOf(DateTime d) => DateTime(d.year, d.month);

  /// Accepted jobs scheduled in [selectedMonth], earliest first, each
  /// paired with its logged entry if there is one.
  List<TimesheetRow> get rows {
    final entryByRequest = {for (final entry in entries) entry.requestId: entry};
    final inMonth = requests.where(
      (r) => TimesheetRow.isLoggable(r) && _monthOf(r.scheduledAt!) == selectedMonth,
    );
    return [
      for (final request in inMonth) TimesheetRow(request: request, entry: entryByRequest[request.id]),
    ]..sort((a, b) => a.request.scheduledAt!.compareTo(b.request.scheduledAt!));
  }

  int get totalMinutes => rows.fold(0, (sum, row) => sum + (row.entry?.minutes ?? 0));

  /// What the inspector charged: their prices only, costs left out.
  int get totalPricePiastres => rows.fold(0, (sum, row) => sum + (row.entry?.pricePiastres ?? 0));

  /// What they spent on transportation and the like.
  int get totalExpensesPiastres => rows.fold(0, (sum, row) => sum + (row.entry?.expensesPiastres ?? 0));

  /// Prices and costs together — the month's money.
  int get totalPiastres => totalPricePiastres + totalExpensesPiastres;

  int get loggedCount => rows.where((row) => row.isLogged).length;

  TimesheetState copyWith({
    TimesheetStatus? status,
    List<InspectionRequest>? requests,
    List<TimesheetEntry>? entries,
    int? hourlyRatePiastres,
    DateTime? selectedMonth,
    TimesheetFailureCode? failure,
    bool clearFailure = false,
  }) {
    return TimesheetState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      entries: entries ?? this.entries,
      hourlyRatePiastres: hourlyRatePiastres ?? this.hourlyRatePiastres,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, requests, entries, hourlyRatePiastres, selectedMonth, failure];
}
