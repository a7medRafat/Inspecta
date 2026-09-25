import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/certificate_template.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/entities/certificate_result.dart';
import '../../domain/entities/checklist_answer.dart';

/// A `certificates/{requestId}` Firestore document.
class CertificateModel {
  final String requestId;
  final String inspectorId;
  final String templateId;
  final Map<String, ChecklistAnswer> checklistAnswers;
  final Map<String, String> defectNotes;
  final double? testLoadKg;
  final int? durationMinutes;
  final CertificateResult? finalResult;
  final String? reviewNote;
  final DateTime? submittedAt;

  const CertificateModel({
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

  factory CertificateModel.fromEntity(Certificate certificate) {
    return CertificateModel(
      requestId: certificate.requestId,
      inspectorId: certificate.inspectorId,
      templateId: certificate.templateId,
      checklistAnswers: certificate.checklistAnswers,
      defectNotes: certificate.defectNotes,
      testLoadKg: certificate.testLoadKg,
      durationMinutes: certificate.durationMinutes,
      finalResult: certificate.finalResult,
      reviewNote: certificate.reviewNote,
      submittedAt: certificate.submittedAt,
    );
  }

  factory CertificateModel.fromJson(String requestId, Map<String, dynamic> json) {
    final answers = <String, ChecklistAnswer>{};
    for (final entry in (json['checklistAnswers'] as Map<String, dynamic>? ?? const {}).entries) {
      answers[entry.key] = ChecklistAnswer.fromValue(entry.value);
    }
    final notes = <String, String>{};
    for (final entry in (json['defectNotes'] as Map<String, dynamic>? ?? const {}).entries) {
      notes[entry.key] = entry.value as String? ?? '';
    }
    return CertificateModel(
      requestId: requestId,
      inspectorId: json['inspectorId'] as String? ?? '',
      templateId: json['templateId'] as String? ?? CertificateTemplate.id,
      checklistAnswers: answers,
      defectNotes: notes,
      testLoadKg: (json['testLoadKg'] as num?)?.toDouble(),
      durationMinutes: json['durationMinutes'] as int?,
      finalResult: CertificateResult.fromValue(json['finalResult']),
      reviewNote: json['reviewNote'] as String?,
      submittedAt: (json['submittedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Just the inspector's own draft fields — never touches `submittedAt`
  /// (server-stamped only by [CertificateRemoteDataSource.submit]).
  Map<String, dynamic> toJson() => {
    'inspectorId': inspectorId,
    'templateId': templateId,
    'checklistAnswers': checklistAnswers.map((key, value) => MapEntry(key, value.value)),
    'defectNotes': defectNotes,
    'testLoadKg': testLoadKg,
    'durationMinutes': durationMinutes,
    'finalResult': finalResult?.value,
    'reviewNote': reviewNote,
  };

  Certificate toEntity() => Certificate(
    requestId: requestId,
    inspectorId: inspectorId,
    templateId: templateId,
    checklistAnswers: checklistAnswers,
    defectNotes: defectNotes,
    testLoadKg: testLoadKg,
    durationMinutes: durationMinutes,
    finalResult: finalResult,
    reviewNote: reviewNote,
    submittedAt: submittedAt,
  );
}
