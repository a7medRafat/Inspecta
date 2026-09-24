import '../../../../core/enums/job_status.dart';
import '../../../requests/domain/repositories/requests_repository.dart';
import '../entities/client_response_outcome.dart';
import '../repositories/quotation_repository.dart';

/// BR-03.6/03.7: logs how the client answered a sent quotation, and
/// moves the request accordingly. An `accepted` outcome also supersedes
/// every other quotation on the request (BR-03.7: the agreed price is
/// locked to this one version).
class LogClientResponse {
  final QuotationRepository _quotations;
  final RequestsRepository _requests;

  const LogClientResponse(this._quotations, this._requests);

  Future<void> call({
    required String quotationId,
    required String requestId,
    required ClientResponseOutcome outcome,
    int? clientPricePiastres,
    String? note,
  }) async {
    await _quotations.recordClientResponse(
      quotationId: quotationId,
      requestId: requestId,
      outcome: outcome,
      clientPricePiastres: clientPricePiastres,
      note: note?.trim(),
    );

    final status = switch (outcome) {
      ClientResponseOutcome.counter => JobStatus.clientCountered,
      ClientResponseOutcome.accepted => JobStatus.quoteAccepted,
      ClientResponseOutcome.declined => JobStatus.clientDeclined,
    };
    await _requests.updateStatus(requestId, status, note: note);
  }
}
