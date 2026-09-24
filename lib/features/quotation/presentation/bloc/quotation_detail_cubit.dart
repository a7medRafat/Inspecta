import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../requests/domain/entities/inspection_request.dart';
import '../../../requests/domain/usecases/get_request_detail.dart';
import '../../domain/entities/client_response_outcome.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/entities/quotation_failure.dart';
import '../../domain/entities/quotation_status.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../../domain/usecases/log_client_response.dart';

part 'quotation_detail_state.dart';

/// The quote detail screen: a request's full version timeline, plus
/// logging the client's reply (BR-03.6/03.7). "Send reminder" lives on
/// the tracker's cards instead — it's a one-tap action, not something
/// that needs this screen open.
class QuotationDetailCubit extends Cubit<QuotationDetailState> {
  final String requestId;
  final QuotationRepository _repository;
  final LogClientResponse _logClientResponse;
  final GetRequestDetail _getRequestDetail;

  StreamSubscription<List<Quotation>>? _subscription;

  QuotationDetailCubit({
    required this.requestId,
    required QuotationRepository repository,
    required LogClientResponse logClientResponse,
    required GetRequestDetail getRequestDetail,
  }) : _repository = repository,
       _logClientResponse = logClientResponse,
       _getRequestDetail = getRequestDetail,
       super(const QuotationDetailState());

  void start() {
    if (_subscription != null) return;
    _subscription = _repository.watchForRequest(requestId).listen(
      (versions) => emit(state.copyWith(status: QuotationDetailStatus.ready, versions: versions)),
      onError: (Object error) => emit(
        state.copyWith(
          status: QuotationDetailStatus.error,
          failure: error is QuotationFailure ? error.code : QuotationFailureCode.unknown,
        ),
      ),
    );

    // Supplementary — the info card and "Request received" timeline step
    // degrade gracefully (just hide) if this fails or is slow, so it
    // isn't allowed to block the quotations themselves from showing.
    _getRequestDetail(requestId)
        .then((request) {
          if (!isClosed && request != null) emit(state.copyWith(request: request));
        })
        .catchError((_) {});
  }

  Future<void> logResponse({
    required ClientResponseOutcome outcome,
    int? clientPricePiastres,
    String? note,
  }) async {
    final quotation = state.current;
    if (quotation == null || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true));
    try {
      await _logClientResponse(
        quotationId: quotation.id,
        requestId: requestId,
        outcome: outcome,
        clientPricePiastres: clientPricePiastres,
        note: note,
      );
      _complete(success: true);
    } catch (e) {
      _complete(success: false, failure: e is QuotationFailure ? e.code : QuotationFailureCode.unknown);
    }
  }

  void _complete({required bool success, QuotationFailureCode? failure}) {
    if (isClosed) return;
    emit(
      state.copyWith(
        isSubmitting: false,
        actionSeq: state.actionSeq + 1,
        lastActionSuccess: success,
        lastActionFailure: failure,
        clearFailure: failure == null,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
