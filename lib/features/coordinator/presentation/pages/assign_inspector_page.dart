import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/framework/mtoast.dart';
import '../../../../core/shared/loading.dart';
import '../../../../core/shared/m_back_button.dart';
import '../../../../core/shared/m_notice.dart';
import '../../../../core/shared/m_primary_button.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../bloc/assign_inspector_cubit.dart';
import '../widgets/coordinator_labels.dart';
import '../widgets/inspector_option_tile.dart';

/// Feature 04 §5's "Assign inspector" screen: pick a time slot, choose an
/// inspector, and submit — the only way to move a job from
/// [InspectionRequest.isReadyToAssign] to [JobStatus.assigned].
class AssignInspectorPage extends StatelessWidget {
  final InspectionRequest request;
  final String? preselectedInspectorId;

  const AssignInspectorPage({super.key, required this.request, this.preselectedInspectorId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AssignInspectorCubit>(param1: request, param2: preselectedInspectorId)..start(),
      child: Scaffold(
        backgroundColor: AppColours.background,
        body: SafeArea(
          child: Column(
            children: [
              _Header(request: request),
              Expanded(child: _Body(request: request)),
              _Footer(request: request),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final InspectionRequest request;

  const _Header({required this.request});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColours.border)),
      ),
      child: Row(
        children: [
          const MBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  request.id,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColours.inkMuted),
                ),
                Text(
                  t.assignInspectorTitle,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final InspectionRequest request;

  const _Body({required this.request});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final categories = request.items
        .map((item) => item.category)
        .whereType<String>()
        .where((c) => c.isNotEmpty)
        .toSet();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColours.primarySoft, borderRadius: BorderRadius.circular(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                request.equipmentTitle,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 16, color: AppColours.primaryDark),
              ),
              const SizedBox(height: 4),
              Text('${request.clientName} · ${request.location}', style: AppTextStyles.body.copyWith(fontSize: 14)),
              if (categories.isNotEmpty || request.preferredDate != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final category in categories) _Tag(label: category, color: AppColours.primaryDark),
                    if (request.preferredDate != null)
                      _Tag(label: request.preferredDate!.dueLabel(t), color: AppColours.chipAmberTextStrong),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(t.pickTimeStepLabel, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
        const SizedBox(height: 10),
        BlocBuilder<AssignInspectorCubit, AssignInspectorState>(
          buildWhen: (previous, current) => previous.scheduledAt != current.scheduledAt,
          builder: (context, state) {
            final cubit = context.read<AssignInspectorCubit>();
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _PickerField(
                    label: t.dateLabel,
                    value: DateFormat(
                      'EEE, d MMM yyyy',
                      Localizations.localeOf(context).languageCode,
                    ).format(state.scheduledAt),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.scheduledAt,
                        // Wide enough to always include the initial date —
                        // a request's preferred date can already be in the
                        // past (an overdue job still needs assigning).
                        firstDate: DateTime(DateTime.now().year - 1),
                        lastDate: DateTime(DateTime.now().year + 2),
                      );
                      if (picked != null) cubit.changeDate(picked);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PickerField(
                    label: t.startTimeLabel,
                    value: DateFormat(
                      'HH:mm',
                      Localizations.localeOf(context).languageCode,
                    ).format(state.scheduledAt),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(state.scheduledAt),
                      );
                      if (picked != null) cubit.changeTime(picked.hour, picked.minute);
                    },
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Text(t.chooseInspectorStepLabel, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
        const SizedBox(height: 10),
        BlocBuilder<AssignInspectorCubit, AssignInspectorState>(
          builder: (context, state) {
            final cubit = context.read<AssignInspectorCubit>();
            if (state.inspectorsStatus == InspectorsStatus.loading) {
              return Loading.loader(context);
            }
            if (state.inspectorsStatus == InspectorsStatus.error) {
              return MNotice(type: MNoticeType.error, message: state.inspectorsFailure!.message(t));
            }
            if (state.inspectors.isEmpty) {
              return MNotice(type: MNoticeType.info, message: t.emptyInspectors);
            }
            return Column(
              children: [
                for (var i = 0; i < state.inspectors.length; i++) ...[
                  InspectorOptionTile(
                    inspector: state.inspectors[i],
                    selected: state.inspectors[i].id == state.selectedInspectorId,
                    isBestMatch: state.matchedInspectorIds.contains(state.inspectors[i].id),
                    onTap: () => cubit.selectInspector(state.inspectors[i].id),
                  ),
                  if (i < state.inspectors.length - 1) const SizedBox(height: 10),
                ],
                if (state.submitted && state.selectedInspectorId == null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(t.errorInspectorRequired, style: AppTextStyles.caption.copyWith(color: AppColours.dangerText)),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Text(t.assignNotesLabel, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
        const SizedBox(height: 10),
        TextField(
          onChanged: context.read<AssignInspectorCubit>().changeNote,
          maxLines: 2,
          style: AppTextStyles.input.copyWith(fontWeight: FontWeight.w400, fontSize: 15),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColours.border, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: AppTextStyles.badge.copyWith(fontSize: 12, color: color)),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.fieldLabel.copyWith(fontSize: 13)),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: AlignmentDirectional.centerStart,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColours.border, width: 1.5),
            ),
            child: Text(value, style: AppTextStyles.input.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  final InspectionRequest request;

  const _Footer({required this.request});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColours.border)),
      ),
      child: BlocConsumer<AssignInspectorCubit, AssignInspectorState>(
        listenWhen: (previous, current) => current.actionSeq != previous.actionSeq,
        listener: (context, state) {
          if (state.lastActionSuccess) {
            MToast.showSuccess(message: t.assignmentSuccessMessage);
            Navigator.of(context).pop();
          } else {
            MToast.showError(message: state.lastActionFailure!.message(t));
          }
        },
        builder: (context, state) {
          final cubit = context.read<AssignInspectorCubit>();
          final name = state.selectedInspector?.name.split(' ').first;
          return MPrimaryButton(
            label: name == null ? t.assignInspectorAction : t.assignAndNotifyAction(name),
            loading: state.isSubmitting,
            onPressed: cubit.submit,
          );
        },
      ),
    );
  }
}
