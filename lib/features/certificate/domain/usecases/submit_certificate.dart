import '../entities/certificate.dart';
import '../repositories/certificate_repository.dart';

class SubmitCertificate {
  final CertificateRepository _repository;

  const SubmitCertificate(this._repository);

  Future<void> call(Certificate certificate) => _repository.submit(certificate);
}
