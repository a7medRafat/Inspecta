import '../../domain/entities/client_contact.dart';

class ClientContactModel {
  final String name;
  final String? role;
  final String? email;
  final String? phone;
  final bool isMain;

  const ClientContactModel({
    required this.name,
    this.role,
    this.email,
    this.phone,
    this.isMain = false,
  });

  factory ClientContactModel.fromJson(Map<String, dynamic> json) {
    return ClientContactModel(
      name: json['name'] as String? ?? '',
      role: json['role'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isMain: json['isMain'] as bool? ?? false,
    );
  }

  factory ClientContactModel.fromEntity(ClientContact contact) => ClientContactModel(
    name: contact.name,
    role: contact.role,
    email: contact.email,
    phone: contact.phone,
    isMain: contact.isMain,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'role': role,
    'email': email,
    'phone': phone,
    'isMain': isMain,
  };

  ClientContact toEntity() =>
      ClientContact(name: name, role: role, email: email, phone: phone, isMain: isMain);
}
