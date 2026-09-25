import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';

/// Steps 2-5's shared card shape: a numbered (or checked, once done)
/// circle, a title/subtitle, and a blue border while it's the current
/// step (Feature 05).
class CertificateSectionCard extends StatelessWidget {
  final int stepNumber;
  final bool highlighted;
  final bool done;
  final String title;
  final String? subtitle;
  final Widget child;

  const CertificateSectionCard({
    super.key,
    required this.stepNumber,
    required this.highlighted,
    required this.done,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: highlighted ? Border.all(color: AppColours.primaryColor, width: 1.5) : null,
        boxShadow: [
          BoxShadow(color: AppColours.ink.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done
                      ? AppColours.successBackground
                      : (highlighted ? AppColours.primaryColor : AppColours.surfaceMuted),
                  shape: BoxShape.circle,
                ),
                child: done
                    ? const Icon(Icons.check_rounded, size: 16, color: AppColours.successIcon)
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: highlighted ? Colors.white : AppColours.inkMuted,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
                    if (subtitle != null)
                      Text(subtitle!, style: AppTextStyles.subtitle.copyWith(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
