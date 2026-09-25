import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/enums/job_status.dart';
import '../../../../core/framework/mtoast.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../certificate/domain/certificate_number.dart';
import '../../../certificate/domain/certificate_progress.dart';
import '../../../certificate/domain/entities/certificate.dart';
import '../../../certificate/domain/usecases/watch_certificate.dart';
import '../../../certificate/presentation/pages/certificate_page.dart';
import '../../../certificate/presentation/pages/certificate_view_page.dart';
import '../../../certificate/presentation/pdf/certificate_pdf_builder.dart';
import '../../../certificate/presentation/widgets/certificate_labels.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../../requests/presentation/widgets/status_chip.dart';

/// One row on the Certificates list — which of the four layouts it
/// takes depends on the job's status (Feature 05).
class CertificateListCard extends StatelessWidget {
  final InspectionRequest request;

  const CertificateListCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Certificate?>(
      stream: getIt<WatchCertificate>()(request.id),
      builder: (context, snapshot) {
        final certificate = snapshot.data;
        return switch (request.status) {
          JobStatus.certificateReturned => _ReturnedCard(request: request, certificate: certificate),
          JobStatus.inProgress => _DraftCard(request: request, certificate: certificate),
          JobStatus.sentToClient => _SentCard(request: request, certificate: certificate),
          _ => _SubmittedCard(request: request, certificate: certificate),
        };
      },
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final VoidCallback? onTap;

  const _CardShell({required this.child, this.borderColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1.5) : null,
        boxShadow: [
          BoxShadow(color: AppColours.ink.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(borderRadius: BorderRadius.circular(18), onTap: onTap, child: content),
    );
  }
}

class _TopRow extends StatelessWidget {
  final String left;
  final String badgeLabel;
  final Color badgeBackground;
  final Color badgeText;

  const _TopRow({
    required this.left,
    required this.badgeLabel,
    required this.badgeBackground,
    required this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          left,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColours.inkMuted),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(color: badgeBackground, borderRadius: BorderRadius.circular(999)),
          child: Text(badgeLabel, style: AppTextStyles.badge.copyWith(color: badgeText)),
        ),
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TitleBlock({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
        Text(subtitle, style: AppTextStyles.subtitle.copyWith(fontSize: 13), overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _ReturnedCard extends StatelessWidget {
  final InspectionRequest request;
  final Certificate? certificate;

  const _ReturnedCard({required this.request, required this.certificate});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final note = certificate?.reviewNote;
    return _CardShell(
      borderColor: AppColours.chipAmberTextStrong.withValues(alpha: 0.5),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => CertificatePage(request: request)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _TopRow(
            left: certNumberFor(request),
            badgeLabel: t.returnedBadge,
            badgeBackground: AppColours.chipAmberBackground,
            badgeText: AppColours.chipAmberText,
          ),
          const SizedBox(height: 10),
          _TitleBlock(title: request.equipmentTitle, subtitle: request.clientName),
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColours.chipAmberBackground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"$note"',
                style: const TextStyle(fontSize: 13, height: 1.4, color: AppColours.chipAmberTextStrong),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SizedBox(
              height: 40,
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => CertificatePage(request: request)),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColours.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(t.fixAndResubmitAction, style: AppTextStyles.buttonLabel.copyWith(fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  final InspectionRequest request;
  final Certificate? certificate;

  const _DraftCard({required this.request, required this.certificate});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final percent = certificate.percentComplete;
    return _CardShell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => CertificatePage(request: request)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _TopRow(
            left: t.notYetSubmittedLabel,
            badgeLabel: t.draftPercentLabel(percent),
            badgeBackground: AppColours.surfaceMuted,
            badgeText: AppColours.inkSecondary,
          ),
          const SizedBox(height: 10),
          _TitleBlock(title: request.equipmentTitle, subtitle: request.location),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6,
              backgroundColor: AppColours.surfaceMuted,
              valueColor: const AlwaysStoppedAnimation(AppColours.primaryColor),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SizedBox(
              height: 40,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => CertificatePage(request: request)),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColours.primaryDark,
                  side: const BorderSide(color: AppColours.primaryTint, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(t.continueCertificateAction, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmittedCard extends StatelessWidget {
  final InspectionRequest request;
  final Certificate? certificate;

  const _SubmittedCard({required this.request, required this.certificate});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final submittedAt = certificate?.submittedAt;
    return _CardShell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => CertificateViewPage(request: request)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _TopRow(
            left: certNumberFor(request),
            badgeLabel: request.status.label(t),
            badgeBackground: request.status.chipBackground,
            badgeText: request.status.chipText,
          ),
          const SizedBox(height: 10),
          _TitleBlock(title: request.equipmentTitle, subtitle: request.clientName),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                submittedAt == null ? '' : t.submittedRelativeLabel(RelativeDuration.since(submittedAt).label(t)),
                style: AppTextStyles.caption,
              ),
              Text(t.viewAction, style: AppTextStyles.link.copyWith(fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SentCard extends StatelessWidget {
  final InspectionRequest request;
  final Certificate? certificate;

  const _SentCard({required this.request, required this.certificate});

  Future<void> _viewPdf(BuildContext context) async {
    final certificate = this.certificate;
    final t = AppLocalizations.of(context)!;
    if (certificate == null) {
      MToast.showError(message: t.certificateNotFound);
      return;
    }
    final locale = Localizations.localeOf(context).languageCode;
    await Printing.layoutPdf(
      onLayout: (_) => buildCertificatePdf(t: t, request: request, certificate: certificate, locale: locale),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final resultLabel = certificate?.finalResult.label(t) ?? '';
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _TopRow(
            left: certNumberFor(request),
            badgeLabel: request.status.label(t),
            badgeBackground: request.status.chipBackground,
            badgeText: request.status.chipText,
          ),
          const SizedBox(height: 10),
          _TitleBlock(
            title: request.equipmentTitle,
            subtitle: resultLabel.isEmpty ? request.clientName : '${request.clientName} · $resultLabel',
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GestureDetector(
              onTap: () => _viewPdf(context),
              child: Text(t.viewPdfAction, style: AppTextStyles.link.copyWith(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
