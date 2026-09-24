import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

/// A dashed-border reminder for a request whose sender couldn't be
/// matched to a known client (BR-02.4) — tapping "Match" resolves it.
class UnmatchedSenderCard extends StatelessWidget {
  final String senderEmail;
  final VoidCallback onMatch;

  const UnmatchedSenderCard({super.key, required this.senderEmail, required this.onMatch});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFD1FB), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColours.chipAmberBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.error_outline_rounded, color: Color(0xFFB45309)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.newSenderNeedsClient,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                ),
                Text(
                  senderEmail,
                  style: AppTextStyles.subtitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: onMatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColours.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(t.matchAction, style: AppTextStyles.badge.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
