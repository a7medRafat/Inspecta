import 'package:equatable/equatable.dart';

import '../certificate_template.dart';
import 'certificate_result.dart';
import 'checklist_answer.dart';

/// A `certificates/{requestId}` document (Feature 05): one per job, owned
/// by the inspector it's assigned to. Autosaved as the inspector fills it
/// in, locked once the job's [JobStatus] moves past `inProgress`.
class Certificate extends Equatable {
  final String requestId;
  final String inspectorId;
  final String templateId;
  final Map<String, ChecklistAnswer> checklistAnswers;
  final Map<String, String> defectNotes;
  final double? testLoadKg;
  final int? durationMinutes;
  final CertificateResult? finalResult;

  /// Set by a technical manager sending a certificate back for changes
  /// (not built yet — there's no reviewer UI in the app today, so this
  /// stays null in practice; the Certificates list already knows how to
  /// display it once one exists).
  final String? reviewNote;

  /// Server-stamped the moment the inspector submits (or resubmits) —
  /// never set by the generic autosave. Powers the Certificates list's
  /// "Submitted N ago".
  final DateTime? submittedAt;

  const Certificate({
    required this.requestId,
    required this.inspectorId,
    this.templateId = CertificateTemplate.id,
    this.checklistAnswers = const {},
    this.defectNotes = const {},
    this.testLoadKg,
    this.durationMinutes,
    this.finalResult,
    this.reviewNote,
    this.submittedAt,
  });

  ChecklistAnswer answerFor(String itemId) =>
      checklistAnswers[itemId] ?? ChecklistAnswer.unanswered;

  String? defectNoteFor(String itemId) => defectNotes[itemId];

  int get answeredCount =>
      CertificateTemplate.items.where((item) => answerFor(item.id) != ChecklistAnswer.unanswered).length;

  /// Every item answered, and every "fail" has a defect note (BR-05's
  /// checklist can't be submitted with an unexplained failure).
  bool get isChecklistComplete => CertificateTemplate.items.every((item) {
    final answer = answerFor(item.id);
    if (answer == ChecklistAnswer.unanswered) return false;
    if (answer == ChecklistAnswer.fail) return (defectNoteFor(item.id) ?? '').trim().isNotEmpty;
    return true;
  });

  bool get isLoadTestComplete => testLoadKg != null && durationMinutes != null;

  bool get isFinalResultComplete => finalResult != null;

  /// Photos are optional (Feature 05, scope-cut #2 — no upload yet), so
  /// they never block submission.
  bool get isReadyToSubmit => isChecklistComplete && isLoadTestComplete && isFinalResultComplete;

  Certificate copyWith({
    Map<String, ChecklistAnswer>? checklistAnswers,
    Map<String, String>? defectNotes,
    double? testLoadKg,
    bool clearTestLoadKg = false,
    int? durationMinutes,
    bool clearDurationMinutes = false,
    CertificateResult? finalResult,
  }) {
    return Certificate(
      requestId: requestId,
      inspectorId: inspectorId,
      templateId: templateId,
      checklistAnswers: checklistAnswers ?? this.checklistAnswers,
      defectNotes: defectNotes ?? this.defectNotes,
      testLoadKg: clearTestLoadKg ? null : (testLoadKg ?? this.testLoadKg),
      durationMinutes: clearDurationMinutes ? null : (durationMinutes ?? this.durationMinutes),
      finalResult: finalResult ?? this.finalResult,
      // Not settable here — reviewNote is a technical manager's, and
      // submittedAt is server-stamped on submit; every field this
      // copyWith touches is the inspector's own draft data.
      reviewNote: reviewNote,
      submittedAt: submittedAt,
    );
  }

  @override
  List<Object?> get props => [
    requestId,
    inspectorId,
    templateId,
    checklistAnswers,
    defectNotes,
    testLoadKg,
    durationMinutes,
    finalResult,
    reviewNote,
    submittedAt,
  ];
}
