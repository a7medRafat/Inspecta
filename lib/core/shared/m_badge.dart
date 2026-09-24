import 'package:flutter/material.dart';

import '../consts/app_text_styles.dart';

/// Small rounded pill with bold text: used for status badges and priority
/// chips wherever a coloured label needs to stand out from its surroundings.
class MBadge extends StatelessWidget {
  final String label;
  final Color background;
  final Color textColor;
  final double fontSize;

  const MBadge({
    super.key,
    required this.label,
    required this.background,
    required this.textColor,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: AppTextStyles.badge.copyWith(fontSize: fontSize, color: textColor)),
    );
  }
}
