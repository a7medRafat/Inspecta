import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/timesheet_entry.dart';

/// Why a coordinator sent an entry back — spelled out, since it's what the
/// inspector has to act on, so it stays on show instead of behind "Details".
class TimesheetReturnedNote extends StatelessWidget {
  final TimesheetEntry entry;

  const TimesheetReturnedNote({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final reviewer = entry.reviewerName;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColours.chipRedBackground, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reviewer == null ? t.timesheetStatusReturned : t.timesheetReturnedBy(reviewer),
            style: AppTextStyles.badge.copyWith(color: AppColours.chipRedText),
          ),
          if (entry.reviewNote != null) ...[
            const SizedBox(height: 4),
            Text(entry.reviewNote!, style: AppTextStyles.subtitle.copyWith(color: AppColours.chipRedText)),
          ],
        ],
      ),
    );
  }
}
