import '../../../../core/enums/job_status.dart';
import '../repositories/requests_repository.dart';

/// Feature 05: the inspector begins the job on site — [JobStatus.taskAccepted]
/// moves to [JobStatus.inProgress].
class StartInspection {
  final RequestsRepository _repository;

  const StartInspection(this._repository);

  Future<void> call(String requestId) => _repository.updateStatus(requestId, JobStatus.inProgress);
}
