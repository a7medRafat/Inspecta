import '../entities/certificate.dart';
import '../repositories/certificate_repository.dart';

/// Feature 06: a technical manager sends a certificate back to its
/// inspector with a reason.
class ReturnCertificate {
  final CertificateRepository _repository;

  const ReturnCertificate(this._repository);

  Future<void> call(Certificate certificate, {required String note}) =>
      _repository.sendBack(certificate, note: note);
}
