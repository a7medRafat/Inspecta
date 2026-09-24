import 'quotation.dart';
import 'quotation_status.dart';
import 'reply_type.dart';

/// The Quotations tracker's four tabs. Only *sent* quotations appear on
/// the board at all — a draft is still work-in-progress and shows on the
/// Requests tab instead (via the request's own `quote_draft` status).
enum QuoteBoardTab { replied, open, accepted, lost }

extension QuoteBoardTabX on QuoteBoardTab {
  static QuoteBoardTab? of(Quotation q, {DateTime? now}) {
    // A rejection is always terminal, regardless of its stored status.
    if (q.type == ReplyType.reject) return QuoteBoardTab.lost;

    return switch (q.status) {
      QuotationStatus.draft || QuotationStatus.superseded => null,
      QuotationStatus.accepted => QuoteBoardTab.accepted,
      QuotationStatus.declined => QuoteBoardTab.lost,
      QuotationStatus.expired => QuoteBoardTab.lost,
      QuotationStatus.countered => QuoteBoardTab.replied,
      QuotationStatus.sent => q.isExpired(now: now) ? QuoteBoardTab.lost : QuoteBoardTab.open,
    };
  }
}
