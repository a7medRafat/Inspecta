import 'package:equatable/equatable.dart';

import '../timesheet_pricing.dart';
import 'timesheet_activity.dart';
import 'timesheet_entry_status.dart';
import 'timesheet_expense.dart';

/// What an inspector logged for one job: how their time was spent and what
/// it cost them, the price worked out from that time, and where a
/// coordinator's review of it stands. One entry per job — the doc id is the
/// job's request id, same as a certificate.
class TimesheetEntry extends Equatable {
  final String requestId;
  final String inspectorId;

  /// Whole minutes per activity. Activities with nothing logged are left
  /// out, so two entries that read the same compare equal.
  final Map<TimesheetActivity, int> activities;

  /// The inspector's hourly rate when this was saved, in integer piastres.
  /// Kept on the entry so a later change of rate doesn't rewrite what was
  /// already logged; 0 when no rate was set (or the entry predates rates).
  final int hourlyRatePiastres;

  /// The price for the job, in integer piastres (BR-03.10): the net working
  /// time at [hourlyRatePiastres]. Calculated, never entered.
  final int pricePiastres;

  /// Costs such as transportation, in integer piastres per expense. Left
  /// out when nothing was spent, like [activities].
  final Map<TimesheetExpense, int> expenses;

  final TimesheetEntryStatus status;

  /// Why a coordinator returned it; only meaningful while [status] is
  /// [TimesheetEntryStatus.returned].
  final String? reviewNote;

  /// The coordinator who last approved or returned it.
  final String? reviewedBy;
  final String? reviewerName;
  final DateTime? reviewedAt;

  const TimesheetEntry({
    required this.requestId,
    required this.inspectorId,
    required this.activities,
    required this.pricePiastres,
    this.hourlyRatePiastres = 0,
    this.expenses = const {},
    this.status = TimesheetEntryStatus.pending,
    this.reviewNote,
    this.reviewedBy,
    this.reviewerName,
    this.reviewedAt,
  });

  /// A new entry whose price is worked out rather than given: the net
  /// working time of [activities] at [hourlyRatePiastres] an hour. This is
  /// how an inspector's save is built — the price is never an input.
  factory TimesheetEntry.priced({
    required String requestId,
    required String inspectorId,
    required Map<TimesheetActivity, int> activities,
    required Map<TimesheetExpense, int> expenses,
    required int hourlyRatePiastres,
  }) {
    return TimesheetEntry(
      requestId: requestId,
      inspectorId: inspectorId,
      activities: activities,
      expenses: expenses,
      hourlyRatePiastres: hourlyRatePiastres,
      pricePiastres: TimesheetPricing.priceFor(
        netMinutes: _netMinutesOf(activities),
        hourlyRatePiastres: hourlyRatePiastres,
      ),
    );
  }

  static int _netMinutesOf(Map<TimesheetActivity, int> activities) => activities.entries
      .where((entry) => entry.key.isPaid)
      .fold(0, (sum, entry) => sum + entry.value);

  int minutesOf(TimesheetActivity activity) => activities[activity] ?? 0;

  /// Everything logged, the unpaid break included.
  int get elapsedMinutes => activities.values.fold(0, (sum, minutes) => sum + minutes);

  int get unpaidBreakMinutes => minutesOf(TimesheetActivity.unpaidBreak);

  /// The time that counts as work: [elapsedMinutes] less the unpaid break.
  /// This is what the totals add up, and what the price is worked out from.
  int get minutes => _netMinutesOf(activities);

  bool get hasTime => elapsedMinutes > 0;

  bool get hasPrice => pricePiastres > 0;

  int expenseOf(TimesheetExpense expense) => expenses[expense] ?? 0;

  /// All the costs added up — what the inspector spent, as opposed to what
  /// they charge.
  int get expensesPiastres => expenses.values.fold(0, (sum, piastres) => sum + piastres);

  bool get hasExpenses => expensesPiastres > 0;

  /// The price and the costs together: what the entry comes to in money.
  int get totalPiastres => pricePiastres + expensesPiastres;

  bool get isPending => status == TimesheetEntryStatus.pending;

  bool get isApproved => status == TimesheetEntryStatus.approved;

  bool get isReturned => status == TimesheetEntryStatus.returned;

  /// An approved entry is locked, so the inspector can't change a price
  /// that's already been accepted.
  bool get isEditable => !isApproved;

  @override
  List<Object?> get props => [
    requestId,
    inspectorId,
    activities,
    hourlyRatePiastres,
    pricePiastres,
    expenses,
    status,
    reviewNote,
    reviewedBy,
    reviewerName,
    reviewedAt,
  ];
}
