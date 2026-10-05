import '../../auth/domain/entities/user.dart';
import '../../requests/domain/entities/inspection_request.dart';
import 'certificate_template.dart';
import 'entities/certificate.dart';

/// "Name & qualifications of person making this report", written from the
/// inspector's profile — called when a draft is first created and again on
/// submit, so a profile change between the two is picked up.
Certificate withPreparedBy(Certificate certificate, AppUser? inspector) {
  if (inspector == null) return certificate;
  return certificate
      .withText(CertText.preparedByName, inspector.name)
      .withText(CertText.preparedByQualifications, inspector.qualifications.map((q) => q.name).join(', '));
}

/// [base] with everything the job already tells us filled in — the item's
/// manufacturer / model / serial / capacity from the request, today as the
/// examination date, the suggested next examination and the usual test
/// type. Never overwrites something the inspector has already entered, and
/// stamps the current template id, so it also upgrades a draft started on
/// an older template.
Certificate seedCertificate(Certificate base, {required InspectionRequest request, AppUser? inspector, DateTime? now}) {
  var seeded = base.copyWith(templateId: CertificateTemplate.id);

  Certificate textIfEmpty(Certificate c, String key, String? value) =>
      c.text(key) == null && value != null && value.trim().isNotEmpty ? c.withText(key, value.trim()) : c;

  final item = request.items.isEmpty ? null : request.items.first;
  seeded = textIfEmpty(seeded, CertText.manufacturer, item?.manufacturer);
  seeded = textIfEmpty(seeded, CertText.modelYear, item?.model);
  seeded = textIfEmpty(seeded, CertText.serialNumber, item?.serialNumber);
  seeded = textIfEmpty(seeded, CertText.maxWorkingRate, item?.capacity);
  seeded = textIfEmpty(seeded, CertText.testType, CertificateTemplate.defaultTestType);

  if (seeded.dateOf(CertDate.examination) == null) {
    final today = now ?? DateTime.now();
    final examination = DateTime(today.year, today.month, today.day);
    seeded = seeded.withDate(CertDate.examination, examination);
    seeded = seeded.withDate(CertDate.nextExamination, CertificateTemplate.suggestedNextExamination(examination));
  }

  return withPreparedBy(seeded, inspector);
}
