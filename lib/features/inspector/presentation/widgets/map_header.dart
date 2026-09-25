import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/route_estimate.dart';
import '../bloc/inspector_tasks_cubit.dart';
import 'day_strip.dart';

/// The Map tab's header: the day switcher and, once stops are geocoded,
/// a rough distance/drive-time line (Feature 05).
class MapHeader extends StatelessWidget {
  final RouteEstimate? route;

  const MapHeader({super.key, required this.route});

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.navMap, style: AppTextStyles.pageTitle.copyWith(color: Colors.white, fontSize: 24)),
              if (route != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.routeSummaryLabel(route!.distanceKm.toStringAsFixed(1), route!.minutes),
                      style: AppTextStyles.emphasis.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      t.routeEstimateCaption,
                      textAlign: TextAlign.end,
                      style: AppTextStyles.caption.copyWith(color: AppColours.onPrimaryMuted, fontSize: 10),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 18),
          BlocBuilder<InspectorTasksCubit, InspectorTasksState>(
            builder: (context, state) {
              final cubit = context.read<InspectorTasksCubit>();
              return DayStrip(
                weekDates: state.weekDates,
                selectedDate: state.selectedDate,
                hasIndicator: (day) => state.taskCountFor(day) > 0,
                onSelectDate: cubit.selectDate,
              );
            },
          ),
        ],
      ),
    );
  }
}
