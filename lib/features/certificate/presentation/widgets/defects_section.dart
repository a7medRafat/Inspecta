import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/certificate_progress.dart';
import '../../domain/certificate_template.dart';
import '../bloc/certificate_cubit.dart';
import 'certificate_form_fields.dart';
import 'certificate_section_card.dart';

/// Step 4 of the certificate (Feature 05): any defect found, whether it's
/// a danger now or could become one (and by when), and what's needed to
/// put it right. Left empty, the defect and repair fields print as NONE /
/// N/A on the certificate.
class DefectsSection extends StatelessWidget {
  const DefectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocBuilder<CertificateCubit, CertificateState>(
      buildWhen: (previous, current) =>
          previous.certificate?.isDefectsComplete != current.certificate?.isDefectsComplete ||
          previous.currentStep != current.currentStep,
      builder: (context, state) {
        return CertificateSectionCard(
          stepNumber: 4,
          highlighted: state.currentStep == CertificateStep.defects,
          done: state.certificate?.isDefectsComplete ?? false,
          title: t.defectsTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A recorded danger needs the defect described.
              BlocSelector<CertificateCubit, CertificateState, bool>(
                selector: (state) {
                  final certificate = state.certificate;
                  return certificate != null && certificate.hasDefect && certificate.defectSummary == null;
                },
                builder: (context, needsDescription) => CertificateTextInput(
                  textKey: CertText.defectDescription,
                  label: t.defectDescriptionLabel,
                  hint: t.defectDescriptionHint,
                  multiline: true,
                  helper: needsDescription ? t.describeDefectRequired : null,
                ),
              ),
              certificateFieldGap,
              CertificateYesNoInput(question: CertQuestion.existingDanger, label: t.existingDangerLabel),
              const SizedBox(height: 12),
              CertificateYesNoInput(question: CertQuestion.futureDanger, label: t.futureDangerLabel),
              BlocSelector<CertificateCubit, CertificateState, bool>(
                selector: (state) => state.certificate?.answerOf(CertQuestion.futureDanger) == true,
                builder: (context, isFutureDanger) {
                  if (!isFutureDanger) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: CertificateDateInput(dateKey: CertDate.futureDangerBy, label: t.futureDangerByLabel),
                  );
                },
              ),
              certificateFieldGap,
              CertificateTextInput(
                textKey: CertText.repairsRequired,
                label: t.repairsRequiredLabel,
                hint: t.naOption,
                multiline: true,
              ),
              certificateFieldGap,
              CertificateTextInput(textKey: CertText.testsCarriedOut, label: t.testsCarriedOutLabel, multiline: true),
            ],
          ),
        );
      },
    );
  }
}
