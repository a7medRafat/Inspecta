import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/timesheet_review_cubit.dart';
import 'timesheet_breakdown.dart';
import 'timesheet_details_toggle.dart';
import 'timesheet_labels.dart';
import 'timesheet_returned_note.dart';
import 'timesheet_summary.dart';

/// One inspector's logged entry on the coordinator's Timesheets tab: who,
/// which job, the two numbers it comes to, and — while it's pending — the
/// Return / Approve decision. How the time and money add up is under
/// "Details", so the decision is made on the headline and checked in the
/// working only when it needs to be.
class TimesheetReviewCard extends StatefulWidget {
  final TimesheetReviewItem item;

  /// A decision on this entry is being saved.
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReturn;

  const TimesheetReviewCard({
    super.key,
    required this.item,
    required this.busy,
    required this.onApprove,
    required this.onReturn,
  });

  @override
  State<TimesheetReviewCard> createState() => _TimesheetReviewCardState();
}

class _TimesheetReviewCardState extends State<TimesheetReviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final item = widget.item;
    final entry = item.entry;
    final request = item.request;
    final scheduledAt = request?.scheduledAt;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppColours.ink.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
          BoxShadow(color: AppColours.ink.withValues(alpha: 0.04), blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColours.primaryTint, shape: BoxShape.circle),
                child: Text(
                  item.inspector?.initials ?? '?',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColours.primaryDark),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.inspector?.name ?? '—',
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      request == null ? entry.requestId : '${request.equipmentTitle} · ${request.clientName}',
                      style: AppTextStyles.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // What's pending needs no label — the tab says so. Once decided,
              // the entry says which way it went.
              if (!entry.isPending) ...[
                const SizedBox(width: 8),
                TimesheetEntryStatusChip(status: entry.status),
              ],
            ],
          ),
          if (scheduledAt != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColours.inkMuted),
                const SizedBox(width: 6),
                Text(DateFormat('EEE, d MMM · HH:mm', locale).format(scheduledAt), style: AppTextStyles.caption),
              ],
            ),
          ],
          const SizedBox(height: 14),
          TimesheetSummary(entry: entry),
          if (entry.isReturned) ...[
            const SizedBox(height: 10),
            TimesheetReturnedNote(entry: entry),
          ],
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(2, 14, 2, 4),
                    child: TimesheetBreakdown(entry: entry),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              TimesheetDetailsToggle(expanded: _expanded, onTap: () => setState(() => _expanded = !_expanded)),
            ],
          ),
          if (entry.isPending) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: widget.busy ? null : widget.onReturn,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColours.dangerText,
                          side: const BorderSide(color: AppColours.dangerBorder, width: 1.5),
                          textStyle: AppTextStyles.buttonLabel.copyWith(fontSize: 14, color: AppColours.dangerText),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(t.returnAction),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: widget.busy ? null : widget.onApprove,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColours.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: widget.busy
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : Text(t.approveConfirmAction, style: AppTextStyles.buttonLabel.copyWith(fontSize: 14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}
