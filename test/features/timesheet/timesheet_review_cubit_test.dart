import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:inspecta/core/enums/job_status.dart';
import 'package:inspecta/features/auth/domain/entities/user.dart';
import 'package:inspecta/features/auth/domain/entities/user_role.dart';
import 'package:inspecta/features/coordinator/domain/repositories/coordinator_repository.dart';
import 'package:inspecta/features/coordinator/domain/usecases/get_inspectors.dart';
import 'package:inspecta/features/requests/domain/usecases/get_requests.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_entry_status.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_expense.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_failure.dart';
import 'package:inspecta/features/timesheet/domain/usecases/approve_timesheet_entry.dart';
import 'package:inspecta/features/timesheet/domain/usecases/return_timesheet_entry.dart';
import 'package:inspecta/features/timesheet/domain/usecases/watch_all_timesheets.dart';
import 'package:inspecta/features/timesheet/presentation/bloc/timesheet_review_cubit.dart';

import '../requests/fake_requests_repository.dart';
import 'fake_timesheet_repository.dart';

class _FakeCoordinatorRepository implements CoordinatorRepository {
  final controller = StreamController<List<AppUser>>.broadcast();

  @override
  Stream<List<AppUser>> watchInspectors() => controller.stream;

  @override
  Future<void> markOnLeave(String inspectorId, DateTime? until) => throw UnimplementedError();
}

const _karim = AppUser(id: 'insp-1', name: 'Karim Adel', email: 'karim@inspecta.test', role: UserRole.inspector);

