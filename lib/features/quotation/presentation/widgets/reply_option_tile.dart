import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';

/// One of the three reply choices (BR-03.1): a big radio-style row with a
/// title and a one-line explanation.
class ReplyOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  /// Red styling for the Reject option, matching the mockup.
  final bool danger;

  const ReplyOptionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = danger ? AppColours.errorIcon : AppColours.primaryColor;
    final titleColor = selected ? accent : AppColours.ink;

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColours.primarySoft : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accent : AppColours.surfaceMuted,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 22,
                color: selected ? accent : AppColours.inkMuted,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 15,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.subtitle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
