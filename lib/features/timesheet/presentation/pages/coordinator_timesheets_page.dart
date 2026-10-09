import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_layout.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/framework/mtoast.dart';
import '../../../../core/shared/loading.dart';
import '../../../../core/shared/m_notice.dart';
import '../../../../core/utils/currency.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../technical_manager/presentation/widgets/return_note_dialog.dart';
import '../../domain/entities/timesheet_entry_status.dart';
import '../../domain/entities/timesheet_failure.dart';
import '../bloc/timesheet_review_cubit.dart';
import '../widgets/timesheet_labels.dart';
import '../widgets/timesheet_review_card.dart';
import '../widgets/timesheet_review_filter_tabs.dart';
import '../widgets/timesheet_review_header.dart';

/// The coordinator's Timesheets tab: what each inspector logged for their
/// jobs — time and price — to approve or send back with a reason.
class CoordinatorTimesheetsPage extends StatelessWidget {
  const CoordinatorTimesheetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TimesheetReviewCubit>()..start(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColours.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const TimesheetReviewHeader(),
                Expanded(
                  child: BlocBuilder<TimesheetReviewCubit, TimesheetReviewState>(
                    builder: (context, state) => switch (state.status) {
                      TimesheetReviewStatus.loading => Loading.loader(context),
                      TimesheetReviewStatus.error => _ErrorState(failure: state.failure!),
                      TimesheetReviewStatus.ready => _ReviewList(state: state),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  final TimesheetReviewState state;

  const _ReviewList({required this.state});

  Future<void> _approve(BuildContext context, TimesheetReviewItem item) async {
    final cubit = context.read<TimesheetReviewCubit>();
    if (cubit.state.busyRequestId != null) return;
    final t = AppLocalizations.of(context)!;

    final entry = item.entry;
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(t.timesheetApproveTitle),
        content: Text(
          entry.hasExpenses
              ? t.timesheetApproveMessageWithTransport(
                  item.inspector?.name ?? '—',
                  formatMinutes(t, entry.minutes),
                  entry.hasPrice ? Currency.formatEgp(entry.pricePiastres) : '—',
                  Currency.formatEgp(entry.expensesPiastres),
                )
              : t.timesheetApproveMessage(
                  item.inspector?.name ?? '—',
                  formatMinutes(t, entry.minutes),
                  entry.hasPrice ? Currency.formatEgp(entry.pricePiastres) : '—',
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(t.cancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(t.approveConfirmAction)),
        ],
      ),
    );
    if (confirmed != true) return;

    _report(await cubit.approve(entry.requestId), t, successMessage: t.timesheetApprovedMessage);
  }

  Future<void> _return(BuildContext context, TimesheetReviewItem item) async {
    final cubit = context.read<TimesheetReviewCubit>();
    if (cubit.state.busyRequestId != null) return;
    final t = AppLocalizations.of(context)!;

    final note = await ReturnNoteDialog.show(context, hint: t.timesheetReturnReasonHint);
    if (note == null) return;

    _report(await cubit.sendBack(item.entry.requestId, note), t, successMessage: t.timesheetReturnedMessage);
  }

  void _report(TimesheetFailureCode? failure, AppLocalizations t, {required String successMessage}) {
    if (failure == null) {
      MToast.showSuccess(message: successMessage);
    } else {
      MToast.showError(message: failure.message(t));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final items = state.items;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, AppLayout.bottomNavClearance),
      children: [
        const TimesheetReviewFilterTabs(),
        const SizedBox(height: 16),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                state.filter == TimesheetEntryStatus.pending ? t.timesheetReviewEmptyPending : t.timesheetReviewEmptyOther,
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle,
              ),
            ),
          )
        else
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            TimesheetReviewCard(
              key: ValueKey(items[i].entry.requestId),
              item: items[i],
              busy: state.busyRequestId == items[i].entry.requestId,
              onApprove: () => _approve(context, items[i]),
              onReturn: () => _return(context, items[i]),
            ),
          ],
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final TimesheetFailureCode failure;

  const _ErrorState({required this.failure});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MNotice(type: MNoticeType.error, message: failure.message(t)),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: context.read<TimesheetReviewCubit>().retry, child: Text(t.retry)),
          ],
        ),
      ),
    );
  }
}
