import '../../../../core/error/failure.dart';

enum RequestsFailureCode { permissionDenied, network, unknown }

class RequestsFailure extends Failure {
  final RequestsFailureCode code;

  const RequestsFailure(this.code);

  @override
  String toString() => 'RequestsFailure(${code.name})';
}
