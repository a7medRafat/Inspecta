import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../certificate/domain/certificate_number.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import 'review_labels.dart';

/// The review screen's blue header: back, role and title, the cert number,
/// and the white card saying who submitted it and when.
class ReviewDetailHeader extends StatelessWidget {
  final InspectionRequest request;
  final String? inspectorName;
  final DateTime? submittedAt;

  const ReviewDetailHeader({super.key, required this.request, this.inspectorName, this.submittedAt});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 16, 20, 20),
      decoration: const BoxDecoration(
        color: AppColours.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const _HeaderBackButton(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.roleTechnicalManager,
                      style: AppTextStyles.caption.copyWith(color: AppColours.onPrimaryMuted),
                    ),
                    Text(
                      t.reviewCertificateTitle,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle.copyWith(color: Colors.white, fontSize: 21),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  certNumberFor(request),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppColours.primaryTint, shape: BoxShape.circle),
                  child: Text(
                    _initials(inspectorName),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColours.primaryDark),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(inspectorName ?? '—', style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
                      if (submittedAt != null)
                        Text(
                          t.submittedRelativeLabel(reviewWhenLabel(t, submittedAt!, locale)),
                          style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColours.chipAmberBackground,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(t.awaitingYouBadge, style: AppTextStyles.badge.copyWith(color: AppColours.chipAmberText)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String? name) {
    final parts = (name ?? '').trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return letters.isEmpty ? '?' : letters;
  }
}

class _HeaderBackButton extends StatelessWidget {
  const _HeaderBackButton();

  @override
  Widget build(BuildContext context) {
    // Same square button as `MBackButton`, recoloured for the blue header.
    return IconButton(
      onPressed: () => Navigator.of(context).maybePop(),
      tooltip: AppLocalizations.of(context)!.back,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(44),
        backgroundColor: Colors.white.withValues(alpha: 0.16),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.chevron_left_rounded, size: 26),
    );
  }
}
