import 'package:flutter/material.dart';

import '../../../../core/consts/app_text_styles.dart';

/// A small caption over a bold value — "Time spent / 2h 30m" — with an
/// optional line under it for the working behind the number.
class TimesheetFigure extends StatelessWidget {
  final String label;
  final String value;
  final String? caption;

  const TimesheetFigure({super.key, required this.label, required this.value, this.caption});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.emphasis.copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
        if (caption != null) ...[
          const SizedBox(height: 2),
          Text(caption!, style: AppTextStyles.caption.copyWith(fontSize: 12, height: 1.3)),
        ],
      ],
    );
  }
}
