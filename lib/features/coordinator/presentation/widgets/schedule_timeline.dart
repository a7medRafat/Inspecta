import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../../requests/presentation/widgets/status_chip.dart';
import '../../domain/coordinator_consts.dart';

/// One inspector's tasks for the selected day, laid out as blocks on an
/// hour ruler (Feature 04 §5, scope-cut #1) — lets the coordinator spot
/// a gap or an overlap at a glance instead of reading times off a list.
class ScheduleTimeline extends StatelessWidget {
  final List<InspectionRequest> tasks;

  const ScheduleTimeline({super.key, required this.tasks});

  static const double _pixelsPerHour = 72;
  static const double _rowHeight = 64;

  double _offsetFor(DateTime time) {
    final startHour = CoordinatorConsts.scheduleStartHour;
    final endHour = CoordinatorConsts.scheduleEndHour;
    final hoursIn = (time.hour - startHour) + time.minute / 60;
    return hoursIn.clamp(0, (endHour - startHour).toDouble()) * _pixelsPerHour;
  }

  @override
  Widget build(BuildContext context) {
    final totalHours = CoordinatorConsts.scheduleEndHour - CoordinatorConsts.scheduleStartHour;
    final width = totalHours * _pixelsPerHour;
    final locale = Localizations.localeOf(context).languageCode;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width,
        height: _rowHeight,
        child: Stack(
          children: [
            const _HourRuler(pixelsPerHour: _pixelsPerHour, rowHeight: _rowHeight),
            for (final task in tasks)
              if (task.scheduledAt != null)
                Positioned(
                  left: _offsetFor(task.scheduledAt!),
                  top: 22,
                  width: math.min(
                    CoordinatorConsts.scheduleBlockHours * _pixelsPerHour,
                    width - _offsetFor(task.scheduledAt!),
                  ),
                  child: _TaskBlock(task: task, locale: locale),
                ),
          ],
        ),
      ),
    );
  }
}

class _HourRuler extends StatelessWidget {
  final double pixelsPerHour;
  final double rowHeight;

  const _HourRuler({required this.pixelsPerHour, required this.rowHeight});

  @override
  Widget build(BuildContext context) {
    final startHour = CoordinatorConsts.scheduleStartHour;
    final endHour = CoordinatorConsts.scheduleEndHour;
    return Row(
      children: [
        for (var hour = startHour; hour < endHour; hour++)
          Container(
            width: pixelsPerHour,
            height: rowHeight,
            padding: const EdgeInsets.only(left: 4, top: 2),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColours.border, width: 1)),
            ),
            child: Text('$hour:00', style: AppTextStyles.caption.copyWith(fontSize: 10)),
          ),
      ],
    );
  }
}

class _TaskBlock extends StatelessWidget {
  final InspectionRequest task;
  final String locale;

  const _TaskBlock({required this.task, required this.locale});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm', locale).format(task.scheduledAt!);
    return Container(
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: task.status.chipBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Text(
        '$time · ${task.equipmentTitle}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.badge.copyWith(fontSize: 11, color: task.status.chipText),
      ),
    );
  }
}
