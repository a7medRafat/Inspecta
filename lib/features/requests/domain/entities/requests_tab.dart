import '../../../../core/enums/job_status.dart';

/// The inbox's two segments. "Negotiating" used to be a third tab here,
/// but it only duplicated the Quotations tab (which already tracks every
/// sent quote's follow-up) — once the first quote goes out, a request's
/// story continues there, not in this inbox.
enum RequestsTab { newTab, all }

extension RequestsTabX on RequestsTab {
  /// Whether a job's current [JobStatus] still needs a first quote —
  /// the only thing that keeps a request in the "New" segment.
  static bool isNew(JobStatus status) =>
      status == JobStatus.requestReceived || status == JobStatus.quoteDraft;
}
