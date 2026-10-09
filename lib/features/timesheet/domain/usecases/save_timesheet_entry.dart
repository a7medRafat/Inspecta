import '../entities/timesheet_entry.dart';
import '../repositories/timesheet_repository.dart';

class SaveTimesheetEntry {
  final TimesheetRepository _repository;

  const SaveTimesheetEntry(this._repository);

  Future<void> call(TimesheetEntry entry) => _repository.saveEntry(entry);
}
