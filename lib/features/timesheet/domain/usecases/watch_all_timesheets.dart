import '../entities/timesheet_entry.dart';
import '../repositories/timesheet_repository.dart';

class WatchAllTimesheets {
  final TimesheetRepository _repository;

  const WatchAllTimesheets(this._repository);

  Stream<List<TimesheetEntry>> call() => _repository.watchAllEntries();
}
