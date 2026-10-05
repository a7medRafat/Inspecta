import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../domain/certificate_progress.dart';
import '../../domain/certificate_template.dart';
import '../../domain/entities/checklist_answer.dart';
import '../bloc/certificate_cubit.dart';
import 'certificate_form_fields.dart';
import 'certificate_labels.dart';
import 'certificate_section_card.dart';

/// Step 2 of the certificate (Feature 05): the "Item information / Test
/// results" block — what was inspected (pre-filled from the request, but
/// correctable on site) and its function check.
class ItemInformationSection extends StatelessWidget {
  final InspectionRequest request;

  const ItemInformationSection({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocBuilder<CertificateCubit, CertificateState>(
      buildWhen: (previous, current) =>
          previous.certificate?.isItemComplete != current.certificate?.isItemComplete ||
          previous.currentStep != current.currentStep,
      builder: (context, state) {
        return CertificateSectionCard(
          stepNumber: 2,
          highlighted: state.currentStep == CertificateStep.item,
          done: state.certificate?.isItemComplete ?? false,
          title: t.itemInformationTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CertificateReadOnlyField(
                label: t.inspectedItemLabel,
                value: request.items.isEmpty ? request.equipmentTitle : request.items.first.type,
              ),
              certificateFieldGap,
              CertificateTextInput(textKey: CertText.manufacturer, label: t.manufacturerLabel),
              certificateFieldGap,
              CertificateTextInput(textKey: CertText.modelYear, label: t.modelYearLabel),
              certificateFieldGap,
              CertificateTextInput(textKey: CertText.maxWorkingRate, label: t.maxWorkingRateLabel),
              certificateFieldGap,
              CertificateTextInput(textKey: CertText.serialNumber, label: t.serialNumberLabel),
              certificateFieldGap,
              CertificateTextInput(textKey: CertText.ownerId, label: t.ownerIdLabel),
              certificateFieldGap,
              const _FunctionCheck(),
              certificateFieldGap,
              CertificateTextInput(textKey: CertText.ndt, label: t.ndtLabel, hint: t.naOption),
            ],
          ),
        );
      },
    );
  }
}

class _FunctionCheck extends StatelessWidget {
  const _FunctionCheck();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocSelector<CertificateCubit, CertificateState, ChecklistAnswer>(
      selector: (state) => state.certificate?.functionCheck ?? ChecklistAnswer.unanswered,
      builder: (context, answer) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.functionCheckLabel, style: AppTextStyles.fieldLabel.copyWith(fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColours.surfaceMuted, borderRadius: BorderRadius.circular(14)),
              child: CertificateSegmented<ChecklistAnswer>(
                value: answer,
                options: [
                  CertificateSegmentOption(
                    label: ChecklistAnswer.pass.label(t),
                    value: ChecklistAnswer.pass,
                    selectedColor: AppColours.successIcon,
                  ),
                  CertificateSegmentOption(
                    label: ChecklistAnswer.fail.label(t),
                    value: ChecklistAnswer.fail,
                    selectedColor: AppColours.errorIcon,
                  ),
                  CertificateSegmentOption(
                    label: ChecklistAnswer.na.label(t),
                    value: ChecklistAnswer.na,
                    selectedColor: AppColours.inkMuted,
                  ),
                ],
                onChanged: context.read<CertificateCubit>().setFunctionCheck,
              ),
            ),
          ],
        );
      },
    );
  }
}
