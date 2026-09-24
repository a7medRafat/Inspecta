import '../entities/client_contact.dart';
import '../repositories/clients_repository.dart';

class AddContact {
  final ClientsRepository _repository;

  const AddContact(this._repository);

  Future<void> call(String clientId, ClientContact contact) =>
      _repository.addContact(clientId, contact);
}
