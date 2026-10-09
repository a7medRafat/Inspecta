import '../entities/timesheet_entry.dart';
import '../repositories/timesheet_repository.dart';

class WatchTimesheet {
  final TimesheetRepository _repository;

  const WatchTimesheet(this._repository);

  Stream<List<TimesheetEntry>> call(String inspectorId) => _repository.watchEntries(inspectorId);
}
