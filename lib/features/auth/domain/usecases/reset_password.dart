import '../repositories/auth_repository.dart';

class ResetPassword {
  final AuthRepository _repository;

  const ResetPassword(this._repository);

  Future<void> call({required String email, required String languageCode}) {
    return _repository.sendPasswordReset(
      email: email.trim(),
      languageCode: languageCode,
    );
  }
}
