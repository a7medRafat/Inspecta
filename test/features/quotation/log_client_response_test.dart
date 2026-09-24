import 'package:flutter_test/flutter_test.dart';
import 'package:inspecta/core/enums/job_status.dart';
import 'package:inspecta/features/quotation/domain/entities/client_response_outcome.dart';
import 'package:inspecta/features/quotation/domain/entities/quotation_failure.dart';
import 'package:inspecta/features/quotation/domain/usecases/log_client_response.dart';

import '../requests/fake_requests_repository.dart';
import 'fake_quotation_repository.dart';

void main() {
  late FakeQuotationRepository quotationRepo;
  late FakeRequestsRepository requestsRepo;
  late LogClientResponse usecase;

  setUp(() {
    quotationRepo = FakeQuotationRepository();
    requestsRepo = FakeRequestsRepository();
    usecase = LogClientResponse(quotationRepo, requestsRepo);
  });

  test('counter moves the request to client_countered (BR-03.6)', () async {
    await usecase(
      quotationId: 'q1',
      requestId: 'REQ-1',
      outcome: ClientResponseOutcome.counter,
      clientPricePiastres: 400000,
      note: 'They want a lower rate',
    );

    expect(quotationRepo.responseCalls.single.outcome, ClientResponseOutcome.counter);
    expect(quotationRepo.responseCalls.single.clientPrice, 400000);
    expect(requestsRepo.statusUpdates.single.$2, JobStatus.clientCountered);
  });

  test('accepted moves the request to quote_accepted (BR-03.7)', () async {
    await usecase(
      quotationId: 'q1',
      requestId: 'REQ-1',
      outcome: ClientResponseOutcome.accepted,
    );

    expect(requestsRepo.statusUpdates.single.$2, JobStatus.quoteAccepted);
  });

  test('declined moves the request to client_declined', () async {
    await usecase(
      quotationId: 'q1',
      requestId: 'REQ-1',
      outcome: ClientResponseOutcome.declined,
    );

    expect(requestsRepo.statusUpdates.single.$2, JobStatus.clientDeclined);
  });

  test('does not update the request if recording the response fails', () async {
    quotationRepo.recordResponseFailure = const QuotationFailure(QuotationFailureCode.network);

    await expectLater(
      () => usecase(quotationId: 'q1', requestId: 'REQ-1', outcome: ClientResponseOutcome.accepted),
      throwsA(isA<QuotationFailure>()),
    );
    expect(requestsRepo.statusUpdates, isEmpty);
  });
}
