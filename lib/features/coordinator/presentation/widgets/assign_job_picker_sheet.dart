import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/loading.dart';
import '../../../../core/shared/m_notice.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../bloc/coordinator_queue_cubit.dart';

/// "+ Assign a job" on an inspector's detail screen: picks which
/// ready-to-assign job to send them to next, then hands it back so the
/// caller can open [AssignInspectorPage] with this inspector preselected.
class AssignJobPickerSheet extends StatelessWidget {
  const AssignJobPickerSheet({super.key});

  static Future<InspectionRequest?> show(BuildContext context) {
    return showModalBottomSheet<InspectionRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AssignJobPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => getIt<CoordinatorQueueCubit>()..start(),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColours.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Text(t.pickJobToAssignTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
                ],
              ),
            ),
            Flexible(
              child: BlocBuilder<CoordinatorQueueCubit, CoordinatorQueueState>(
                builder: (context, state) {
                  if (state.status == CoordinatorQueueStatus.loading) {
                    return Padding(padding: const EdgeInsets.all(24), child: Loading.loader(context));
                  }
                  final jobs = state.readyToAssign;
                  if (jobs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: MNotice(type: MNoticeType.info, message: t.emptyCoordinatorQueue),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: jobs.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: AppColours.surfaceMuted),
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(job.equipmentTitle, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
                        subtitle: Text('${job.clientName} · ${job.location}', style: AppTextStyles.subtitle),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColours.inkMuted),
                        onTap: () => Navigator.of(context).pop(job),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
