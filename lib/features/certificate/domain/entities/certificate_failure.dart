import '../../../../core/error/failure.dart';

enum CertificateFailureCode { permissionDenied, network, unknown }

class CertificateFailure extends Failure {
  final CertificateFailureCode code;

  const CertificateFailure(this.code);

  @override
  String toString() => 'CertificateFailure(${code.name})';
}
