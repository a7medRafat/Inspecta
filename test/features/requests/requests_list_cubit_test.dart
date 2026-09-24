import 'package:flutter_test/flutter_test.dart';
import 'package:inspecta/core/enums/job_status.dart';
import 'package:inspecta/features/requests/domain/entities/requests_failure.dart';
import 'package:inspecta/features/requests/domain/entities/requests_tab.dart';
import 'package:inspecta/features/requests/domain/usecases/get_requests.dart';
import 'package:inspecta/features/requests/presentation/bloc/requests_list_cubit.dart';

import 'fake_requests_repository.dart';

void main() {
  late FakeRequestsRepository repo;
  late RequestsListCubit cubit;

  setUp(() {
    repo = FakeRequestsRepository();
    cubit = RequestsListCubit(GetRequests(repo));
  });

  tearDown(() => cubit.close());

  test('starts loading, then ready with the stream\'s requests', () async {
    expect(cubit.state.status, RequestsListStatus.loading);

    cubit.start();
    final requests = [sampleRequest(id: 'REQ-1')];
    repo.controller.add(requests);
    await pumpEventQueue();

    expect(cubit.state.status, RequestsListStatus.ready);
    expect(cubit.state.requests, requests);
  });

  test('surfaces a stream error as a failure code', () async {
    cubit.start();
    repo.controller.addError(
      const RequestsFailure(RequestsFailureCode.permissionDenied),
    );
    await pumpEventQueue();

    expect(cubit.state.status, RequestsListStatus.error);
    expect(cubit.state.failure, RequestsFailureCode.permissionDenied);
  });

  group('RequestsListState.visible', () {
    test('filters by tab, then by search text (acceptance criterion 4)', () async {
      cubit.start();
      repo.controller.add([
        sampleRequest(
          id: 'REQ-2026-0001',
          status: JobStatus.requestReceived,
          clientName: 'Delta Steel Co.',
        ),
        sampleRequest(
          id: 'REQ-2026-0002',
          status: JobStatus.quoteSent,
          clientName: 'Nile Logistics',
        ),
      ]);
      await pumpEventQueue();

      expect(cubit.state.visible.map((r) => r.id), ['REQ-2026-0001']);

      cubit.setTab(RequestsTab.all);
      expect(
        cubit.state.visible.map((r) => r.id),
        ['REQ-2026-0001', 'REQ-2026-0002'],
      );

      cubit.setTab(RequestsTab.newTab);
      cubit.setQuery('nile');
      expect(cubit.state.visible, isEmpty);

      cubit.setQuery('delta');
      expect(cubit.state.visible.map((r) => r.id), ['REQ-2026-0001']);
    });

    test('countOf ignores the search text', () async {
      cubit.start();
      repo.controller.add([
        sampleRequest(id: 'REQ-1', status: JobStatus.requestReceived),
        sampleRequest(id: 'REQ-2', status: JobStatus.requestReceived),
        sampleRequest(id: 'REQ-3', status: JobStatus.quoteSent),
      ]);
      await pumpEventQueue();

      cubit.setQuery('nothing matches this');
      expect(cubit.state.countOf(RequestsTab.newTab), 2);
      expect(cubit.state.countOf(RequestsTab.all), 3);
    });
  });

  test('retry resubscribes after an error', () async {
    cubit.start();
    repo.controller.addError(const RequestsFailure(RequestsFailureCode.network));
    await pumpEventQueue();
    expect(cubit.state.status, RequestsListStatus.error);

    await cubit.retry();
    final repo2 = repo; // same repo/controller; retry just re-listens.
    repo2.controller.add([sampleRequest()]);
    await pumpEventQueue();

    expect(cubit.state.status, RequestsListStatus.ready);
    expect(cubit.state.failure, isNull);
  });
}
