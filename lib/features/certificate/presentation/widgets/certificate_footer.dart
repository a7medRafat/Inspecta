import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/framework/mtoast.dart';
import '../../../../core/shared/m_primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/certificate_cubit.dart';
import 'certificate_labels.dart';

/// "Preview" (stubbed) and "Submit to technical manager" — enabled only
/// once the checklist, load test and final result are all filled in
/// (photos stay optional).
class CertificateFooter extends StatelessWidget {
  const CertificateFooter({super.key});

  Future<void> _confirmSubmit(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(t.confirmSubmitCertificateTitle),
        content: Text(t.confirmSubmitCertificateMessage),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(t.cancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(t.submitAction)),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<CertificateCubit>().submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColours.border)),
      ),
      child: BlocConsumer<CertificateCubit, CertificateState>(
        listenWhen: (previous, current) => current.actionSeq != previous.actionSeq,
        listener: (context, state) {
          if (state.lastActionSuccess) {
            MToast.showSuccess(message: t.certificateSubmittedMessage);
            Navigator.of(context).pop();
          } else if (state.lastActionFailure != null) {
            MToast.showError(message: state.lastActionFailure!.message(t));
          }
        },
        builder: (context, state) {
          final canSubmit = (state.certificate?.isReadyToSubmit ?? false) && !state.isSubmitting;
          return Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => showCertificateComingSoon(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColours.inkBody,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColours.border, width: 1.5),
                      textStyle: AppTextStyles.buttonLabel.copyWith(fontSize: 14, color: AppColours.inkBody),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(t.previewAction),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52,
                  child: MPrimaryButton(
                    label: t.submitToTechnicalManagerAction,
                    loading: state.isSubmitting,
                    onPressed: canSubmit ? () => _confirmSubmit(context) : null,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
