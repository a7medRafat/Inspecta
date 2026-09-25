import '../entities/certificate.dart';
import '../repositories/certificate_repository.dart';

class SaveCertificateDraft {
  final CertificateRepository _repository;

  const SaveCertificateDraft(this._repository);

  Future<void> call(Certificate certificate) => _repository.saveDraft(certificate);
}
