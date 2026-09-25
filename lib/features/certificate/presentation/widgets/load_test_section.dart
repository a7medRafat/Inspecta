import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/certificate_progress.dart';
import '../bloc/certificate_cubit.dart';
import 'certificate_section_card.dart';

/// Step 3 of the certificate (Feature 05): the test load and how long it
/// was held.
class LoadTestSection extends StatefulWidget {
  const LoadTestSection({super.key});

  @override
  State<LoadTestSection> createState() => _LoadTestSectionState();
}

class _LoadTestSectionState extends State<LoadTestSection> {
  late final TextEditingController _kgController;
  late final TextEditingController _minutesController;

  @override
  void initState() {
    super.initState();
    final certificate = context.read<CertificateCubit>().state.certificate;
    _kgController = TextEditingController(text: certificate?.testLoadKg?.toStringAsFixed(0) ?? '');
    _minutesController = TextEditingController(text: certificate?.durationMinutes?.toString() ?? '');
  }

  @override
  void dispose() {
    _kgController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocBuilder<CertificateCubit, CertificateState>(
      buildWhen: (previous, current) =>
          previous.certificate?.testLoadKg != current.certificate?.testLoadKg ||
          previous.certificate?.durationMinutes != current.certificate?.durationMinutes ||
          previous.currentStep != current.currentStep,
      builder: (context, state) {
        final certificate = state.certificate;
        if (certificate == null) return const SizedBox.shrink();
        final cubit = context.read<CertificateCubit>();

        return CertificateSectionCard(
          stepNumber: 3,
          highlighted: state.currentStep == CertificateStep.loadTest,
          done: certificate.isLoadTestComplete,
          title: t.loadTestTitle,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _NumberField(
                  label: t.testLoadKgLabel,
                  hintText: 'e.g. 790',
                  controller: _kgController,
                  onChanged: (text) => cubit.updateTestLoadLocal(double.tryParse(text)),
                  onBlur: cubit.persist,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _NumberField(
                  label: t.durationMinLabel,
                  hintText: 'e.g. 10',
                  controller: _minutesController,
                  onChanged: (text) => cubit.updateDurationLocal(int.tryParse(text)),
                  onBlur: cubit.persist,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onBlur;

  const _NumberField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.onChanged,
    required this.onBlur,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.fieldLabel.copyWith(fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          onEditingComplete: onBlur,
          onTapOutside: (_) {
            onBlur();
            FocusScope.of(context).unfocus();
          },
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          style: AppTextStyles.input.copyWith(fontSize: 15),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColours.border, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
