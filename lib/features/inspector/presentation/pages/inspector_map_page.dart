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
import '../../domain/geocoding_service.dart';
import '../../domain/route_estimate.dart';
import '../bloc/inspector_tasks_cubit.dart';
import '../widgets/decline_task_dialog.dart';
import '../widgets/map_header.dart';
import '../widgets/map_stop_card.dart';

/// Feature 05's Map tab: the day's stops in visit order, a rough
/// distance/drive-time line, and a "Directions" handoff per stop —
/// a list view (no map tiles/pins yet; see the feature's scope-cuts).
class InspectorMapPage extends StatelessWidget {
  const InspectorMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InspectorTasksCubit>()..start(),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView();

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  final GeocodingService _geocoding = getIt<GeocodingService>();

  List<InspectionRequest> _lastStops = const [];
  RouteEstimate? _route;
  int _lastToastedActionSeq = 0;

  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  List<InspectionRequest> _stopsFor(InspectorTasksState state) {
    final stops = state.requests.where((r) {
      final at = r.scheduledAt;
      return at != null && _sameDay(at, state.selectedDate);
    }).toList()
      ..sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));
    return stops;
  }

  bool _sameStopOrder(List<InspectionRequest> stops) {
    if (stops.length != _lastStops.length) return false;
    for (var i = 0; i < stops.length; i++) {
      if (stops[i].id != _lastStops[i].id) return false;
    }
    return true;
  }

  Future<void> _recomputeRoute(List<InspectionRequest> stops) async {
    if (_sameStopOrder(stops)) return;
    _lastStops = stops;
    final coordinates = [for (final stop in stops) await _geocoding.geocode(stop.location)];
    if (!mounted || !_sameStopOrder(stops)) return;
    setState(() => _route = estimateRoute(coordinates));
  }

  Future<void> _openDirections(InspectionRequest stop) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(stop.location)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _decline(InspectionRequest stop) async {
    final cubit = context.read<InspectorTasksCubit>();
    final reason = await showDeclineTaskDialog(context);
    if (reason == null) return;
    await cubit.decline(stop.id, reason: reason.isEmpty ? null : reason);
  }

  void _continueCertificate(InspectionRequest stop) {
    if (stop.status == JobStatus.taskAccepted) {
      context.read<InspectorTasksCubit>().startInspection(stop.id);
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => CertificatePage(request: stop)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColours.background,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<InspectorTasksCubit, InspectorTasksState>(
            // `builder` must stay a pure function of state — it runs
            // synchronously nested inside this widget's own build, so
            // triggering `_recomputeRoute` (and its `setState`) from
            // there crashes whenever the geocode loop has nothing to
            // await (e.g. a day with zero stops) and completes before
            // ever yielding. Side effects belong in `listener`, whose
            // callback runs from the cubit's own emit, not from a build.
            listenWhen: (previous, current) =>
                current.actionSeq != previous.actionSeq ||
                previous.requests != current.requests ||
                previous.selectedDate != current.selectedDate,
            listener: (context, state) {
              if (state.actionSeq != _lastToastedActionSeq) {
                _lastToastedActionSeq = state.actionSeq;
                if (!state.lastActionSuccess && state.lastActionFailure != null) {
                  MToast.showError(message: state.lastActionFailure!.message(t));
                }
              }
              if (state.status == InspectorTasksStatus.ready) {
                _recomputeRoute(_stopsFor(state));
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  MapHeader(route: _route),
                  Expanded(
                    child: switch (state.status) {
                      InspectorTasksStatus.loading => Loading.loader(context),
                      InspectorTasksStatus.error => _ErrorState(failure: state.failure!),
                      InspectorTasksStatus.ready => _StopsList(
                        stops: _stopsFor(state),
                        isSubmitting: state.isSubmitting,
                        onAccept: (stop) => context.read<InspectorTasksCubit>().accept(stop.id),
                        onDecline: _decline,
                        onContinueCertificate: _continueCertificate,
                        onDirections: _openDirections,
                      ),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StopsList extends StatelessWidget {
  final List<InspectionRequest> stops;
  final bool isSubmitting;
  final ValueChanged<InspectionRequest> onAccept;
  final ValueChanged<InspectionRequest> onDecline;
  final ValueChanged<InspectionRequest> onContinueCertificate;
  final ValueChanged<InspectionRequest> onDirections;

  const _StopsList({
    required this.stops,
    required this.isSubmitting,
    required this.onAccept,
    required this.onDecline,
    required this.onContinueCertificate,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (stops.isEmpty) {
      return Center(child: Text(t.emptyTasksForDay, style: AppTextStyles.subtitle));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, AppLayout.bottomNavClearance),
      itemCount: stops.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final stop = stops[index];
        return MapStopCard(
          key: ValueKey(stop.id),
          order: index + 1,
          stop: stop,
          submitting: isSubmitting,
          onAccept: () => onAccept(stop),
          onDecline: () => onDecline(stop),
          onContinueCertificate: () => onContinueCertificate(stop),
          onDirections: () => onDirections(stop),
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
