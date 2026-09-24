import '../repositories/clients_repository.dart';

class SetCertificatesEmail {
  final ClientsRepository _repository;

  const SetCertificatesEmail(this._repository);

  Future<void> call(String clientId, String email) =>
      _repository.setCertificatesEmail(clientId, email);
}
