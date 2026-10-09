import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/utils/currency.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/timesheet_entry_status.dart';
import '../bloc/timesheet_review_cubit.dart';

/// The coordinator Timesheets tab's blue header: the title and what's
/// waiting on a decision — how many entries, and what they add up to.
class TimesheetReviewHeader extends StatelessWidget {
  const TimesheetReviewHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 20, 20, 18),
      decoration: const BoxDecoration(
        color: AppColours.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.timesheetReviewTitle, style: AppTextStyles.pageTitle.copyWith(color: Colors.white, fontSize: 24)),
          const SizedBox(height: 16),
          BlocBuilder<TimesheetReviewCubit, TimesheetReviewState>(
            builder: (context, state) {
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _StatTile(
                      label: t.timesheetAwaitingApprovalLabel,
                      value: '${state.countOf(TimesheetEntryStatus.pending)}',
                      emphasised: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: _StatTile(
                      label: t.timesheetPendingValueLabel,
                      value: Currency.formatEgp(state.pendingValuePiastres),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasised;

  const _StatTile({required this.label, required this.value, this.emphasised = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: emphasised ? Colors.white : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // A large pending total would otherwise overflow its tile.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: emphasised ? AppColours.chipAmberTextStrong : Colors.white,
              ),
            ),
          ),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: emphasised ? AppColours.inkSecondary : AppColours.onPrimaryMuted,
            ),
          ),
        ],
      ),
    );
  }
}
