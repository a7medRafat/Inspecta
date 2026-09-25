import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';
import 'qualification_model.dart';

/// A `users/{uid}` Firestore document.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final List<QualificationModel> qualifications;
  final String? signatureImageId;
  final bool active;
  final DateTime? lastLogin;
  final DateTime? onLeaveUntil;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    this.qualifications = const [],
    this.signatureImageId,
    this.active = false,
    this.lastLogin,
    this.onLeaveUntil,
  });

  factory UserModel.fromJson(String id, Map<String, dynamic> json) {
    return UserModel(
      id: id,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      qualifications: (json['qualifications'] as List<dynamic>? ?? const [])
          .where((q) => q is String || q is Map)
          .map(QualificationModel.fromJson)
          .toList(),
      signatureImageId: json['signatureImageId'] as String?,
      // A missing `active` field means "not activated", not "active".
      active: json['active'] as bool? ?? false,
      lastLogin: (json['lastLogin'] as Timestamp?)?.toDate(),
      onLeaveUntil: (json['onLeaveUntil'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'qualifications': qualifications.map((q) => q.toJson()).toList(),
    'signatureImageId': signatureImageId,
    'active': active,
    'lastLogin': lastLogin == null ? null : Timestamp.fromDate(lastLogin!),
    'onLeaveUntil': onLeaveUntil == null ? null : Timestamp.fromDate(onLeaveUntil!),
  };

  /// Returns `null` when [role] isn't one of [UserRole]'s values, since a
  /// user without a valid role has no home screen.
  AppUser? toEntity() {
    final parsedRole = UserRole.fromValue(role);
    if (parsedRole == null) return null;
    return AppUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: parsedRole,
      qualifications: qualifications.map((q) => q.toEntity()).toList(),
      signatureImageId: signatureImageId,
      active: active,
      lastLogin: lastLogin,
      onLeaveUntil: onLeaveUntil,
    );
  }
}
