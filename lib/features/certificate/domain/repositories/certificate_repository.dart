import '../entities/certificate.dart';

/// Methods emit / throw [CertificateFailure] on expected errors.
abstract interface class CertificateRepository {
  /// The one certificate for this job, or `null` until the inspector's
  /// first save creates it.
  Stream<Certificate?> watchCertificate(String requestId);

  /// Autosaves the current state of the form.
  Future<void> saveDraft(Certificate certificate);

  /// Saves the final state and moves the job to
  /// [JobStatus.certificateSubmitted] — the inspector's part is done.
  Future<void> submit(Certificate certificate);
}
