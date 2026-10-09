import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/timesheet_activity.dart';
import '../../domain/entities/timesheet_entry.dart';
import '../../domain/entities/timesheet_entry_status.dart';
import '../../domain/entities/timesheet_expense.dart';

/// A `timesheets/{requestId}` Firestore document.
class TimesheetEntryModel {
  final String requestId;
  final String inspectorId;

  /// Minutes per activity; activities with nothing logged are left out.
  final Map<TimesheetActivity, int> activities;

  /// The hourly rate the price was calculated with.
  final int hourlyRatePiastres;
  final int pricePiastres;

  /// Piastres per expense; expenses with nothing spent are left out.
  final Map<TimesheetExpense, int> expenses;
  final TimesheetEntryStatus status;
  final String? reviewNote;
  final String? reviewedBy;
  final String? reviewerName;
  final DateTime? reviewedAt;

  const TimesheetEntryModel({
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

  factory TimesheetEntryModel.fromJson(String requestId, Map<String, dynamic> json) {
    final activities = <TimesheetActivity, int>{};
    for (final activity in TimesheetActivity.values) {
      final minutes = (json[activity.field] as num?)?.toInt() ?? 0;
      if (minutes > 0) activities[activity] = minutes;
    }

    // An entry saved before time was split by activity has just the one
    // total, which was the inspector's time on the job — inspection, as far
    // as anyone can tell.
    final legacyMinutes = (json['minutes'] as num?)?.toInt() ?? 0;
    if (activities.isEmpty && legacyMinutes > 0) {
      activities[TimesheetActivity.inspection] = legacyMinutes;
    }

    final expenses = <TimesheetExpense, int>{};
    for (final expense in TimesheetExpense.values) {
      final piastres = (json[expense.field] as num?)?.toInt() ?? 0;
      if (piastres > 0) expenses[expense] = piastres;
    }

    return TimesheetEntryModel(
      requestId: requestId,
      inspectorId: json['inspectorId'] as String? ?? '',
      activities: activities,
      pricePiastres: (json['pricePiastres'] as num?)?.toInt() ?? 0,
      hourlyRatePiastres: (json['hourlyRatePiastres'] as num?)?.toInt() ?? 0,
      expenses: expenses,
      status: TimesheetEntryStatus.fromValue(json['status']),
      reviewNote: json['reviewNote'] as String?,
      reviewedBy: json['reviewedBy'] as String?,
      reviewerName: json['reviewerName'] as String?,
      reviewedAt: (json['reviewedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory TimesheetEntryModel.fromEntity(TimesheetEntry entry) {
    return TimesheetEntryModel(
      requestId: entry.requestId,
      inspectorId: entry.inspectorId,
      activities: entry.activities,
      pricePiastres: entry.pricePiastres,
      hourlyRatePiastres: entry.hourlyRatePiastres,
      expenses: entry.expenses,
      status: entry.status,
      reviewNote: entry.reviewNote,
      reviewedBy: entry.reviewedBy,
      reviewerName: entry.reviewerName,
      reviewedAt: entry.reviewedAt,
    );
  }

  /// What an inspector writes. The doc id is [requestId], so it isn't
  /// repeated in the body, and the review fields are left out — they're a
  /// coordinator's to set, and a merge-write here must not touch them. A
  /// save always (re)submits for review, so the status is always pending.
  ///
  /// Every activity and expense is written, zeros included, so that
  /// clearing one in an edit overwrites the old value instead of leaving it
  /// behind. `minutes` is the net working time — the activities less the
  /// unpaid break — kept as its own field so firestore.rules can check it
  /// against them.
  Map<String, dynamic> toJson() {
    final entry = toEntity();
    return {
      'inspectorId': inspectorId,
      'minutes': entry.minutes,
      for (final activity in TimesheetActivity.values) activity.field: entry.minutesOf(activity),
      'hourlyRatePiastres': hourlyRatePiastres,
      'pricePiastres': pricePiastres,
      for (final expense in TimesheetExpense.values) expense.field: entry.expenseOf(expense),
      'status': TimesheetEntryStatus.pending.value,
    };
  }

  TimesheetEntry toEntity() => TimesheetEntry(
    requestId: requestId,
    inspectorId: inspectorId,
    activities: activities,
    pricePiastres: pricePiastres,
    hourlyRatePiastres: hourlyRatePiastres,
    expenses: expenses,
    status: status,
    reviewNote: reviewNote,
    reviewedBy: reviewedBy,
    reviewerName: reviewerName,
    reviewedAt: reviewedAt,
  );
}
