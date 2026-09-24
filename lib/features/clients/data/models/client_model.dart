import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/client.dart';
import 'client_contact_model.dart';
import 'client_equipment_item_model.dart';

/// A `clients/{id}` Firestore document.
class ClientModel {
  final String id;
  final String companyName;
  final String location;
  final List<ClientContactModel> contacts;
  final String? certificatesEmail;
  final List<ClientEquipmentItemModel> equipment;
  final DateTime createdAt;

  const ClientModel({
    required this.id,
    required this.companyName,
    required this.location,
    required this.createdAt,
    this.contacts = const [],
    this.certificatesEmail,
    this.equipment = const [],
  });

  factory ClientModel.fromJson(String id, Map<String, dynamic> json) {
    return ClientModel(
      id: id,
      companyName: json['companyName'] as String? ?? '',
      location: json['location'] as String? ?? '',
      contacts: (json['contacts'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ClientContactModel.fromJson)
          .toList(),
      certificatesEmail: json['certificatesEmail'] as String?,
      equipment: (json['equipment'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ClientEquipmentItemModel.fromJson)
          .toList(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Client toEntity() => Client(
    id: id,
    companyName: companyName,
    location: location,
    contacts: contacts.map((c) => c.toEntity()).toList(),
    certificatesEmail: certificatesEmail,
    equipment: equipment.map((e) => e.toEntity()).toList(),
    createdAt: createdAt,
  );
}
