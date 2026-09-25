import '../../../auth/domain/entities/user.dart';
import '../repositories/coordinator_repository.dart';

class GetInspectors {
  final CoordinatorRepository _repository;

  const GetInspectors(this._repository);

  Stream<List<AppUser>> call() => _repository.watchInspectors();
}
