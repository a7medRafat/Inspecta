import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/client_equipment_item.dart';

class ClientEquipmentItemModel {
  final String id;
  final String type;
  final String? serialNumber;
  final String? location;
  final String? lastInspectionResult;
  final DateTime? nextDueDate;

  const ClientEquipmentItemModel({
    required this.id,
    required this.type,
    this.serialNumber,
    this.location,
    this.lastInspectionResult,
    this.nextDueDate,
  });

  factory ClientEquipmentItemModel.fromJson(Map<String, dynamic> json) {
    return ClientEquipmentItemModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      serialNumber: json['serialNumber'] as String?,
      location: json['location'] as String?,
      lastInspectionResult: json['lastInspectionResult'] as String?,
      nextDueDate: (json['nextDueDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'serialNumber': serialNumber,
    'location': location,
    'lastInspectionResult': lastInspectionResult,
    'nextDueDate': nextDueDate == null ? null : Timestamp.fromDate(nextDueDate!),
  };

  ClientEquipmentItem toEntity() => ClientEquipmentItem(
    id: id,
    type: type,
    serialNumber: serialNumber,
    location: location,
    lastInspectionResult: lastInspectionResult,
    nextDueDate: nextDueDate,
  );
}
