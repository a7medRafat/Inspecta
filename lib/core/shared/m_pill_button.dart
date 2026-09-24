import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../consts/app_text_styles.dart';

enum MPillButtonVariant { primary, secondary }

/// Small pill button used for compact actions on a card (Send / Edit /
/// Snooze, Book / Edit / Send, ...).
class MPillButton extends StatelessWidget {
  final String label;
  final MPillButtonVariant variant;
  final VoidCallback onTap;

  const MPillButton({
    super.key,
    required this.label,
    required this.variant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == MPillButtonVariant.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? AppColours.authAccent : AppColours.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTextStyles.badge.copyWith(
            color: isPrimary ? Colors.white : Colors.black.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
