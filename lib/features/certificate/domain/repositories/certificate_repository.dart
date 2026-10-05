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

  /// Feature 06: the technical manager approves and signs — saves the
  /// review fields and moves the job to [JobStatus.sentToClient]. The
  /// client email itself is not sent from the app.
  Future<void> approve(Certificate certificate);

  /// Feature 06: sends the certificate back to its inspector with a
  /// reason, moving the job to [JobStatus.certificateReturned].
  Future<void> sendBack(Certificate certificate, {required String note});
}
