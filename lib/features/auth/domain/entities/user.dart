import 'package:equatable/equatable.dart';

import 'user_role.dart';

/// An internal staff member. Named `AppUser` so it doesn't clash with
/// Firebase Auth's `User`.
class AppUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;

  /// Equipment categories an inspector may inspect (e.g. Lifts, Cranes).
  final List<String> qualifications;

  /// Stored signature image, for technical managers.
  final String? signatureImageId;
  final bool active;
  final DateTime? lastLogin;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.qualifications = const [],
    this.signatureImageId,
    this.active = true,
    this.lastLogin,
  });

  /// Up to two initials for an avatar ("Karim Adel" -> "KA").
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return letters.isEmpty ? '?' : letters;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    role,
    qualifications,
    signatureImageId,
    active,
    lastLogin,
  ];
}
