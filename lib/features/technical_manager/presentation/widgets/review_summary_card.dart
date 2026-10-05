import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../certificate/domain/certificate_template.dart';
import '../../../certificate/domain/entities/certificate.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import 'certificate_finding_tiles.dart';
import 'result_banner.dart';

/// What the reviewer is signing off: client, equipment, when it was
/// inspected and when it's next due, the key findings and the verdict.
class ReviewSummaryCard extends StatelessWidget {
  final InspectionRequest request;
  final Certificate certificate;
  final VoidCallback onViewPdf;

  const ReviewSummaryCard({super.key, required this.request, required this.certificate, required this.onViewPdf});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    // The dates the inspector put on the certificate; a certificate from
    // before that template falls back to the job's own schedule.
    final inspected = certificate.dateOf(CertDate.examination) ?? request.scheduledAt ?? request.receivedAt;
    final nextDue =
        certificate.dateOf(CertDate.nextExamination) ?? DateTime(inspected.year + 1, inspected.month, inspected.day);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: AppColours.ink.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.reviewSummaryTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 19)),
              GestureDetector(
                onTap: onViewPdf,
                child: Text(t.viewFullPdfAction, style: AppTextStyles.link.copyWith(fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Fact(label: t.clientLabel, value: request.clientName)),
              const SizedBox(width: 12),
              Expanded(child: _Fact(label: t.equipmentLabel, value: request.equipmentTitle)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Fact(label: t.inspectedLabel, value: DateFormat('d MMM yyyy', locale).format(inspected)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Fact(label: t.nextDueLabel, value: DateFormat('MMM yyyy', locale).format(nextDue)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CertificateFindingTiles(certificate: certificate),
          const SizedBox(height: 12),
          ResultBanner(certificate: certificate),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final String label;
  final String value;

  const _Fact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
      ],
    );
  }
}
