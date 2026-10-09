import '../repositories/timesheet_repository.dart';

class WatchHourlyRate {
  final TimesheetRepository _repository;

  const WatchHourlyRate(this._repository);

  Stream<int> call(String inspectorId) => _repository.watchHourlyRate(inspectorId);
}
