import '../entities/inspection_request.dart';
import '../repositories/requests_repository.dart';

/// Feature 05: every job ever assigned to one inspector.
class GetMyTasks {
  final RequestsRepository _repository;

  const GetMyTasks(this._repository);

  Stream<List<InspectionRequest>> call(String inspectorId) =>
      _repository.watchAssignedRequests(inspectorId);
}
