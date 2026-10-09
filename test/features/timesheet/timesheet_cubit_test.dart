import 'package:flutter_test/flutter_test.dart';
import 'package:inspecta/core/enums/job_status.dart';
import 'package:inspecta/features/requests/domain/entities/inspection_request.dart';
import 'package:inspecta/features/requests/domain/entities/requests_failure.dart';
import 'package:inspecta/features/requests/domain/usecases/get_my_tasks.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_activity.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_entry.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_expense.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_failure.dart';
import 'package:inspecta/features/timesheet/domain/usecases/save_hourly_rate.dart';
import 'package:inspecta/features/timesheet/domain/usecases/save_timesheet_entry.dart';
import 'package:inspecta/features/timesheet/domain/usecases/watch_hourly_rate.dart';
import 'package:inspecta/features/timesheet/domain/usecases/watch_timesheet.dart';
import 'package:inspecta/features/timesheet/presentation/bloc/timesheet_cubit.dart';

import '../requests/fake_requests_repository.dart';
import 'fake_timesheet_repository.dart';

void main() {
  late FakeRequestsRepository requestsRepo;
  late FakeTimesheetRepository timesheetRepo;
  late TimesheetCubit cubit;

  final now = DateTime.now();
  DateTime inThisMonth(int day, [int hour = 9]) => DateTime(now.year, now.month, day, hour);

  setUp(() {
    requestsRepo = FakeRequestsRepository();
    timesheetRepo = FakeTimesheetRepository();
    cubit = TimesheetCubit(
      inspectorId: 'insp-1',
      getMyTasks: GetMyTasks(requestsRepo),
      watchTimesheet: WatchTimesheet(timesheetRepo),
      watchHourlyRate: WatchHourlyRate(timesheetRepo),
      saveEntry: SaveTimesheetEntry(timesheetRepo),
      saveHourlyRate: SaveHourlyRate(timesheetRepo),
    );
  });

  tearDown(() => cubit.close());

  test('stays loading until the jobs, the entries and the hourly rate have all arrived', () async {
    cubit.start();
    expect(cubit.state.status, TimesheetStatus.loading);

    requestsRepo.assignedController.add([sampleRequest(id: 'REQ-1', status: JobStatus.taskAccepted)]);
    await pumpEventQueue();
    expect(cubit.state.status, TimesheetStatus.loading);

    timesheetRepo.controller.add([]);
    await pumpEventQueue();
    expect(cubit.state.status, TimesheetStatus.loading);

    timesheetRepo.rateController.add(15000);
    await pumpEventQueue();
    expect(cubit.state.status, TimesheetStatus.ready);
    expect(cubit.state.hourlyRatePiastres, 15000);
  });

  test('a rate that cannot be read shows the error rather than pricing at nothing', () async {
    cubit.start();
    timesheetRepo.rateController.addError(const TimesheetFailure(TimesheetFailureCode.permissionDenied));
    await pumpEventQueue();

    expect(cubit.state.status, TimesheetStatus.error);
    expect(cubit.state.failure, TimesheetFailureCode.permissionDenied);
  });

  group('rows', () {
    Future<void> deliver({required List<InspectionRequest> requests, List<TimesheetEntry> entries = const []}) async {
      cubit.start();
      requestsRepo.assignedController.add(requests);
      timesheetRepo.controller.add(entries);
      await pumpEventQueue();
    }

    test('lists only accepted, scheduled jobs in the selected month, earliest first', () async {
      await deliver(
        requests: [
          sampleRequest(id: 'late', status: JobStatus.inProgress, scheduledAt: inThisMonth(20)),
          sampleRequest(id: 'early', status: JobStatus.taskAccepted, scheduledAt: inThisMonth(3)),
          sampleRequest(id: 'not-accepted', status: JobStatus.assigned, scheduledAt: inThisMonth(5)),
          sampleRequest(id: 'unscheduled', status: JobStatus.taskAccepted),
          sampleRequest(
            id: 'other-month',
            status: JobStatus.sentToClient,
            scheduledAt: DateTime(now.year, now.month + 1, 2),
          ),
        ],
      );

      expect(cubit.state.rows.map((r) => r.request.id), ['early', 'late']);
    });

    test('includes jobs past the inspector\'s own work, so finished jobs can still be priced', () async {
      await deliver(
        requests: [
          for (final (i, status) in [
            JobStatus.certificateSubmitted,
            JobStatus.certificateReturned,
            JobStatus.certificateApproved,
            JobStatus.sentToClient,
          ].indexed)
            sampleRequest(id: 'job-$i', status: status, scheduledAt: inThisMonth(i + 1)),
        ],
      );

      expect(cubit.state.rows, hasLength(4));
    });

    test('pairs each job with its entry, and leaves unlogged jobs without one', () async {
      await deliver(
        requests: [
          sampleRequest(id: 'logged', status: JobStatus.taskAccepted, scheduledAt: inThisMonth(3)),
          sampleRequest(id: 'unlogged', status: JobStatus.taskAccepted, scheduledAt: inThisMonth(4)),
        ],
        entries: [sampleEntry(requestId: 'logged'), sampleEntry(requestId: 'someone-elses-job')],
      );

      final rows = cubit.state.rows;
      expect(rows.map((r) => r.isLogged), [true, false]);
      expect(rows.first.entry, sampleEntry(requestId: 'logged'));
    });

    test('totals only the selected month\'s logged time and price', () async {
      await deliver(
        requests: [
          sampleRequest(id: 'a', status: JobStatus.taskAccepted, scheduledAt: inThisMonth(3)),
          sampleRequest(id: 'b', status: JobStatus.inProgress, scheduledAt: inThisMonth(4)),
          sampleRequest(id: 'c', status: JobStatus.taskAccepted, scheduledAt: inThisMonth(5)),
          sampleRequest(
            id: 'next-month',
            status: JobStatus.taskAccepted,
            scheduledAt: DateTime(now.year, now.month + 1, 2),
          ),
        ],
        entries: [
          sampleEntry(requestId: 'a', minutes: 90, pricePiastres: 450000),
          sampleEntry(requestId: 'b', minutes: 45, pricePiastres: 200050),
          sampleEntry(requestId: 'next-month', minutes: 600, pricePiastres: 999900),
        ],
      );

      expect(cubit.state.totalMinutes, 135);
      expect(cubit.state.totalPricePiastres, 650050);
      expect(cubit.state.loggedCount, 2);
      expect(cubit.state.rows, hasLength(3));
    });
  });

  test('the month\'s time is net working time: an unpaid break is deducted, not added', () async {
    cubit.start();
    requestsRepo.assignedController.add([
      sampleRequest(id: 'a', status: JobStatus.taskAccepted, scheduledAt: inThisMonth(3)),
    ]);
    timesheetRepo.controller.add([
      sampleEntry(
        requestId: 'a',
        activities: {
          TimesheetActivity.inspection: 180,
          TimesheetActivity.reportPreparation: 30,
          TimesheetActivity.waiting: 60,
          TimesheetActivity.unpaidBreak: 60,
        },
      ),
    ]);
    await pumpEventQueue();

    // 180 + 30 + 60 worked, with the 60-minute break left out.
    expect(cubit.state.totalMinutes, 270);
  });

  test('transportation costs are money in the month total, kept apart from the prices', () async {
    cubit.start();
    requestsRepo.assignedController.add([
      sampleRequest(id: 'a', status: JobStatus.taskAccepted, scheduledAt: inThisMonth(3)),
      sampleRequest(id: 'b', status: JobStatus.inProgress, scheduledAt: inThisMonth(4)),
      sampleRequest(id: 'next-month', status: JobStatus.taskAccepted, scheduledAt: DateTime(now.year, now.month + 1, 2)),
    ]);
    timesheetRepo.controller.add([
      sampleEntry(
        requestId: 'a',
        pricePiastres: 300000,
        expenses: {TimesheetExpense.internalTransport: 5000, TimesheetExpense.externalTransport: 20000},
      ),
      sampleEntry(requestId: 'b', pricePiastres: 100000, expenses: {TimesheetExpense.externalTransport: 7550}),
      sampleEntry(requestId: 'next-month', pricePiastres: 999900, expenses: {TimesheetExpense.internalTransport: 99900}),
    ]);
    await pumpEventQueue();

    expect(cubit.state.totalPricePiastres, 400000);
    expect(cubit.state.totalExpensesPiastres, 32550);
    expect(cubit.state.totalPiastres, 432550);
  });

  test('transportation never adds to the time', () async {
    cubit.start();
    requestsRepo.assignedController.add([
      sampleRequest(id: 'a', status: JobStatus.taskAccepted, scheduledAt: inThisMonth(3)),
    ]);
    timesheetRepo.controller.add([
      sampleEntry(
        requestId: 'a',
        minutes: 60,
        expenses: {TimesheetExpense.internalTransport: 5000, TimesheetExpense.externalTransport: 20000},
      ),
    ]);
    await pumpEventQueue();

    expect(cubit.state.totalMinutes, 60);
  });

  group('month navigation', () {
    test('starts on the current month and steps back and forward', () {
      expect(cubit.state.selectedMonth, DateTime(now.year, now.month));

      cubit.previousMonth();
      expect(cubit.state.selectedMonth, DateTime(now.year, now.month - 1));

      cubit.nextMonth();
      cubit.nextMonth();
      expect(cubit.state.selectedMonth, DateTime(now.year, now.month + 1));
    });

    test('rolls over the year', () {
      for (var i = 0; i < 12; i++) {
        cubit.nextMonth();
      }
      expect(cubit.state.selectedMonth, DateTime(now.year + 1, now.month));
    });

    test('shows the jobs of whichever month is selected', () async {
      cubit.start();
      requestsRepo.assignedController.add([
        sampleRequest(
          id: 'last-month',
          status: JobStatus.sentToClient,
          scheduledAt: DateTime(now.year, now.month - 1, 15),
        ),
      ]);
      timesheetRepo.controller.add([]);
      await pumpEventQueue();
      expect(cubit.state.rows, isEmpty);

      cubit.previousMonth();
      expect(cubit.state.rows.map((r) => r.request.id), ['last-month']);
    });
  });

  group('errors', () {
    test('a failing jobs stream shows the error', () async {
      cubit.start();
      requestsRepo.assignedController.addError(const RequestsFailure(RequestsFailureCode.permissionDenied));
      await pumpEventQueue();

      expect(cubit.state.status, TimesheetStatus.error);
      expect(cubit.state.failure, TimesheetFailureCode.permissionDenied);
    });

    test('a failing entries stream shows the error', () async {
      cubit.start();
      timesheetRepo.controller.addError(const TimesheetFailure(TimesheetFailureCode.network));
      await pumpEventQueue();

      expect(cubit.state.status, TimesheetStatus.error);
      expect(cubit.state.failure, TimesheetFailureCode.network);
    });

    test('data from the other stream does not clear an error', () async {
      cubit.start();
      requestsRepo.assignedController.add([]);
      timesheetRepo.controller.addError(const TimesheetFailure(TimesheetFailureCode.unknown));
      await pumpEventQueue();

      requestsRepo.assignedController.add([]);
      await pumpEventQueue();

      expect(cubit.state.status, TimesheetStatus.error);
    });

    test('retry reloads both streams', () async {
      cubit.start();
      timesheetRepo.controller.addError(const TimesheetFailure(TimesheetFailureCode.network));
      await pumpEventQueue();
      expect(cubit.state.status, TimesheetStatus.error);

      final retrying = cubit.retry();
      await retrying;
      expect(cubit.state.status, TimesheetStatus.loading);
      expect(cubit.state.failure, isNull);

      requestsRepo.assignedController.add([]);
      timesheetRepo.controller.add([]);
      timesheetRepo.rateController.add(0);
      await pumpEventQueue();
      expect(cubit.state.status, TimesheetStatus.ready);
    });
  });

  group('saveEntry', () {
    // The tab knows the rate once the stream has delivered it.
    Future<void> hasRate(int piastres) async {
      cubit.start();
      timesheetRepo.rateController.add(piastres);
      await pumpEventQueue();
    }

    test('works out the price from the net time at the hourly rate — it is never an input', () async {
      await hasRate(15000);

      final failure = await cubit.saveEntry(
        requestId: 'REQ-1',
        activities: {TimesheetActivity.inspection: 150, TimesheetActivity.unpaidBreak: 60},
        expenses: {TimesheetExpense.externalTransport: 12000},
      );

      expect(failure, isNull);
      expect(timesheetRepo.saved, [
        sampleEntry(
          requestId: 'REQ-1',
          inspectorId: 'insp-1',
          activities: {TimesheetActivity.inspection: 150, TimesheetActivity.unpaidBreak: 60},
          // 150 minutes worked at EGP 150 an hour; the break isn't paid.
          pricePiastres: 37500,
          hourlyRatePiastres: 15000,
          expenses: {TimesheetExpense.externalTransport: 12000},
        ),
      ]);
    });

    test('saves the rate it priced with, so changing the rate later leaves it alone', () async {
      await hasRate(10000);
      await cubit.saveEntry(requestId: 'REQ-1', activities: {TimesheetActivity.inspection: 60}, expenses: const {});

      timesheetRepo.rateController.add(20000);
      await pumpEventQueue();
      await cubit.saveEntry(requestId: 'REQ-2', activities: {TimesheetActivity.inspection: 60}, expenses: const {});

      expect(timesheetRepo.saved.map((e) => (e.hourlyRatePiastres, e.pricePiastres)), [(10000, 10000), (20000, 20000)]);
    });

    test('has no price while no rate is set', () async {
      await hasRate(0);

      await cubit.saveEntry(requestId: 'REQ-1', activities: {TimesheetActivity.inspection: 240}, expenses: const {});

      expect(timesheetRepo.saved.single.pricePiastres, 0);
      expect(timesheetRepo.saved.single.hourlyRatePiastres, 0);
      expect(timesheetRepo.saved.single.minutes, 240);
    });

    test('reports why a save failed', () async {
      timesheetRepo.saveFailure = const TimesheetFailure(TimesheetFailureCode.permissionDenied);

      final failure = await cubit.saveEntry(
        requestId: 'REQ-1',
        activities: {TimesheetActivity.inspection: 60},
        expenses: const {},
      );

      expect(failure, TimesheetFailureCode.permissionDenied);
      expect(timesheetRepo.saved, isEmpty);
    });

    test('treats an unexpected error as unknown', () async {
      timesheetRepo.saveFailure = const TimesheetFailure(TimesheetFailureCode.unknown);

      expect(
        await cubit.saveEntry(requestId: 'REQ-1', activities: {TimesheetActivity.inspection: 60}, expenses: const {}),
        TimesheetFailureCode.unknown,
      );
    });
  });

  group('saveHourlyRate', () {
    test('saves the rate under the inspector id and reports success as null', () async {
      expect(await cubit.saveHourlyRate(17550), isNull);

      expect(timesheetRepo.savedRates, [('insp-1', 17550)]);
    });

    test('reports why it failed', () async {
      timesheetRepo.rateFailure = const TimesheetFailure(TimesheetFailureCode.permissionDenied);

      expect(await cubit.saveHourlyRate(17550), TimesheetFailureCode.permissionDenied);
      expect(timesheetRepo.savedRates, isEmpty);
    });
  });
}
