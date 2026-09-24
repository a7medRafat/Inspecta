import '../../../../core/enums/job_status.dart';
import '../entities/inspection_request.dart';

/// Methods emit / throw [RequestsFailure] on expected errors.
abstract interface class RequestsRepository {
  /// The shared requests inbox (BR-02.1), newest first. Every supervisor
  /// sees every request — there's no per-supervisor split.
  Stream<List<InspectionRequest>> watchRequests();

  /// A single request, or `null` if it doesn't exist (or its status isn't
  /// one the app understands). Used when a screen only has a request's id
  /// (e.g. opening it from the quotations list).
  Future<InspectionRequest?> getById(String id);

  /// Moves a request to [status] and appends a `JobEvent` to its history
  /// (00-overview.md §7/§8: every status change is logged).
  Future<void> updateStatus(String requestId, JobStatus status, {String? note});

  /// BR-03.8: rejects the request with a reason, closing it.
  Future<void> rejectRequest({required String requestId, required String reason});

  /// BR-02.4: matches an unmatched sender to a known client.
  Future<void> assignClient(String requestId, String clientId);
}
