import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/client.dart';
import '../../domain/entities/client_contact.dart';
import '../../domain/entities/clients_failure.dart';
import '../../domain/repositories/clients_repository.dart';
import '../datasources/clients_remote_datasource.dart';
import '../models/client_contact_model.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  final ClientsRemoteDataSource _remote;

  const ClientsRepositoryImpl(this._remote);

  @override
  Stream<List<Client>> watchClients() {
    return _remote
        .watchClients()
        .map((models) => models.map((m) => m.toEntity()).toList())
        .handleError((Object error) {
          throw _mapError(error);
        });
  }

  @override
  Future<Client?> getById(String id) async {
    try {
      final model = await _remote.getById(id);
      return model?.toEntity();
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<String> createClient({
    required String companyName,
    required String location,
    required ClientContact mainContact,
  }) async {
    try {
      return await _remote.createClient(
        companyName: companyName,
        location: location,
        mainContact: ClientContactModel.fromEntity(
          ClientContact(
            name: mainContact.name,
            role: mainContact.role,
            email: mainContact.email,
            phone: mainContact.phone,
            isMain: true,
          ),
        ),
      );
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> addContact(String clientId, ClientContact contact) async {
    try {
      await _remote.addContact(clientId, ClientContactModel.fromEntity(contact));
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> setCertificatesEmail(String clientId, String email) async {
    try {
      await _remote.setCertificatesEmail(clientId, email);
    } catch (e) {
      throw _mapError(e);
    }
  }

  ClientsFailure _mapError(Object error) {
    if (error is ClientsFailure) return error;
    if (error is FirebaseException) {
      return ClientsFailure(switch (error.code) {
        'permission-denied' => ClientsFailureCode.permissionDenied,
        'unavailable' => ClientsFailureCode.network,
        _ => ClientsFailureCode.unknown,
      });
    }
    debugPrint('Unexpected clients error: $error');
    return const ClientsFailure(ClientsFailureCode.unknown);
  }
}
