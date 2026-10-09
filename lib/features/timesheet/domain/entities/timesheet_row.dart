import 'package:equatable/equatable.dart';

import '../../../../core/enums/job_status.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import 'timesheet_entry.dart';

/// A job on the timesheet together with whatever the inspector has logged
/// for it so far — [entry] is `null` until they do.
class TimesheetRow extends Equatable {
  final InspectionRequest request;
  final TimesheetEntry? entry;

  const TimesheetRow({required this.request, this.entry});

  /// Jobs the inspector has accepted — before that they haven't committed
  /// to the work, so there's nothing to log or price yet. A declined job
  /// is handed back to the coordinator and no longer shows up at all.
  static const _workedStatuses = {
    JobStatus.taskAccepted,
    JobStatus.inProgress,
    JobStatus.certificateSubmitted,
    JobStatus.certificateReturned,
    JobStatus.certificateApproved,
    JobStatus.sentToClient,
  };

  /// A scheduled job the inspector has accepted — the only kind that
  /// belongs on the timesheet.
  static bool isLoggable(InspectionRequest request) =>
      request.scheduledAt != null && _workedStatuses.contains(request.status);

  bool get isLogged => entry != null;

  /// Nothing logged yet, or logged but not yet approved.
  bool get isEditable => entry?.isEditable ?? true;

  @override
  List<Object?> get props => [request, entry];
}
