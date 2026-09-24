import '../entities/inspection_request.dart';
import '../repositories/requests_repository.dart';

/// Fetches a single request by id (e.g. opening one from the quotations
/// list, which only has the id).
class GetRequestDetail {
  final RequestsRepository _repository;

  const GetRequestDetail(this._repository);

  Future<InspectionRequest?> call(String id) => _repository.getById(id);
}
