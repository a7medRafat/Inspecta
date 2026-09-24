import '../../../../core/error/failure.dart';

enum ClientsFailureCode { permissionDenied, network, unknown }

class ClientsFailure extends Failure {
  final ClientsFailureCode code;

  const ClientsFailure(this.code);

  @override
  String toString() => 'ClientsFailure(${code.name})';
}
