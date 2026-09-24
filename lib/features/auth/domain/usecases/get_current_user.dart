import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository _repository;

  const GetCurrentUser(this._repository);

  Future<AppUser?> call() => _repository.getCurrentUser();

  /// See [AuthRepository.watch].
  Stream<AppUser?> watch() => _repository.watch();

  /// See [AuthRepository.applySessionPolicy].
  Future<void> applySessionPolicy() => _repository.applySessionPolicy();
}
