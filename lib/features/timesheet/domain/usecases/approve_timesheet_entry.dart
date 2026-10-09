import '../repositories/timesheet_repository.dart';

class ApproveTimesheetEntry {
  final TimesheetRepository _repository;

  const ApproveTimesheetEntry(this._repository);

  Future<void> call({
    required String requestId,
    required String reviewerId,
    required String reviewerName,
  }) => _repository.approve(requestId: requestId, reviewerId: reviewerId, reviewerName: reviewerName);
}
