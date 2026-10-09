import '../repositories/timesheet_repository.dart';

class SaveHourlyRate {
  final TimesheetRepository _repository;

  const SaveHourlyRate(this._repository);

  Future<void> call(String inspectorId, int hourlyRatePiastres) =>
      _repository.saveHourlyRate(inspectorId, hourlyRatePiastres);
}
