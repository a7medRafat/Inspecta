import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository _repository;

  const SignIn(this._repository);

  Future<AppUser> call({
    required String email,
    required String password,
    required bool keepSignedIn,
  }) {
    return _repository.signIn(
      email: email.trim(),
      password: password,
      keepSignedIn: keepSignedIn,
    );
  }
}
