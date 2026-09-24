import 'package:flutter_test/flutter_test.dart';
import 'package:inspecta/features/quotation/domain/entities/client_response_outcome.dart';
import 'package:inspecta/features/quotation/domain/entities/quotation_status.dart';
import 'package:inspecta/features/quotation/domain/entities/quote_board_tab.dart';
import 'package:inspecta/features/quotation/domain/entities/reply_type.dart';

import 'fake_quotation.dart';

void main() {
  group('QuoteBoardTabX.of', () {
    test('a reject is always Lost, regardless of status', () {
      final q = sampleQuotation(type: ReplyType.reject, status: QuotationStatus.sent);
      expect(QuoteBoardTabX.of(q), QuoteBoardTab.lost);
    });

    test('drafts and superseded versions have no board tab', () {
      expect(
        QuoteBoardTabX.of(sampleQuotation(status: QuotationStatus.draft)),
        isNull,
      );
      expect(
        QuoteBoardTabX.of(sampleQuotation(status: QuotationStatus.superseded)),
        isNull,
      );
    });

    test('sent is Open, unless past its validUntil, then Lost', () {
      final now = DateTime(2026, 1, 10);
      final open = sampleQuotation(
        status: QuotationStatus.sent,
        validUntil: DateTime(2026, 1, 20),
      );
      final expired = sampleQuotation(
        status: QuotationStatus.sent,
        validUntil: DateTime(2026, 1, 1),
      );
      expect(QuoteBoardTabX.of(open, now: now), QuoteBoardTab.open);
      expect(QuoteBoardTabX.of(expired, now: now), QuoteBoardTab.lost);
    });

    test('countered is Replied', () {
      final q = sampleQuotation(status: QuotationStatus.countered);
      expect(QuoteBoardTabX.of(q), QuoteBoardTab.replied);
    });

    test('accepted and declined map to Accepted / Lost', () {
      expect(
        QuoteBoardTabX.of(sampleQuotation(status: QuotationStatus.accepted)),
        QuoteBoardTab.accepted,
      );
      expect(
        QuoteBoardTabX.of(sampleQuotation(status: QuotationStatus.declined)),
        QuoteBoardTab.lost,
      );
    });
  });

  group('Quotation expiry', () {
    test('isExpiringSoon is true within 2 days of validUntil, not after expiry', () {
      final now = DateTime(2026, 1, 10);
      final soon = sampleQuotation(validUntil: now.add(const Duration(hours: 30)));
      final notYet = sampleQuotation(validUntil: now.add(const Duration(days: 5)));
      final already = sampleQuotation(validUntil: now.subtract(const Duration(days: 1)));

      expect(soon.isExpiringSoon(now: now), isTrue);
      expect(notYet.isExpiringSoon(now: now), isFalse);
      expect(already.isExpiringSoon(now: now), isFalse);
      expect(already.isExpired(now: now), isTrue);
    });

    test('a countered quote can also expire', () {
      final now = DateTime(2026, 1, 10);
      final q = sampleQuotation(
        status: QuotationStatus.countered,
        clientResponseOutcome: ClientResponseOutcome.counter,
        validUntil: now.subtract(const Duration(days: 1)),
      );
      expect(q.isExpired(now: now), isTrue);
    });
  });
}
