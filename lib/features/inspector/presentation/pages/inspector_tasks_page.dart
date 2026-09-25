import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_layout.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/enums/job_status.dart';
import '../../../../core/framework/mtoast.dart';
import '../../../../core/shared/loading.dart';
import '../../../../core/shared/m_notice.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../certificate/presentation/pages/certificate_page.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../../requests/domain/entities/requests_failure.dart';
import '../../../requests/presentation/widgets/requests_labels.dart';
import '../bloc/inspector_tasks_cubit.dart';
import '../widgets/decline_task_dialog.dart';
import '../widgets/inspector_task_card.dart';
import '../widgets/inspector_tasks_header.dart';
import '../widgets/new_task_banner.dart';

/// Feature 05's Tasks tab: a day strip, a nudge toward any job the
/// inspector hasn't responded to yet, and that day's task cards.
class InspectorTasksPage extends StatelessWidget {
  const InspectorTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InspectorTasksCubit>()..start(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColours.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const InspectorTasksHeader(),
                const Expanded(child: _Body()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final Map<String, GlobalKey> _cardKeys = {};

  GlobalKey _keyFor(String requestId) => _cardKeys.putIfAbsent(requestId, GlobalKey.new);

  Future<void> _openInMaps(InspectionRequest task) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(task.location)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _decline(InspectionRequest task) async {
    final cubit = context.read<InspectorTasksCubit>();
    final reason = await showDeclineTaskDialog(context);
    if (reason == null) return;
    await cubit.decline(task.id, reason: reason.isEmpty ? null : reason);
  }

  void _continueCertificate(InspectionRequest task) {
    if (task.status == JobStatus.taskAccepted) {
      context.read<InspectorTasksCubit>().startInspection(task.id);
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => CertificatePage(request: task)),
    );
  }

  void _openFirstNeedsResponse(InspectorTasksState state) {
    final task = state.firstNeedsResponse;
    if (task == null) return;
    final targetContext = _cardKeys[task.id]?.currentContext;
    if (targetContext == null) return;
    Scrollable.ensureVisible(targetContext, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocConsumer<InspectorTasksCubit, InspectorTasksState>(
      listenWhen: (previous, current) => current.actionSeq != previous.actionSeq,
      listener: (context, state) {
        if (state.lastActionSuccess) {
          final message = switch (state.lastAction) {
            InspectorTaskAction.accept => t.taskAcceptedMessage,
            InspectorTaskAction.decline => t.taskDeclinedMessage,
            _ => null,
          };
          if (message != null) MToast.showSuccess(message: message);
        } else if (state.lastActionFailure != null) {
          MToast.showError(message: state.lastActionFailure!.message(t));
        }
      },
      builder: (context, state) {
        if (state.status == InspectorTasksStatus.loading) {
          return Loading.loader(context);
        }
        if (state.status == InspectorTasksStatus.error) {
          return _ErrorState(failure: state.failure!);
        }

        final tasks = state.tasksForSelectedDate;
        final banner = state.firstNeedsResponse;
        final cubit = context.read<InspectorTasksCubit>();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, AppLayout.bottomNavClearance),
          children: [
            if (banner != null) ...[
              NewTaskBanner(onOpen: () => _openFirstNeedsResponse(state)),
              const SizedBox(height: 14),
            ],
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(t.emptyTasksForDay, style: AppTextStyles.subtitle),
                ),
              )
            else
              for (var i = 0; i < tasks.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                KeyedSubtree(
                  key: _keyFor(tasks[i].id),
                  child: InspectorTaskCard(
                    task: tasks[i],
                    submitting: state.isSubmitting,
                    onAccept: () => cubit.accept(tasks[i].id),
                    onDecline: () => _decline(tasks[i]),
                    onContinueCertificate: () => _continueCertificate(tasks[i]),
                    onNavigate: () => _openInMaps(tasks[i]),
                  ),
                ),
              ],
          ],
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
              onPressed: context.read<InspectorTasksCubit>().retry,
              child: Text(t.retry),
            ),
          ],
        ),
      ),
    );
  }
}
