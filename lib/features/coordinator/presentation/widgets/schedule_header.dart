import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/schedule_cubit.dart';

/// The Schedule tab's blue header: the day picker and two roster tiles
/// for the selected day (Feature 04 §5, scope-cut #1).
class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 24, 20, 22),
      decoration: const BoxDecoration(
        color: AppColours.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.navSchedule, style: AppTextStyles.pageTitle.copyWith(color: Colors.white, fontSize: 26)),
          const SizedBox(height: 16),
          const _DateNav(),
          const SizedBox(height: 18),
          BlocBuilder<ScheduleCubit, ScheduleState>(
            buildWhen: (previous, current) =>
                previous.totalTasksOnDate != current.totalTasksOnDate ||
                previous.onLeaveCountOnDate != current.onLeaveCountOnDate,
            builder: (context, state) {
              return Row(
                children: [
                  Expanded(
                    child: _StatTile(value: state.totalTasksOnDate, label: t.statScheduled, emphasised: true),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _StatTile(value: state.onLeaveCountOnDate, label: t.statOnLeave)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DateNav extends StatelessWidget {
  const _DateNav();

  Future<void> _pickDate(BuildContext context) async {
    final cubit = context.read<ScheduleCubit>();
    final picked = await showDatePicker(
      context: context,
      initialDate: cubit.state.selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked != null) cubit.selectDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cubit = context.read<ScheduleCubit>();

    return BlocBuilder<ScheduleCubit, ScheduleState>(
      buildWhen: (previous, current) => previous.selectedDate != current.selectedDate,
      builder: (context, state) {
        final locale = Localizations.localeOf(context).languageCode;
        final label = DateFormat('EEE, d MMM', locale).format(state.selectedDate);

        return Row(
          children: [
            _NavIconButton(icon: Icons.chevron_left_rounded, tooltip: t.previousDayTooltip, onTap: cubit.goToPreviousDay),
            Expanded(
              child: GestureDetector(
                onTap: () => _pickDate(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: AppTextStyles.emphasis.copyWith(color: Colors.white, fontSize: 16)),
                    if (!state.isToday)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: GestureDetector(
                          onTap: cubit.goToToday,
                          child: Text(
                            t.todayLabel,
                            style: AppTextStyles.link.copyWith(color: AppColours.amberOnPrimary, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _NavIconButton(icon: Icons.chevron_right_rounded, tooltip: t.nextDayTooltip, onTap: cubit.goToNextDay),
          ],
        );
      },
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _NavIconButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(40),
        backgroundColor: Colors.white.withValues(alpha: 0.16),
      ),
      icon: Icon(icon, color: Colors.white),
    );
  }
}

class _StatTile extends StatelessWidget {
  final int value;
  final String label;
  final bool emphasised;

  const _StatTile({required this.value, required this.label, this.emphasised = false});

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
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: emphasised ? AppColours.chipAmberTextStrong : Colors.white,
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
