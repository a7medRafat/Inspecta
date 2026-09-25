import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

/// The coordinator just assigned a job the inspector hasn't responded
/// to yet — a nudge toward its card, already visible in the list below
/// (Feature 05).
class NewTaskBanner extends StatelessWidget {
  final VoidCallback onOpen;

  const NewTaskBanner({super.key, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColours.primarySoft, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none_rounded, size: 18, color: AppColours.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppTextStyles.subtitle.copyWith(fontSize: 14, color: AppColours.inkBody),
                children: [
                  TextSpan(text: '${t.newTaskLabel} ', style: const TextStyle(fontWeight: FontWeight.w800)),
                  TextSpan(text: t.fromYourCoordinatorLabel),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onOpen,
            style: FilledButton.styleFrom(
              backgroundColor: AppColours.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(t.openAction, style: AppTextStyles.buttonLabel.copyWith(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
