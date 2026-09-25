import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/qualification.dart';

class QualificationModel {
  final String name;
  final DateTime? validUntil;

  const QualificationModel({required this.name, this.validUntil});

  /// Accepts either the current `{name, validUntil}` map shape, or a bare
  /// string (legacy data written before Feature 04 tracked expiry).
  factory QualificationModel.fromJson(Object? json) {
    if (json is String) return QualificationModel(name: json);
    final map = json as Map<String, dynamic>;
    return QualificationModel(
      name: map['name'] as String? ?? '',
      validUntil: (map['validUntil'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'validUntil': validUntil == null ? null : Timestamp.fromDate(validUntil!),
  };

  Qualification toEntity() => Qualification(name: name, validUntil: validUntil);
}
