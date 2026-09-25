import '../repositories/requests_repository.dart';

/// Feature 05: the assigned inspector turns a job down, handing it back
/// to the coordinator's "ready to assign" queue.
class DeclineTask {
  final RequestsRepository _repository;

  const DeclineTask(this._repository);

  Future<void> call({required String requestId, String? reason}) =>
      _repository.declineAssignment(requestId: requestId, reason: reason);
}
