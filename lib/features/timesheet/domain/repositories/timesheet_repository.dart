import '../entities/timesheet_entry.dart';

/// Methods emit / throw [TimesheetFailure] on expected errors.
abstract interface class TimesheetRepository {
  /// Every entry this inspector has logged, across all their jobs.
  Stream<List<TimesheetEntry>> watchEntries(String inspectorId);

  /// Creates or replaces the entry for [TimesheetEntry.requestId], and
  /// (re)submits it for a coordinator's review: whatever its status was,
  /// it's pending afterwards.
  Future<void> saveEntry(TimesheetEntry entry);

  /// The inspector's hourly rate in piastres — 0 until they set one. Their
  /// prices are calculated from it.
  Stream<int> watchHourlyRate(String inspectorId);

  /// Sets the inspector's hourly rate. It applies to entries saved from now
  /// on; entries already logged keep the rate they were saved with.
  Future<void> saveHourlyRate(String inspectorId, int hourlyRatePiastres);

  /// A coordinator's view: every inspector's entries.
  Stream<List<TimesheetEntry>> watchAllEntries();

  /// A coordinator accepts a pending entry, locking it.
  Future<void> approve({
    required String requestId,
    required String reviewerId,
    required String reviewerName,
  });

  /// A coordinator sends a pending entry back to its inspector with a
  /// reason.
  Future<void> sendBack({
    required String requestId,
    required String reviewerId,
    required String reviewerName,
    required String note,
  });
}
