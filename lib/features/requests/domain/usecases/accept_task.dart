import '../../../../core/enums/job_status.dart';
import '../repositories/requests_repository.dart';

/// Feature 05: the assigned inspector accepts a job — [JobStatus.assigned]
/// moves to [JobStatus.taskAccepted].
class AcceptTask {
  final RequestsRepository _repository;

  const AcceptTask(this._repository);

  Future<void> call(String requestId) => _repository.updateStatus(requestId, JobStatus.taskAccepted);
}
