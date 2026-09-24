import '../entities/client_contact.dart';
import '../repositories/clients_repository.dart';

class CreateClient {
  final ClientsRepository _repository;

  const CreateClient(this._repository);

  Future<String> call({
    required String companyName,
    required String location,
    required ClientContact mainContact,
  }) => _repository.createClient(
    companyName: companyName,
    location: location,
    mainContact: mainContact,
  );
}
