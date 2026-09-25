import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/certificate_progress.dart';
import '../../domain/certificate_template.dart';
import '../../domain/entities/checklist_answer.dart';
import '../bloc/certificate_cubit.dart';
import 'certificate_labels.dart';
import 'certificate_section_card.dart';

/// Step 2 of the certificate (Feature 05): Pass/Fail/N/A per item, with a
/// required defect note (and a stubbed photo affordance) once an item
/// fails.
class ChecklistSection extends StatefulWidget {
  const ChecklistSection({super.key});

  @override
  State<ChecklistSection> createState() => _ChecklistSectionState();
}

class _ChecklistSectionState extends State<ChecklistSection> {
  final Map<String, TextEditingController> _controllers = {};

  TextEditingController _controllerFor(String itemId, String initialText) {
    final existing = _controllers[itemId];
    if (existing != null) return existing;
    return _controllers[itemId] = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocBuilder<CertificateCubit, CertificateState>(
      buildWhen: (previous, current) =>
          previous.certificate?.checklistAnswers != current.certificate?.checklistAnswers ||
          previous.certificate?.defectNotes != current.certificate?.defectNotes ||
          previous.currentStep != current.currentStep,
      builder: (context, state) {
        final certificate = state.certificate;
        if (certificate == null) return const SizedBox.shrink();
        final cubit = context.read<CertificateCubit>();

        return CertificateSectionCard(
          stepNumber: 2,
          highlighted: state.currentStep == CertificateStep.checklist,
          done: certificate.isChecklistComplete,
          title: t.inspectionChecklistTitle,
          subtitle: t.itemsAnsweredLabel(certificate.answeredCount, CertificateTemplate.items.length),
          child: Column(
            children: [
              for (var i = 0; i < CertificateTemplate.items.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _ChecklistItemTile(
                  item: CertificateTemplate.items[i],
                  answer: certificate.answerFor(CertificateTemplate.items[i].id),
                  defectNoteController: _controllerFor(
                    CertificateTemplate.items[i].id,
                    certificate.defectNoteFor(CertificateTemplate.items[i].id) ?? '',
                  ),
                  onAnswer: (answer) => cubit.setAnswer(CertificateTemplate.items[i].id, answer),
                  onDefectNoteChanged: (text) =>
                      cubit.updateDefectNoteLocal(CertificateTemplate.items[i].id, text),
                  onDefectNoteBlur: cubit.persist,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ChecklistItemTile extends StatelessWidget {
  final CertificateChecklistItem item;
  final ChecklistAnswer answer;
  final TextEditingController defectNoteController;
  final ValueChanged<ChecklistAnswer> onAnswer;
  final ValueChanged<String> onDefectNoteChanged;
  final VoidCallback onDefectNoteBlur;

  const _ChecklistItemTile({
    required this.item,
    required this.answer,
    required this.defectNoteController,
    required this.onAnswer,
    required this.onDefectNoteChanged,
    required this.onDefectNoteBlur,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isFail = answer == ChecklistAnswer.fail;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isFail ? AppColours.errorBackground.withValues(alpha: 0.5) : AppColours.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(item.label, style: AppTextStyles.cardTitle.copyWith(fontSize: 14)),
          const SizedBox(height: 10),
          _AnswerSegmented(value: answer, onChanged: onAnswer),
          if (isFail) ...[
            const SizedBox(height: 12),
            Text(
              t.describeDefectRequired,
              style: AppTextStyles.caption.copyWith(color: AppColours.dangerText, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: defectNoteController,
              onChanged: onDefectNoteChanged,
              onEditingComplete: onDefectNoteBlur,
              onTapOutside: (_) {
                onDefectNoteBlur();
                FocusScope.of(context).unfocus();
              },
              maxLines: 2,
              style: AppTextStyles.input.copyWith(fontWeight: FontWeight.w400, fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColours.dangerBorder, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showCertificateComingSoon(context),
                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                label: Text(t.addPhotoOfDefectAction),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColours.dangerText,
                  side: const BorderSide(color: AppColours.dangerBorder, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerSegmented extends StatelessWidget {
  final ChecklistAnswer value;
  final ValueChanged<ChecklistAnswer> onChanged;

  const _AnswerSegmented({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: t.passOption,
              selected: value == ChecklistAnswer.pass,
              background: AppColours.successIcon,
              textColor: Colors.white,
              onTap: () => onChanged(ChecklistAnswer.pass),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _Segment(
              label: t.failOption,
              selected: value == ChecklistAnswer.fail,
              background: AppColours.errorIcon,
              textColor: Colors.white,
              onTap: () => onChanged(ChecklistAnswer.fail),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _Segment(
              label: t.naOption,
              selected: value == ChecklistAnswer.na,
              background: AppColours.surfaceMuted,
              textColor: AppColours.inkBody,
              onTap: () => onChanged(ChecklistAnswer.na),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final Color background;
  final Color textColor;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.selected,
    required this.background,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? background : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.badge.copyWith(color: selected ? textColor : AppColours.inkMuted),
          ),
        ),
      ),
    );
  }
}
