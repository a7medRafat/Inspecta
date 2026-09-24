import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/currency.dart';
import '../../../requests/domain/entities/inspection_request.dart';
import '../../../requests/domain/entities/requests_failure.dart';
import '../../domain/entities/quotation_failure.dart';
import '../../domain/entities/quote_line_item.dart';
import '../../domain/entities/reply_type.dart';
import '../../domain/usecases/save_draft.dart';
import '../../domain/usecases/send_quotation.dart';

part 'quotation_form_state.dart';

/// The reply panel on a request's detail screen (Feature 03 §5): reply
/// type, price, validity, message, their validation, and actually
/// saving/sending them — including reject, which now goes through the
/// same [SendQuotation] path so the Quotations tracker has a full
/// history of every reply sent.
///
/// Known gaps: Accept has no real price (no price list backend, US-03's
/// open question #1), an offer prices every item at the same per-unit
/// rate (the UI has one price field, not one per item), there's no VAT
/// line, and nothing here emails the client a PDF (BR-03.5) — that needs
/// a backend job this client can't perform.
class QuotationFormCubit extends Cubit<QuotationFormState> {
  final InspectionRequest request;
  final SaveDraft _saveDraft;
  final SendQuotation _sendQuotation;

  QuotationFormCubit({
    required this.request,
    required SaveDraft saveDraft,
    required SendQuotation sendQuotation,
  }) : _saveDraft = saveDraft,
       _sendQuotation = sendQuotation,
       super(const QuotationFormState());

  int? get totalPiastres {
    final unitPrice = state.unitPricePiastres;
    if (unitPrice == null) return null;
    final totalUnits = request.items.fold<int>(0, (sum, item) => sum + item.quantity);
    return unitPrice * totalUnits;
  }

  /// "Overhead crane × 2", or each item type joined when there's more
  /// than one — shown on the Quotations tracker's cards.
  String get _equipmentSummary {
    if (request.items.isEmpty) return request.equipmentTitle;
    return request.items.map((item) => '${item.type} × ${item.quantity}').join(', ');
  }

  void selectReplyType(ReplyType type) {
    emit(state.copyWith(replyType: type, submitted: false, clearFailure: true));
  }

  void changePrice(String value) => emit(state.copyWith(priceText: value));

  void changeValidity(int days) => emit(state.copyWith(validityDays: days));

  void changeMessage(String value) => emit(state.copyWith(message: value));

  /// Every item priced at the same entered rate (see the class doc's
  /// gaps list).
  List<QuoteLineItem> _priceAllItems(int unitPricePiastres) {
    return request.items
        .map(
          (item) => QuoteLineItem(
            requestItemId: item.id,
            type: item.type,
            quantity: item.quantity,
            unitPricePiastres: unitPricePiastres,
          ),
        )
        .toList();
  }

  /// US-03.4: not available once Reject is chosen — there's nothing
  /// meaningful to draft.
  Future<void> saveDraft() async {
    if (state.replyType == null || state.replyType == ReplyType.reject) return;
    if (state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true));
    try {
      await _saveDraft(
        requestId: request.id,
        requestNumber: request.id,
        clientName: request.clientName,
        equipmentSummary: _equipmentSummary,
        type: state.replyType!,
        items: state.replyType == ReplyType.offer
            ? _priceAllItems(state.unitPricePiastres ?? 0)
            : _priceAllItems(0),
        validityDays: state.replyType == ReplyType.offer ? state.validityDays : null,
        message: state.message,
      );
      _completeAction(QuotationAction.saveDraft, success: true);
    } catch (e) {
      _completeAction(QuotationAction.saveDraft, success: false, failure: _mapFailure(e));
    }
  }

  /// BR-03.5/BR-03.8: validates first (acceptance criterion 2), then
  /// sends — accept/offer/reject alike.
  Future<void> send() async {
    if (state.isSubmitting) return;
    if (!validate()) return;

    emit(state.copyWith(isSubmitting: true));
    try {
      final version = await _sendQuotation(
        requestId: request.id,
        requestNumber: request.id,
        clientName: request.clientName,
        equipmentSummary: _equipmentSummary,
        type: state.replyType!,
        items: state.replyType == ReplyType.offer
            ? _priceAllItems(state.unitPricePiastres ?? 0)
            : _priceAllItems(0),
        validityDays: state.replyType == ReplyType.offer ? state.validityDays : null,
        message: state.message,
      );
      emit(state.copyWith(sentVersion: version));
      _completeAction(QuotationAction.send, success: true);
    } catch (e) {
      _completeAction(QuotationAction.send, success: false, failure: _mapFailure(e));
    }
  }

  /// [_saveDraft]/[_sendQuotation] throw [QuotationFailure]; a reject
  /// send also touches the requests collection and can throw
  /// [RequestsFailure]. Both map onto the same failure codes for display.
  QuotationFailureCode _mapFailure(Object error) {
    if (error is QuotationFailure) return error.code;
    if (error is RequestsFailure) {
      return switch (error.code) {
        RequestsFailureCode.permissionDenied => QuotationFailureCode.permissionDenied,
        RequestsFailureCode.network => QuotationFailureCode.network,
        RequestsFailureCode.unknown => QuotationFailureCode.unknown,
      };
    }
    return QuotationFailureCode.unknown;
  }

  void _completeAction(
    QuotationAction action, {
    required bool success,
    QuotationFailureCode? failure,
  }) {
    if (isClosed) return;
    emit(
      state.copyWith(
        isSubmitting: false,
        actionSeq: state.actionSeq + 1,
        lastAction: action,
        lastActionSuccess: success,
        lastActionFailure: failure,
        clearFailure: failure == null,
      ),
    );
  }

  /// Flips on field errors (acceptance criterion 2) and reports whether
  /// the form may be sent.
  bool validate() {
    if (!state.submitted) emit(state.copyWith(submitted: true));
    return state.isValid;
  }
}
