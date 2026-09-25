/// One row of the inspection checklist.
class CertificateChecklistItem {
  final String id;
  final String label;

  const CertificateChecklistItem({required this.id, required this.label});
}

/// Feature 05's single hardcoded checklist template — every job uses the
/// same checklist for now, regardless of equipment type. A real
/// per-category template system is a later concern.
class CertificateTemplate {
  CertificateTemplate._();

  static const String id = 'CI-LIFT-01';

  static const List<CertificateChecklistItem> items = [
    CertificateChecklistItem(id: 'suspension_ropes', label: 'Suspension ropes & terminations'),
    CertificateChecklistItem(id: 'brake_governor', label: 'Brake & overspeed governor'),
    CertificateChecklistItem(id: 'landing_door_interlocks', label: 'Landing door interlocks'),
    CertificateChecklistItem(id: 'emergency_alarm_lighting', label: 'Emergency alarm & lighting'),
  ];
}
