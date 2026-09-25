import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/widgets/auth_labels.dart';
import '../bloc/inspector_tasks_cubit.dart';
import 'day_strip.dart';

/// The Tasks tab's blue header: avatar, a live task count for the
/// selected day, a (visual-only) notifications bell, and the day strip
/// — the selected day always in the middle (Feature 05).
class InspectorTasksHeader extends StatelessWidget {
  const InspectorTasksHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = context.select((AuthCubit cubit) => cubit.user);
    if (user == null) return const SizedBox.shrink();

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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Text(
                  user.initials,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColours.primaryDark),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.role.label(t),
                      style: AppTextStyles.caption.copyWith(color: AppColours.onPrimaryMuted),
                    ),
                    BlocBuilder<InspectorTasksCubit, InspectorTasksState>(
                      buildWhen: (previous, current) =>
                          previous.tasksForSelectedDate.length != current.tasksForSelectedDate.length ||
                          previous.selectedDate != current.selectedDate,
                      builder: (context, state) {
                        final count = state.tasksForSelectedDate.length;
                        final title = state.isToday
                            ? t.tasksTodayTitle(count)
                            : t.tasksOnDayTitle(
                                count,
                                DateFormat('EEE, d MMM', Localizations.localeOf(context).languageCode)
                                    .format(state.selectedDate),
                              );
                        return Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.emphasis.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        );
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: null,
                tooltip: t.notifications,
                style: IconButton.styleFrom(
                  fixedSize: const Size.square(44),
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.16),
                ),
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _DayStrip(),
        ],
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InspectorTasksCubit, InspectorTasksState>(
      builder: (context, state) {
        final cubit = context.read<InspectorTasksCubit>();
        return DayStrip(
          weekDates: state.weekDates,
          selectedDate: state.selectedDate,
          hasIndicator: (day) => state.taskCountFor(day) > 0,
          onSelectDate: cubit.selectDate,
        );
      },
    );
  }
}
