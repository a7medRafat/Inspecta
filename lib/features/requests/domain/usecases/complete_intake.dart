import '../entities/request_item.dart';
import '../repositories/requests_repository.dart';

/// Fills in a request's equipment and location so it can be quoted
/// (BR-02.5) — the only in-app way to complete an intake-only request.
class CompleteIntake {
  final RequestsRepository _repository;

  const CompleteIntake(this._repository);

  Future<void> call({
    required String requestId,
    required String location,
    required List<RequestItem> items,
  }) => _repository.completeIntake(requestId: requestId, location: location, items: items);
}
