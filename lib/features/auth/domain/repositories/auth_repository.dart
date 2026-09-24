import '../entities/user.dart';

/// Authentication contract. Methods throw [AuthFailure] on expected errors.
abstract interface class AuthRepository {
  Future<void> applySessionPolicy();

  Stream<AppUser?> watch();

  Future<AppUser?> getCurrentUser();

  Future<AppUser> signIn({
    required String email,
    required String password,
    required bool keepSignedIn,
  });

  Future<void> signOut();

  Future<void> sendPasswordReset({
    required String email,
    required String languageCode,
  });
}
