import '../repositories/coordinator_repository.dart';

/// Marks (or clears, with `until: null`) an inspector's leave.
class MarkInspectorLeave {
  final CoordinatorRepository _repository;

  const MarkInspectorLeave(this._repository);

  Future<void> call(String inspectorId, DateTime? until) => _repository.markOnLeave(inspectorId, until);
}
