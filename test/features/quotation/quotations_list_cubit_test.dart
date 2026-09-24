import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspecta/features/quotation/domain/entities/quotation.dart';
import 'package:inspecta/features/quotation/domain/entities/quotation_status.dart';
import 'package:inspecta/features/quotation/domain/entities/quote_board_tab.dart';
import 'package:inspecta/features/quotation/domain/entities/reply_type.dart';
import 'package:inspecta/features/quotation/domain/usecases/get_quotations.dart';
import 'package:inspecta/features/quotation/presentation/bloc/quotations_list_cubit.dart';

import 'fake_quotation.dart';
import 'fake_quotation_repository.dart';

class _StreamingQuotationRepository extends FakeQuotationRepository {
  final controller = StreamController<List<Quotation>>.broadcast();

  @override
  Stream<List<Quotation>> watchAll() => controller.stream;
}

void main() {
  late _StreamingQuotationRepository repo;
  late QuotationsListCubit cubit;

  setUp(() {
    repo = _StreamingQuotationRepository();
    cubit = QuotationsListCubit(GetQuotations(repo));
  });

  tearDown(() => cubit.close());

  test('keeps only the latest non-draft, non-superseded quotation per request', () async {
    cubit.start();
    repo.controller.add([
      sampleQuotation(id: 'q1', requestId: 'REQ-1', version: 1, status: QuotationStatus.superseded),
      sampleQuotation(
        id: 'q2',
        requestId: 'REQ-1',
        version: 2,
        status: QuotationStatus.sent,
        createdAt: DateTime(2026, 1, 5),
      ),
      sampleQuotation(id: 'q3', requestId: 'REQ-2', status: QuotationStatus.draft),
    ]);
    await pumpEventQueue();

    expect(cubit.state.board.map((q) => q.id), ['q2']);
  });

  test('countOf groups board items by their QuoteBoardTab', () async {
    cubit.start();
    repo.controller.add([
      sampleQuotation(id: 'q1', requestId: 'REQ-1', status: QuotationStatus.sent),
      sampleQuotation(id: 'q2', requestId: 'REQ-2', status: QuotationStatus.countered),
      sampleQuotation(id: 'q3', requestId: 'REQ-3', status: QuotationStatus.accepted),
      sampleQuotation(id: 'q4', requestId: 'REQ-4', type: ReplyType.reject),
    ]);
    await pumpEventQueue();

    expect(cubit.state.countOf(QuoteBoardTab.open), 1);
    expect(cubit.state.countOf(QuoteBoardTab.replied), 1);
    expect(cubit.state.countOf(QuoteBoardTab.accepted), 1);
    expect(cubit.state.countOf(QuoteBoardTab.lost), 1);
  });

  test('visible filters by tab then by client/request/quote-id search', () async {
    cubit.start();
    repo.controller.add([
      sampleQuotation(
        id: 'q1',
        requestId: 'REQ-1',
        requestNumber: 'REQ-2026-0001',
        clientName: 'Delta Steel Co.',
        status: QuotationStatus.sent,
      ),
      sampleQuotation(
        id: 'q2',
        requestId: 'REQ-2',
        requestNumber: 'REQ-2026-0002',
        clientName: 'Nile Logistics',
        status: QuotationStatus.sent,
      ),
    ]);
    await pumpEventQueue();

    expect(cubit.state.visible, hasLength(2));

    cubit.setQuery('delta');
    expect(cubit.state.visible.map((q) => q.id), ['q1']);

    cubit.setQuery('REQ-2026-0002');
    expect(cubit.state.visible.map((q) => q.id), ['q2']);
  });

  test('openTotalPiastres sums only Open-tab totals', () async {
    cubit.start();
    repo.controller.add([
      sampleQuotation(id: 'q1', requestId: 'REQ-1', status: QuotationStatus.sent, totalPiastres: 100000),
      sampleQuotation(id: 'q2', requestId: 'REQ-2', status: QuotationStatus.sent, totalPiastres: 250000),
      sampleQuotation(id: 'q3', requestId: 'REQ-3', status: QuotationStatus.accepted, totalPiastres: 999999),
    ]);
    await pumpEventQueue();

    expect(cubit.state.openTotalPiastres, 350000);
  });

  test('acceptedThisMonth counts and totals only responses logged this month', () async {
    cubit.start();
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 10);
    final lastMonth = DateTime(now.year, now.month - 1 == 0 ? 12 : now.month - 1, 10);

    repo.controller.add([
      sampleQuotation(
        id: 'q1',
        requestId: 'REQ-1',
        status: QuotationStatus.accepted,
        totalPiastres: 100000,
        clientRespondedAt: thisMonth,
      ),
      sampleQuotation(
        id: 'q2',
        requestId: 'REQ-2',
        status: QuotationStatus.accepted,
        totalPiastres: 500000,
        clientRespondedAt: lastMonth,
      ),
    ]);
    await pumpEventQueue();

    expect(cubit.state.acceptedThisMonthCount, 1);
    expect(cubit.state.acceptedThisMonthTotalPiastres, 100000);
  });

  test('expiringSoonCount counts across the whole board, not just Open', () async {
    cubit.start();
    final now = DateTime.now();
    repo.controller.add([
      sampleQuotation(
        id: 'q1',
        requestId: 'REQ-1',
        status: QuotationStatus.sent,
        validUntil: now.add(const Duration(hours: 20)),
      ),
      sampleQuotation(
        id: 'q2',
        requestId: 'REQ-2',
        status: QuotationStatus.sent,
        validUntil: now.add(const Duration(days: 10)),
      ),
    ]);
    await pumpEventQueue();

    expect(cubit.state.expiringSoonCount, 1);

    cubit.showExpiringSoon();
    expect(cubit.state.visible.map((q) => q.id), ['q1']);
  });
}
