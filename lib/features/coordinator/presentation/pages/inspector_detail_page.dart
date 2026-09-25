import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/framework/mtoast.dart';
import '../../../../core/shared/m_back_button.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/widgets/auth_labels.dart';
import '../../domain/inspector_day_summary.dart';
import '../bloc/inspector_detail_cubit.dart';
import '../widgets/assign_job_picker_sheet.dart';
import '../widgets/coordinator_labels.dart';
import '../widgets/inspector_task_row.dart';
import '../widgets/qualifications_card.dart';
import '../widgets/weekly_schedule_card.dart';
import 'assign_inspector_page.dart';
import 'inspector_all_tasks_page.dart';

/// Feature 04 §5's inspector detail screen: today's status, this week's
/// schedule, this month's stats, qualifications, upcoming tasks, and the
/// coordinator's actions (assign a job, mark leave).
class InspectorDetailPage extends StatelessWidget {
  final AppUser inspector;

  const InspectorDetailPage({super.key, required this.inspector});

  void _comingSoon(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.comingSoon), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _assignAJob(BuildContext context) async {
    final job = await AssignJobPickerSheet.show(context);
    if (job == null || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssignInspectorPage(request: job, preselectedInspectorId: inspector.id),
      ),
    );
  }

  Future<void> _markLeave(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final cubit = context.read<InspectorDetailCubit>();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 2),
      helpText: t.markLeaveAction,
    );
    if (picked == null || !context.mounted) return;
    await cubit.markLeave(picked);
    if (!context.mounted) return;
    if (cubit.state.lastActionSuccess) {
      MToast.showSuccess(message: t.leaveMarkedMessage);
      Navigator.of(context).pop();
    } else {
      MToast.showError(message: cubit.state.lastActionFailure!.message(t));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InspectorDetailCubit>(param1: inspector)..start(),
      child: Scaffold(
        backgroundColor: AppColours.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              BlocBuilder<InspectorDetailCubit, InspectorDetailState>(
                buildWhen: (previous, current) => previous.requests != current.requests,
                builder: (context, state) {
                  final cubit = context.read<InspectorDetailCubit>();
                  final onSiteNow = cubit.todaySummary.availability == InspectorAvailability.busy;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const MBackButton(),
                      if (onSiteNow)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColours.chipAmberBackground,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.onSiteNowBadge,
                            style: AppTextStyles.badge.copyWith(color: AppColours.chipAmberText),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColours.primaryTint, shape: BoxShape.circle),
                    child: Text(
                      inspector.initials,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColours.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(inspector.name, style: AppTextStyles.pageTitle.copyWith(fontSize: 22)),
                        Text(inspector.role.label(AppLocalizations.of(context)!), style: AppTextStyles.subtitle),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _ActionsRow(onAssign: () => _assignAJob(context), onComingSoon: () => _comingSoon(context)),
              const SizedBox(height: 20),
              BlocBuilder<InspectorDetailCubit, InspectorDetailState>(
                buildWhen: (previous, current) => previous.requests != current.requests,
                builder: (context, state) {
                  final stats = context.read<InspectorDetailCubit>().monthlyStats;
                  return _StatsRow(stats: stats);
                },
              ),
              const SizedBox(height: 20),
              BlocBuilder<InspectorDetailCubit, InspectorDetailState>(
                buildWhen: (previous, current) => previous.requests != current.requests,
                builder: (context, state) {
                  final cubit = context.read<InspectorDetailCubit>();
                  return WeeklyScheduleCard(weekDates: cubit.weekDates, taskCounts: cubit.weekTaskCounts);
                },
              ),
              const SizedBox(height: 20),
              QualificationsCard(qualifications: inspector.qualifications),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.upcomingTasksTitle,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                  ),
                  BlocBuilder<InspectorDetailCubit, InspectorDetailState>(
                    buildWhen: (previous, current) => previous.requests != current.requests,
                    builder: (context, state) {
                      final upcoming = context.read<InspectorDetailCubit>().upcomingTasks;
                      if (upcoming.isEmpty) return const SizedBox.shrink();
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => InspectorAllTasksPage(inspectorName: inspector.name, tasks: upcoming),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)!.seeAllAction, style: AppTextStyles.link),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              BlocBuilder<InspectorDetailCubit, InspectorDetailState>(
                buildWhen: (previous, current) => previous.requests != current.requests,
                builder: (context, state) {
                  final upcoming = context.read<InspectorDetailCubit>().upcomingTasks;
                  if (upcoming.isEmpty) {
                    return Text(AppLocalizations.of(context)!.emptyUpcomingTasks, style: AppTextStyles.caption);
                  }
                  final shown = upcoming.take(2).toList();
                  return Column(
                    children: [
                      for (var i = 0; i < shown.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        InspectorTaskRow(task: shown[i]),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _markLeave(context),
                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                  label: Text(AppLocalizations.of(context)!.markLeaveAction),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColours.inkBody,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColours.border, width: 1.5),
                    textStyle: AppTextStyles.buttonLabel.copyWith(fontSize: 14, color: AppColours.inkBody),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final VoidCallback onAssign;
  final VoidCallback onComingSoon;

  const _ActionsRow({required this.onAssign, required this.onComingSoon});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: onAssign,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(t.assignAJobAction, overflow: TextOverflow.ellipsis),
              style: FilledButton.styleFrom(
                backgroundColor: AppColours.primaryColor,
                textStyle: AppTextStyles.buttonLabel.copyWith(fontSize: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: onComingSoon,
              icon: const Icon(Icons.call_outlined, size: 18),
              label: Text(t.callAction, overflow: TextOverflow.ellipsis),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColours.primaryDark,
                side: const BorderSide(color: AppColours.primaryTint, width: 1.5),
                textStyle: AppTextStyles.buttonLabel.copyWith(fontSize: 14, color: AppColours.primaryDark),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: onComingSoon,
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: Text(t.chatAction, overflow: TextOverflow.ellipsis),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColours.primaryDark,
                side: const BorderSide(color: AppColours.primaryTint, width: 1.5),
                textStyle: AppTextStyles.buttonLabel.copyWith(fontSize: 14, color: AppColours.primaryDark),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final ({int done, int returned, int? onTimePercent}) stats;

  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(child: _StatTile(value: '${stats.done}', label: t.doneThisMonthLabel)),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            value: stats.onTimePercent == null ? '—' : '${stats.onTimePercent}%',
            label: t.onTimeLabel,
            valueColor: AppColours.successIcon,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            value: '${stats.returned}',
            label: t.returnedLabel,
            valueColor: stats.returned > 0 ? AppColours.dangerText : null,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _StatTile({required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: valueColor ?? AppColours.ink),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
