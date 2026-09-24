/// Each user has exactly one role in v1 (BR-01.1).
enum UserRole {
  supervisor('supervisor'),
  coordinator('coordinator'),
  inspector('inspector'),
  technicalManager('technical_manager'),
  admin('admin');

  /// Value stored in the `role` field of a `users/{uid}` document.
  final String value;

  const UserRole(this.value);

  static UserRole? fromValue(Object? value) {
    for (final role in values) {
      if (role.value == value) return role;
    }
    return null;
  }
}
