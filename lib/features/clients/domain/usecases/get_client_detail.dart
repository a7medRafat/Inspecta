import '../entities/client.dart';
import '../repositories/clients_repository.dart';

/// Fetches a single client by id (e.g. opening one from the clients
/// list, or from an unmatched-sender's "Match" action).
class GetClientDetail {
  final ClientsRepository _repository;

  const GetClientDetail(this._repository);

  Future<Client?> call(String id) => _repository.getById(id);
}
