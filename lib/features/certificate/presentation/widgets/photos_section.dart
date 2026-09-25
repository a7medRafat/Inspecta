import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/certificate_cubit.dart';
import 'certificate_labels.dart';
import 'certificate_section_card.dart';

/// Step 4 of the certificate (Feature 05, scope-cut #2): photo upload
/// isn't built yet, so this is a stubbed tile — optional, never blocks
/// submission.
class PhotosSection extends StatelessWidget {
  const PhotosSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocBuilder<CertificateCubit, CertificateState>(
      buildWhen: (previous, current) => previous.currentStep != current.currentStep,
      builder: (context, state) {
        return CertificateSectionCard(
          stepNumber: 4,
          highlighted: false,
          done: true,
          title: t.photosTitle,
          child: SizedBox(
            width: 88,
            height: 88,
            child: OutlinedButton(
              onPressed: () => showCertificateComingSoon(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColours.primaryDark,
                side: const BorderSide(color: AppColours.border, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded),
                  Text(t.addAction),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