void main() {
  late FakeTimesheetRepository timesheetRepo;
  late FakeRequestsRepository requestsRepo;
  late _FakeCoordinatorRepository coordinatorRepo;
  late TimesheetReviewCubit cubit;

  setUp(() {
    timesheetRepo = FakeTimesheetRepository();
    requestsRepo = FakeRequestsRepository();
    coordinatorRepo = _FakeCoordinatorRepository();
    cubit = TimesheetReviewCubit(
      reviewerId: 'coord-1',
      reviewerName: 'Mona Salem',
      watchAllTimesheets: WatchAllTimesheets(timesheetRepo),
      getRequests: GetRequests(requestsRepo),
      getInspectors: GetInspectors(coordinatorRepo),
      approveEntry: ApproveTimesheetEntry(timesheetRepo),
      returnEntry: ReturnTimesheetEntry(timesheetRepo),
    );
  });

  tearDown(() => cubit.close());

  test('is ready as soon as the entries arrive, without waiting on jobs or inspectors', () async {
    cubit.start();
    expect(cubit.state.status, TimesheetReviewStatus.loading);

    timesheetRepo.allController.add([sampleEntry()]);
    await pumpEventQueue();

    expect(cubit.state.status, TimesheetReviewStatus.ready);
  });

  test('a failing entries stream shows the error, and retry loads again', () async {
    cubit.start();
    timesheetRepo.allController.addError(const TimesheetFailure(TimesheetFailureCode.permissionDenied));
    await pumpEventQueue();

    expect(cubit.state.status, TimesheetReviewStatus.error);
    expect(cubit.state.failure, TimesheetFailureCode.permissionDenied);

    await cubit.retry();
    expect(cubit.state.status, TimesheetReviewStatus.loading);

    timesheetRepo.allController.add([]);
    await pumpEventQueue();
    expect(cubit.state.status, TimesheetReviewStatus.ready);
  });

  test('a failing jobs or inspectors stream does not block the list', () async {
    cubit.start();
    timesheetRepo.allController.add([sampleEntry()]);
    requestsRepo.controller.addError(Exception('boom'));
    coordinatorRepo.controller.addError(Exception('boom'));
    await pumpEventQueue();

    expect(cubit.state.status, TimesheetReviewStatus.ready);
    expect(cubit.state.items, hasLength(1));
  });

  group('filtering', () {
    setUp(() async {
      cubit.start();
      timesheetRepo.allController.add([
        sampleEntry(requestId: 'a', pricePiastres: 100000),
        sampleEntry(requestId: 'b', pricePiastres: 250050),
        sampleEntry(requestId: 'c', status: TimesheetEntryStatus.approved, pricePiastres: 999900),
        sampleEntry(requestId: 'd', status: TimesheetEntryStatus.returned, reviewNote: 'Too high'),
      ]);
      await pumpEventQueue();
    });

    test('starts on pending', () {
      expect(cubit.state.filter, TimesheetEntryStatus.pending);
      expect(cubit.state.items.map((i) => i.entry.requestId), unorderedEquals(['a', 'b']));
    });

    test('switches between pending, approved and returned', () {
      cubit.setFilter(TimesheetEntryStatus.approved);
      expect(cubit.state.items.map((i) => i.entry.requestId), ['c']);

      cubit.setFilter(TimesheetEntryStatus.returned);
      expect(cubit.state.items.map((i) => i.entry.requestId), ['d']);
    });

    test('counts each status regardless of the filter', () {
      cubit.setFilter(TimesheetEntryStatus.approved);

      expect(cubit.state.countOf(TimesheetEntryStatus.pending), 2);
      expect(cubit.state.countOf(TimesheetEntryStatus.approved), 1);
      expect(cubit.state.countOf(TimesheetEntryStatus.returned), 1);
    });

    test('adds up only what is still pending', () {
      expect(cubit.state.pendingValuePiastres, 350050);
    });

    test('counts transportation costs in what is pending, as they are money to approve', () async {
      timesheetRepo.allController.add([
        sampleEntry(requestId: 'a', pricePiastres: 100000, expenses: {TimesheetExpense.internalTransport: 5000}),
        sampleEntry(
          requestId: 'b',
          pricePiastres: 200000,
          expenses: {TimesheetExpense.externalTransport: 12050},
        ),
        sampleEntry(
          requestId: 'c',
          status: TimesheetEntryStatus.approved,
          pricePiastres: 999900,
          expenses: {TimesheetExpense.externalTransport: 99900},
        ),
      ]);
      await pumpEventQueue();

      expect(cubit.state.pendingValuePiastres, 100000 + 5000 + 200000 + 12050);
    });
  });

  group('items', () {
    test('pair each entry with its job and inspector once those load', () async {
      cubit.start();
      timesheetRepo.allController.add([sampleEntry(requestId: 'job-1', inspectorId: 'insp-1')]);
      requestsRepo.controller.add([
        sampleRequest(id: 'job-1', status: JobStatus.inProgress, scheduledAt: DateTime(2026, 10, 5, 9)),
      ]);
      coordinatorRepo.controller.add([_karim]);
      await pumpEventQueue();

      final item = cubit.state.items.single;
      expect(item.request?.id, 'job-1');
      expect(item.inspector?.name, 'Karim Adel');
    });

    test('still list an entry whose job or inspector is unknown', () async {
      cubit.start();
      timesheetRepo.allController.add([sampleEntry(requestId: 'orphan', inspectorId: 'ghost')]);
      await pumpEventQueue();

      final item = cubit.state.items.single;
      expect(item.request, isNull);
      expect(item.inspector, isNull);
    });

    test('put the oldest job first while pending, and the newest first once decided', () async {
      cubit.start();
      timesheetRepo.allController.add([
        sampleEntry(requestId: 'new-pending'),
        sampleEntry(requestId: 'old-pending'),
        sampleEntry(requestId: 'new-approved', status: TimesheetEntryStatus.approved),
        sampleEntry(requestId: 'old-approved', status: TimesheetEntryStatus.approved),
      ]);
      requestsRepo.controller.add([
        sampleRequest(id: 'new-pending', scheduledAt: DateTime(2026, 10, 20)),
        sampleRequest(id: 'old-pending', scheduledAt: DateTime(2026, 10, 2)),
        sampleRequest(id: 'new-approved', scheduledAt: DateTime(2026, 10, 18)),
        sampleRequest(id: 'old-approved', scheduledAt: DateTime(2026, 10, 1)),
      ]);
      await pumpEventQueue();

      expect(cubit.state.items.map((i) => i.entry.requestId), ['old-pending', 'new-pending']);

      cubit.setFilter(TimesheetEntryStatus.approved);
      expect(cubit.state.items.map((i) => i.entry.requestId), ['new-approved', 'old-approved']);
    });
  });

  group('deciding', () {
    test('approving records the reviewer and reports success as null', () async {
      final failure = await cubit.approve('REQ-1');

      expect(failure, isNull);
      expect(timesheetRepo.approvals, [('REQ-1', 'coord-1', 'Mona Salem')]);
    });

    test('returning sends the note along with the reviewer', () async {
      final failure = await cubit.sendBack('REQ-1', 'Price is too high');

      expect(failure, isNull);
      expect(timesheetRepo.returns, [('REQ-1', 'coord-1', 'Mona Salem', 'Price is too high')]);
    });

    test('reports why a decision failed', () async {
      timesheetRepo.reviewFailure = const TimesheetFailure(TimesheetFailureCode.permissionDenied);

      expect(await cubit.approve('REQ-1'), TimesheetFailureCode.permissionDenied);
      expect(await cubit.sendBack('REQ-1', 'x'), TimesheetFailureCode.permissionDenied);
    });

    test('marks the job busy while saving, and clears it afterwards — even on failure', () async {
      final seen = <String?>[];
      final subscription = cubit.stream.listen((s) => seen.add(s.busyRequestId));

      await cubit.approve('REQ-1');
      timesheetRepo.reviewFailure = const TimesheetFailure(TimesheetFailureCode.network);
      await cubit.approve('REQ-2');
      await pumpEventQueue();
      await subscription.cancel();

      expect(seen, ['REQ-1', null, 'REQ-2', null]);
      expect(cubit.state.busyRequestId, isNull);
    });
  });
}
