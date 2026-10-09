import '../repositories/timesheet_repository.dart';

class ReturnTimesheetEntry {
  final TimesheetRepository _repository;

  const ReturnTimesheetEntry(this._repository);

  Future<void> call({
    required String requestId,
    required String reviewerId,
    required String reviewerName,
    required String note,
  }) => _repository.sendBack(
    requestId: requestId,
    reviewerId: reviewerId,
    reviewerName: reviewerName,
    note: note,
  );
}
