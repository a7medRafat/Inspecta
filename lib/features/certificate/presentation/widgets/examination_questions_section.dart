import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/certificate_progress.dart';
import '../../domain/certificate_template.dart';
import '../bloc/certificate_cubit.dart';
import 'certificate_form_fields.dart';
import 'certificate_section_card.dart';

/// Step 3 of the certificate (Feature 05): the six yes/no questions about
/// this examination — is it the first one on a new site, and when/why it
/// was carried out.
class ExaminationQuestionsSection extends StatelessWidget {
  const ExaminationQuestionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocBuilder<CertificateCubit, CertificateState>(
      buildWhen: (previous, current) =>
          previous.certificate?.isQuestionsComplete != current.certificate?.isQuestionsComplete ||
          previous.currentStep != current.currentStep,
      builder: (context, state) {
        return CertificateSectionCard(
          stepNumber: 3,
          highlighted: state.currentStep == CertificateStep.questions,
          done: state.certificate?.isQuestionsComplete ?? false,
          title: t.examinationQuestionsTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CertificateYesNoInput(question: CertQuestion.firstExamination, label: t.questionFirstExamination),
              // The paper form only asks this when the answer above is yes.
              BlocSelector<CertificateCubit, CertificateState, bool>(
                selector: (state) => state.certificate?.answerOf(CertQuestion.firstExamination) == true,
                builder: (context, isFirstExamination) {
                  if (!isFirstExamination) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: CertificateYesNoInput(
                      question: CertQuestion.installedCorrectly,
                      label: t.questionInstalledCorrectly,
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              Text(t.examinationCarriedOutLabel, style: AppTextStyles.cardTitle.copyWith(fontSize: 14)),
              const SizedBox(height: 10),
              CertificateYesNoInput(question: CertQuestion.within6Months, label: t.questionWithin6Months),
              const SizedBox(height: 12),
              CertificateYesNoInput(question: CertQuestion.within12Months, label: t.questionWithin12Months),
              const SizedBox(height: 12),
              CertificateYesNoInput(question: CertQuestion.examinationScheme, label: t.questionExaminationScheme),
              const SizedBox(height: 12),
              CertificateYesNoInput(
                question: CertQuestion.exceptionalCircumstances,
                label: t.questionExceptionalCircumstances,
              ),
            ],
          ),
        );
      },
    );
  }
}
