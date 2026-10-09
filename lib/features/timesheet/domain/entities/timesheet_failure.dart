import '../../../../core/error/failure.dart';

enum TimesheetFailureCode { permissionDenied, network, unknown }

class TimesheetFailure extends Failure {
  final TimesheetFailureCode code;

  const TimesheetFailure(this.code);

  @override
  String toString() => 'TimesheetFailure(${code.name})';
}
