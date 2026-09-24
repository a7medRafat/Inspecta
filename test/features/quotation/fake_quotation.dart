import 'package:inspecta/features/quotation/domain/entities/client_response_outcome.dart';
import 'package:inspecta/features/quotation/domain/entities/quotation.dart';
import 'package:inspecta/features/quotation/domain/entities/quotation_status.dart';
import 'package:inspecta/features/quotation/domain/entities/reply_type.dart';

Quotation sampleQuotation({
  String id = 'q1',
  String requestId = 'REQ-1',
  String requestNumber = 'REQ-1',
  String clientName = 'Delta Steel Co.',
  String equipmentSummary = 'Overhead crane × 2',
  int? version = 1,
  ReplyType type = ReplyType.offer,
  QuotationStatus status = QuotationStatus.sent,
  int? totalPiastres = 900000,
  DateTime? validUntil,
  DateTime? sentAt,
  DateTime? createdAt,
  ClientResponseOutcome? clientResponseOutcome,
  int? clientCounterPricePiastres,
  DateTime? clientRespondedAt,
}) {
  final now = DateTime.now();
  return Quotation(
    id: id,
    requestId: requestId,
    requestNumber: requestNumber,
    clientName: clientName,
    equipmentSummary: equipmentSummary,
    version: version,
    type: type,
    items: const [],
    status: status,
    createdBy: 'u1',
    createdAt: createdAt ?? now,
    totalPiastres: totalPiastres,
    validUntil: validUntil,
    sentAt: sentAt ?? now,
    clientResponseOutcome: clientResponseOutcome,
    clientCounterPricePiastres: clientCounterPricePiastres,
    clientRespondedAt: clientRespondedAt,
  );
}
