import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_layout.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/loading.dart';
import '../../../../core/shared/m_notice.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../requests/domain/entities/requests_failure.dart';
import '../../../requests/presentation/widgets/requests_labels.dart';
import '../bloc/schedule_cubit.dart';
import '../widgets/schedule_header.dart';
import '../widgets/schedule_inspector_row.dart';
import 'inspector_detail_page.dart';

/// Feature 04 §5's Schedule tab (scope-cut #1): a day view, one row per
/// inspector, their tasks for that day as blocks on a timeline, and a
/// date picker to move between days. Drag-and-drop rescheduling and a
/// week view are left for later.
class CoordinatorSchedulePage extends StatelessWidget {
  const CoordinatorSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ScheduleCubit>()..start(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColours.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const ScheduleHeader(),
                const Expanded(child: _Body()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        if (state.status == ScheduleStatus.loading) {
          return Loading.loader(context);
        }
        if (state.status == ScheduleStatus.error) {
          return _ErrorState(failure: state.failure!);
        }

        final inspectors = state.activeInspectors;
        if (inspectors.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(t.scheduleEmptyRoster, textAlign: TextAlign.center, style: AppTextStyles.subtitle),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, AppLayout.bottomNavClearance),
          itemCount: inspectors.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final inspector = inspectors[index];
            return ScheduleInspectorRow(
              key: ValueKey(inspector.id),
              inspector: inspector,
              tasks: state.tasksFor(inspector.id),
              onLeave: state.isOnLeave(inspector),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => InspectorDetailPage(inspector: inspector)),
              ),
            );
          },
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final RequestsFailureCode failure;

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
            OutlinedButton(
              onPressed: context.read<ScheduleCubit>().retry,
              child: Text(t.retry),
            ),
          ],
        ),
      ),
    );
  }
}
