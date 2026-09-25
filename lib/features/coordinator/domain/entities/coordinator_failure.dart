import '../../../../core/error/failure.dart';

enum CoordinatorFailureCode { permissionDenied, network, unknown }

class CoordinatorFailure extends Failure {
  final CoordinatorFailureCode code;

  const CoordinatorFailure(this.code);

  @override
  String toString() => 'CoordinatorFailure(${code.name})';
}
