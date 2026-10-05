import '../entities/certificate.dart';
import '../repositories/certificate_repository.dart';

/// Feature 06: a technical manager signs off a submitted certificate.
class ApproveCertificate {
  final CertificateRepository _repository;

  const ApproveCertificate(this._repository);

  Future<void> call(Certificate certificate) => _repository.approve(certificate);
}
