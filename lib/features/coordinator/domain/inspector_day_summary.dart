import '../../../core/enums/job_status.dart';
import '../../auth/domain/entities/user.dart';
import '../../requests/domain/entities/inspection_request.dart';

enum InspectorAvailability { free, busy, onLeave }

/// An inspector's today, derived from their jobs — the roster card's
/// "Busy"/"Free"/"On leave" badge, slot count, and "Now / Next" line
/// (Feature 04 §5).
class InspectorDaySummary {
  final InspectorAvailability availability;
  final int todaySlots;
  final InspectionRequest? nowTask;
  final InspectionRequest? nextTask;

  const InspectorDaySummary({
    required this.availability,
    required this.todaySlots,
    this.nowTask,
    this.nextTask,
  });

  factory InspectorDaySummary.compute(
    AppUser inspector,
    List<InspectionRequest> requests, {
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    if (inspector.isOnLeave(now: today)) {
      return const InspectorDaySummary(availability: InspectorAvailability.onLeave, todaySlots: 0);
    }

    final todays = requests
        .where((r) => r.inspectorId == inspector.id && r.scheduledAt != null && _isSameDay(r.scheduledAt!, today))
        .toList()
      ..sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));

    InspectionRequest? nowTask;
    for (final r in todays) {
      if (r.status == JobStatus.inProgress) {
        nowTask = r;
        break;
      }
    }

    InspectionRequest? nextTask;
    if (nowTask != null) {
      for (final r in todays) {
        if (r.scheduledAt!.isAfter(nowTask.scheduledAt!)) {
          nextTask = r;
          break;
        }
      }
    }

    return InspectorDaySummary(
      availability: nowTask != null ? InspectorAvailability.busy : InspectorAvailability.free,
      todaySlots: todays.length,
      nowTask: nowTask,
      nextTask: nextTask,
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
