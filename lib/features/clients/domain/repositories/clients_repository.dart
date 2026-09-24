import '../entities/client.dart';
import '../entities/client_contact.dart';

/// Methods emit / throw [ClientsFailure] on expected errors.
abstract interface class ClientsRepository {
  /// Every client, alphabetical by company name.
  Stream<List<Client>> watchClients();

  /// A single client, or `null` if it doesn't exist.
  Future<Client?> getById(String id);

  /// Creates a client with one starting contact (marked main). Returns
  /// the new client's id.
  Future<String> createClient({
    required String companyName,
    required String location,
    required ClientContact mainContact,
  });

  Future<void> addContact(String clientId, ClientContact contact);

  Future<void> setCertificatesEmail(String clientId, String email);
}
