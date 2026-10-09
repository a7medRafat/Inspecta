import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/timesheet_activity.dart';
import '../../domain/entities/timesheet_entry_status.dart';
import '../../domain/entities/timesheet_expense.dart';
import '../../domain/entities/timesheet_failure.dart';

extension TimesheetFailureMessage on TimesheetFailureCode {
  String message(AppLocalizations t) => switch (this) {
    TimesheetFailureCode.permissionDenied => t.timesheetPermissionDenied,
    TimesheetFailureCode.network => t.errorNetwork,
    TimesheetFailureCode.unknown => t.errorUnknown,
  };
}

extension TimesheetActivityLabel on TimesheetActivity {
  String label(AppLocalizations t) => switch (this) {
    TimesheetActivity.inspection => t.timesheetActivityInspection,
    TimesheetActivity.reportPreparation => t.timesheetActivityReport,
    TimesheetActivity.waiting => t.timesheetActivityWaiting,
    TimesheetActivity.unpaidBreak => t.timesheetActivityUnpaidBreak,
  };
}

extension TimesheetExpenseLabel on TimesheetExpense {
  String label(AppLocalizations t) => switch (this) {
    TimesheetExpense.internalTransport => t.timesheetExpenseInternalTransport,
    TimesheetExpense.externalTransport => t.timesheetExpenseExternalTransport,
  };
}

extension TimesheetEntryStatusStyle on TimesheetEntryStatus {
  String label(AppLocalizations t) => switch (this) {
    TimesheetEntryStatus.pending => t.timesheetStatusPending,
    TimesheetEntryStatus.approved => t.timesheetStatusApproved,
    TimesheetEntryStatus.returned => t.timesheetStatusReturned,
  };

  Color get chipBackground => switch (this) {
    TimesheetEntryStatus.pending => AppColours.chipAmberBackground,
    TimesheetEntryStatus.approved => AppColours.chipGreenBackground,
    TimesheetEntryStatus.returned => AppColours.chipRedBackground,
  };

  Color get chipText => switch (this) {
    TimesheetEntryStatus.pending => AppColours.chipAmberText,
    TimesheetEntryStatus.approved => AppColours.chipGreenText,
    TimesheetEntryStatus.returned => AppColours.chipRedText,
  };
}

/// Small rounded badge for where an entry stands with its reviewer;
/// [label] replaces the plain status name (e.g. "Approved by Mona").
class TimesheetEntryStatusChip extends StatelessWidget {
  final TimesheetEntryStatus status;
  final String? label;

  const TimesheetEntryStatusChip({super.key, required this.status, this.label});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: status.chipBackground, borderRadius: BorderRadius.circular(999)),
      child: Text(label ?? status.label(t), style: AppTextStyles.badge.copyWith(color: status.chipText)),
    );
  }
}

/// "2h 30m", "2h" or "45m"; an em dash when nothing was logged.
String formatMinutes(AppLocalizations t, int minutes) {
  if (minutes <= 0) return '—';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours == 0) return t.durationMinutes(rest);
  if (rest == 0) return t.durationHours(hours);
  return t.durationHoursMinutes(hours, rest);
}
