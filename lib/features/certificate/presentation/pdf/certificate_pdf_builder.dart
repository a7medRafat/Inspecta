import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../l10n/app_localizations.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../domain/certificate_number.dart';
import '../../domain/certificate_template.dart';
import '../../domain/entities/certificate.dart';
import '../widgets/certificate_labels.dart';

/// Renders a submitted certificate as a simple, printable PDF (Feature
/// 05's "View PDF") — a plain document, not a styled letterhead;
/// there's no design asset or logo to draw from yet.
Future<Uint8List> buildCertificatePdf({
  required AppLocalizations t,
  required InspectionRequest request,
  required Certificate certificate,
  required String locale,
}) async {
  final doc = pw.Document();
  final dateFormat = DateFormat('d MMM yyyy, HH:mm', locale);

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(t.certificateTitle, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.Text(t.templateLabel(certificate.templateId), style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
          pw.SizedBox(height: 4),
          pw.Text(certNumberFor(request), style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
          pw.Divider(height: 24),

          pw.Text(t.equipmentDetailsTitle, style: _sectionStyle),
          pw.SizedBox(height: 6),
          pw.Text(request.equipmentTitle, style: _sectionStyle),
          pw.Text('${request.clientName} · ${request.location}'),
          pw.SizedBox(height: 18),

          pw.Text(t.inspectionChecklistTitle, style: _sectionStyle),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: const {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth(1)},
            children: [
              for (final item in CertificateTemplate.items)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(item.label),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(certificate.answerFor(item.id).label(t)),
                    ),
                  ],
                ),
            ],
          ),
          for (final item in CertificateTemplate.items)
            if (certificate.defectNoteFor(item.id)?.isNotEmpty ?? false)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 6),
                child: pw.Text(
                  '${item.label}: ${certificate.defectNoteFor(item.id)}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.red800),
                ),
              ),
          pw.SizedBox(height: 18),

          pw.Text(t.loadTestTitle, style: _sectionStyle),
          pw.SizedBox(height: 6),
          pw.Text(
            '${t.testLoadKgLabel}: ${certificate.testLoadKg?.toStringAsFixed(0) ?? '—'}    '
            '${t.durationMinLabel}: ${certificate.durationMinutes ?? '—'}',
          ),
          pw.SizedBox(height: 18),

          pw.Text(t.finalResultTitle, style: _sectionStyle),
          pw.SizedBox(height: 6),
          pw.Text(certificate.finalResult.label(t), style: _sectionStyle),
          pw.SizedBox(height: 24),

          if (certificate.submittedAt != null)
            pw.Text(
              t.submittedRelativeLabel(dateFormat.format(certificate.submittedAt!)),
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
        ],
      ),
    ),
  );

  return doc.save();
}

final _sectionStyle = pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold);
