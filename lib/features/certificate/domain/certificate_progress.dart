import 'entities/certificate.dart';

/// The certificate's 5 sections, in mockup order — used for the "Step N
/// of 5" header on the form and the draft progress bar on the
/// Certificates list (Feature 05).
enum CertificateStep { equipment, checklist, loadTest, photos, finalResult }

/// Pure progress helpers shared by the certificate form (its "Step N of
/// 5" header) and the Certificates list (a draft's "40%" progress bar) —
/// works on a possibly-not-yet-created certificate, since a job's
/// certificate doc doesn't exist until the inspector's first save.
extension CertificateProgress on Certificate? {
  /// The first section that isn't done yet — equipment details (already
  /// filled in at intake) and photos (optional, unbuilt) never block, so
  /// this only ever lands on checklist, load test or final result.
  CertificateStep get currentStep {
    final c = this;
    if (c == null || !c.isChecklistComplete) return CertificateStep.checklist;
    if (!c.isLoadTestComplete) return CertificateStep.loadTest;
    return CertificateStep.finalResult;
  }

  int get currentStepNumber => CertificateStep.values.indexOf(currentStep) + 1;

  int get totalSteps => CertificateStep.values.length;

  int get percentComplete => (currentStepNumber / totalSteps * 100).round();
}
