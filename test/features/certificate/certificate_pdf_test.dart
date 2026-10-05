import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspecta/core/enums/job_status.dart';
import 'package:inspecta/features/certificate/domain/certificate_template.dart';
import 'package:inspecta/features/certificate/domain/entities/certificate.dart';
import 'package:inspecta/features/certificate/domain/entities/certificate_result.dart';
import 'package:inspecta/features/certificate/domain/entities/checklist_answer.dart';
import 'package:inspecta/features/certificate/presentation/pdf/certificate_pdf_builder.dart';
import 'package:inspecta/features/requests/domain/entities/inspection_request.dart';
import 'package:inspecta/features/requests/domain/entities/request_item.dart';
import 'package:inspecta/features/requests/domain/entities/request_source.dart';

/// The Air Compressor certificate from TÜV's own Word template, as data.
InspectionRequest airCompressorRequest() => InspectionRequest(
  id: 'REQ-2026-0001',
  source: RequestSource.email,
  clientName: 'The Petroleum Projects & Technical Consultations Company (PETROJET)',
  receivedAt: DateTime(2026, 9, 20),
  location: 'Al-alamein',
  status: JobStatus.sentToClient,
  items: const [RequestItem(id: 'item-1', type: 'Air Compressor')],
);

Certificate airCompressorCertificate() {
  var c = Certificate(
    requestId: 'REQ-2026-0001',
    inspectorId: 'insp-1',
    functionCheck: ChecklistAnswer.pass,
    finalResult: CertificateResult.safeToOperate,
    reviewerName: 'Mahmoud Nasr',
    reviewedAt: DateTime(2026, 9, 25),
    // A diagonal scribble, standing in for a drawn signature.
    signatureStrokes: const [
      [0.05, 0.8, 0.25, 0.2, 0.45, 0.75, 0.65, 0.25, 0.9, 0.7],
    ],
  );
  final texts = {
    CertText.clientRepresentative: 'Mr.:nagy abo elhassan',
    CertText.standardOfInspection: 'BS ISO 5389: 2005',
    CertText.testType: 'Visual & function test',
    CertText.manufacturer: 'CATERPILLAR',
    CertText.modelYear: 'C13',
    CertText.maxWorkingRate: '10 Bar',
    CertText.serialNumber: 'SN.: LGK06312',
    CertText.ownerId: '23811',
    CertText.preparedByName: 'Anas Hegazi',
  };
  texts.forEach((key, value) => c = c.withText(key, value));
  c = c
      .withDate(CertDate.examination, DateTime(2026, 9, 24))
      .withDate(CertDate.nextExamination, DateTime(2027, 3, 23))
      .withAnswer(CertQuestion.firstExamination, false)
      .withAnswer(CertQuestion.within6Months, true)
      .withAnswer(CertQuestion.within12Months, false)
      .withAnswer(CertQuestion.examinationScheme, true)
      .withAnswer(CertQuestion.exceptionalCircumstances, false)
      .withAnswer(CertQuestion.existingDanger, false)
      .withAnswer(CertQuestion.futureDanger, false);
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('renders the Air Compressor certificate as a one-page PDF', () async {
    final bytes = await buildCertificatePdf(request: airCompressorRequest(), certificate: airCompressorCertificate());

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(20000));

    // Set CERT_PDF_OUT to look at the result.
    final out = Platform.environment['CERT_PDF_OUT'];
    if (out != null) File(out).writeAsBytesSync(bytes);
  });

  test('still renders a draft with nothing filled in', () async {
    final bytes = await buildCertificatePdf(
      request: airCompressorRequest(),
      certificate: const Certificate(requestId: 'REQ-2026-0001', inspectorId: 'insp-1'),
    );

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('renders a defect that is a danger, with long text', () async {
    final certificate = airCompressorCertificate()
        .withAnswer(CertQuestion.existingDanger, true)
        .withAnswer(CertQuestion.futureDanger, true)
        .withDate(CertDate.futureDangerBy, DateTime(2026, 10, 24))
        .withText(CertText.defectDescription, 'Safety relief valve seized in the closed position. ' * 6)
        .withText(CertText.repairsRequired, 'Replace the relief valve and re-test at 1.1x working pressure. ' * 4)
        .withText(CertText.note, 'Machine tagged out of service on site. ' * 8);

    final bytes = await buildCertificatePdf(request: airCompressorRequest(), certificate: certificate);

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');

    final out = Platform.environment['CERT_PDF_OUT'];
    if (out != null) File(out.replaceFirst('.pdf', '-danger.pdf')).writeAsBytesSync(bytes);
  });
}
