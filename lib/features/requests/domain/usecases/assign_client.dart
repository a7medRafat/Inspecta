import '../repositories/requests_repository.dart';

/// BR-02.4: matches an unmatched sender to a known client.
class AssignClient {
  final RequestsRepository _repository;

  const AssignClient(this._repository);

  Future<void> call(String requestId, String clientId) =>
      _repository.assignClient(requestId, clientId);
}
