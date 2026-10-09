import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

/// "Details ⌄" / "Hide details ⌃" — expands a card's breakdown in place.
class TimesheetDetailsToggle extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const TimesheetDetailsToggle({super.key, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return TextButton.icon(
      onPressed: onTap,
      iconAlignment: IconAlignment.end,
      icon: Icon(expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 20),
      label: Text(expanded ? t.timesheetHideDetails : t.timesheetShowDetails),
      style: TextButton.styleFrom(
        foregroundColor: AppColours.inkSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        minimumSize: const Size(0, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: AppTextStyles.badge.copyWith(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
