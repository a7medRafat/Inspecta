import '../entities/certificate.dart';
import '../repositories/certificate_repository.dart';

class WatchCertificate {
  final CertificateRepository _repository;

  const WatchCertificate(this._repository);

  Stream<Certificate?> call(String requestId) => _repository.watchCertificate(requestId);
}
