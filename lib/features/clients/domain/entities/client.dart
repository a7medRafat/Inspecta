import 'package:equatable/equatable.dart';

import 'client_contact.dart';
import 'client_equipment_item.dart';

/// A client company. Requests and quotations reference one by id via
/// their own `clientId` field rather than embedding it — see
/// [InspectionRequest.isNewClient] for the unmatched-sender case this
/// leaves for the Clients screen to resolve.
class Client extends Equatable {
  final String id;
  final String companyName;
  final String location;
  final List<ClientContact> contacts;

  /// Where generated certificates go — often not a named contact (a
  /// shared inbox, a different person than who requests jobs).
  final String? certificatesEmail;
  final List<ClientEquipmentItem> equipment;
  final DateTime createdAt;

  const Client({
    required this.id,
    required this.companyName,
    required this.location,
    required this.createdAt,
    this.contacts = const [],
    this.certificatesEmail,
    this.equipment = const [],
  });

  ClientContact? get mainContact {
    if (contacts.isEmpty) return null;
    return contacts.firstWhere((c) => c.isMain, orElse: () => contacts.first);
  }

  int get equipmentCount => equipment.length;

  int dueSoonCount({DateTime? now}) =>
      equipment.where((e) => e.isDueSoon(now: now)).length;

  @override
  List<Object?> get props => [
    id,
    companyName,
    location,
    contacts,
    certificatesEmail,
    equipment,
    createdAt,
  ];
}
