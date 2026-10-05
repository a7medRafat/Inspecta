import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../certificate/domain/certificate_number.dart';
import '../../../certificate/domain/entities/certificate.dart';
import '../../../certificate/domain/usecases/watch_certificate.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import 'review_labels.dart';

/// One certificate waiting on the technical manager's signature: cert
/// number, verdict badge, equipment and client, who submitted it and when,
/// and the "Review & sign" action (filled when there's a finding to look
/// at, outlined for a clean "safe" one).
class ReviewCertificateCard extends StatelessWidget {
  final InspectionRequest request;
  final String? inspectorName;
  final VoidCallback onOpen;

  const ReviewCertificateCard({super.key, required this.request, required this.onOpen, this.inspectorName});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    return StreamBuilder<Certificate?>(
      stream: getIt<WatchCertificate>()(request.id),
      builder: (context, snapshot) {
        final certificate = snapshot.data;
        final result = certificate?.finalResult;
        final submittedAt = certificate?.submittedAt;
        final name = inspectorName;
        final when = submittedAt == null ? null : reviewWhenLabel(t, submittedAt, locale);
        final subtitle = switch ((name, when)) {
          (final String n, final String w) => t.byInspectorWhenLabel(n, w),
          (final String n, null) => n,
          (null, final String w) => w,
          _ => '',
        };
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
                  if (result != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: result.badgeBackground, borderRadius: BorderRadius.circular(999)),
                      child: Text(result.badgeLabel(t), style: AppTextStyles.badge.copyWith(color: result.badgeText)),
                    )
                  else
                    const SizedBox.shrink(),
                  Text(
                    certNumberFor(request),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColours.inkMuted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('${request.equipmentTitle} — ${request.clientName}', style: AppTextStyles.cardTitle.copyWith(fontSize: 17)),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.subtitle.copyWith(fontSize: 13)),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: result.needsAttention
                    ? FilledButton(
                        onPressed: onOpen,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColours.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(t.reviewAndSignAction, style: AppTextStyles.buttonLabel.copyWith(fontSize: 15)),
                      )
                    : OutlinedButton(
                        onPressed: onOpen,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColours.primaryDark,
                          side: const BorderSide(color: AppColours.primaryTint, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          t.reviewAndSignAction,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
