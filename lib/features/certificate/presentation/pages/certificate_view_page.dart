import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/loading.dart';
import '../../../../core/shared/m_back_button.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../../requests/presentation/widgets/status_chip.dart';
import '../../domain/certificate_template.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/entities/checklist_answer.dart';
import '../../domain/usecases/watch_certificate.dart';
import '../widgets/certificate_labels.dart';
import '../widgets/certificate_section_card.dart';
import '../widgets/equipment_details_section.dart';

/// A read-only view of a submitted/approved certificate (Feature 05) —
/// the Certificates list's "View". Unlike [CertificatePage], nothing
/// here is editable: the job has already left `in_progress`, so the
/// backend wouldn't accept a write anyway.
class CertificateViewPage extends StatelessWidget {
  final InspectionRequest request;

  const CertificateViewPage({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: Column(
          children: [
            _ViewHeader(request: request),
            Expanded(
              child: StreamBuilder<Certificate?>(
                stream: getIt<WatchCertificate>()(request.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Loading.loader(context);
                  }
                  final certificate = snapshot.data;
                  if (certificate == null) {
                    return Center(child: Text(t.certificateNotFound, style: AppTextStyles.subtitle));
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      EquipmentDetailsSection(request: request),
                      const SizedBox(height: 14),
                      _ReadOnlyChecklist(certificate: certificate),
                      const SizedBox(height: 14),
                      _ReadOnlyLoadTest(certificate: certificate),
                      const SizedBox(height: 14),
                      _ReadOnlyFinalResult(certificate: certificate),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewHeader extends StatelessWidget {
  final InspectionRequest request;

  const _ViewHeader({required this.request});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 12, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t.templateLabel(CertificateTemplate.id), style: AppTextStyles.caption),
                Text(
                  t.certificateTitle,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 20),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: request.status.chipBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              request.status.label(t),
              style: AppTextStyles.badge.copyWith(color: request.status.chipText),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyChecklist extends StatelessWidget {
  final Certificate certificate;

  const _ReadOnlyChecklist({required this.certificate});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return CertificateSectionCard(
      stepNumber: 2,
      highlighted: false,
      done: true,
      title: t.inspectionChecklistTitle,
      child: Column(
        children: [
          for (var i = 0; i < CertificateTemplate.items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _ReadOnlyChecklistRow(
              label: CertificateTemplate.items[i].label,
              answer: certificate.answerFor(CertificateTemplate.items[i].id),
              defectNote: certificate.defectNoteFor(CertificateTemplate.items[i].id),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReadOnlyChecklistRow extends StatelessWidget {
  final String label;
  final ChecklistAnswer answer;
  final String? defectNote;

  const _ReadOnlyChecklistRow({required this.label, required this.answer, this.defectNote});

  Color get _badgeBackground => switch (answer) {
    ChecklistAnswer.pass => AppColours.chipGreenBackground,
    ChecklistAnswer.fail => AppColours.chipRedBackground,
    ChecklistAnswer.na || ChecklistAnswer.unanswered => AppColours.chipGreyBackground,
  };

  Color get _badgeText => switch (answer) {
    ChecklistAnswer.pass => AppColours.chipGreenText,
    ChecklistAnswer.fail => AppColours.chipRedText,
    ChecklistAnswer.na || ChecklistAnswer.unanswered => AppColours.chipGreyText,
  };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColours.surfaceMuted, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label, style: AppTextStyles.cardTitle.copyWith(fontSize: 14))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: _badgeBackground, borderRadius: BorderRadius.circular(999)),
                child: Text(answer.label(t), style: AppTextStyles.badge.copyWith(color: _badgeText)),
              ),
            ],
          ),
          if (answer == ChecklistAnswer.fail && (defectNote ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(defectNote!, style: AppTextStyles.subtitle.copyWith(fontSize: 13)),
          ],
        ],
      ),
    );
  }
}

class _ReadOnlyLoadTest extends StatelessWidget {
  final Certificate certificate;

  const _ReadOnlyLoadTest({required this.certificate});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return CertificateSectionCard(
      stepNumber: 3,
      highlighted: false,
      done: true,
      title: t.loadTestTitle,
      child: Row(
        children: [
          Expanded(child: _ValueBlock(label: t.testLoadKgLabel, value: certificate.testLoadKg?.toStringAsFixed(0) ?? '—')),
          const SizedBox(width: 14),
          Expanded(child: _ValueBlock(label: t.durationMinLabel, value: certificate.durationMinutes?.toString() ?? '—')),
        ],
      ),
    );
  }
}

class _ValueBlock extends StatelessWidget {
  final String label;
  final String value;

  const _ValueBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
      ],
    );
  }
}

class _ReadOnlyFinalResult extends StatelessWidget {
  final Certificate certificate;

  const _ReadOnlyFinalResult({required this.certificate});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final label = certificate.finalResult.label(t);
    return CertificateSectionCard(
      stepNumber: 5,
      highlighted: false,
      done: true,
      title: t.finalResultTitle,
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 20, color: AppColours.successIcon),
          const SizedBox(width: 10),
          Text(
            label.isEmpty ? '—' : label,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 15, color: AppColours.primaryDark),
          ),
        ],
      ),
    );
  }
}
