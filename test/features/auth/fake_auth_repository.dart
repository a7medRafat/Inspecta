import 'dart:async';

import 'package:inspecta/features/auth/domain/entities/auth_failure.dart';
import 'package:inspecta/features/auth/domain/entities/user.dart';
import 'package:inspecta/features/auth/domain/entities/user_role.dart';
import 'package:inspecta/features/auth/domain/repositories/auth_repository.dart';

const inspector = AppUser(
  id: 'u1',
  name: 'Karim Adel',
  email: 'karim.adel@company.com',
  role: UserRole.inspector,
  qualifications: ['Lifts', 'Cranes'],
);

class FakeAuthRepository implements AuthRepository {
  final session = StreamController<AppUser?>.broadcast();

  AuthFailure? signInFailure;
  AuthFailure? resetFailure;
  final signInCalls = <({String email, String password, bool keep})>[];
  final resetCalls = <String>[];
  int signOutCalls = 0;

  @override
  Future<void> applySessionPolicy() async {}

  @override
  Stream<AppUser?> watch() => session.stream;

  @override
  Future<AppUser?> getCurrentUser() async => null;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
    required bool keepSignedIn,
  }) async {
    signInCalls.add((email: email, password: password, keep: keepSignedIn));
    if (signInFailure != null) throw signInFailure!;
    session.add(inspector);
    return inspector;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    session.add(null);
  }

  @override
  Future<void> sendPasswordReset({
    required String email,
    required String languageCode,
  }) async {
    resetCalls.add(email);
    if (resetFailure != null) throw resetFailure!;
  }
}
