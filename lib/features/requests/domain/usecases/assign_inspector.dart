import '../repositories/requests_repository.dart';

/// Feature 04: assigns an inspector and a time slot to a job that's
/// ready to assign (BR-04.x).
class AssignInspector {
  final RequestsRepository _repository;

  const AssignInspector(this._repository);

  Future<void> call({
    required String requestId,
    required String inspectorId,
    required DateTime scheduledAt,
    String? note,
  }) => _repository.assignInspector(
    requestId: requestId,
    inspectorId: inspectorId,
    scheduledAt: scheduledAt,
    note: note,
  );
}
