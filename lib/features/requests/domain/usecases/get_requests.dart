import '../entities/inspection_request.dart';
import '../repositories/requests_repository.dart';

class GetRequests {
  final RequestsRepository _repository;

  const GetRequests(this._repository);

  Stream<List<InspectionRequest>> call() => _repository.watchRequests();
}
