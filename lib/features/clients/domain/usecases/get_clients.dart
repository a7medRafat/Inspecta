import '../entities/client.dart';
import '../repositories/clients_repository.dart';

class GetClients {
  final ClientsRepository _repository;

  const GetClients(this._repository);

  Stream<List<Client>> call() => _repository.watchClients();
}
