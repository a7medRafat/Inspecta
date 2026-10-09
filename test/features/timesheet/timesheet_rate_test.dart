import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspecta/features/requests/domain/usecases/get_my_tasks.dart';
import 'package:inspecta/features/timesheet/domain/usecases/save_hourly_rate.dart';
import 'package:inspecta/features/timesheet/domain/usecases/save_timesheet_entry.dart';
import 'package:inspecta/features/timesheet/domain/usecases/watch_hourly_rate.dart';
import 'package:inspecta/features/timesheet/domain/usecases/watch_timesheet.dart';
import 'package:inspecta/features/timesheet/presentation/bloc/timesheet_cubit.dart';
import 'package:inspecta/features/timesheet/presentation/widgets/hourly_rate_sheet.dart';
import 'package:inspecta/features/timesheet/presentation/widgets/timesheet_header.dart';
import 'package:inspecta/l10n/app_localizations.dart';

import '../requests/fake_requests_repository.dart';
import 'fake_timesheet_repository.dart';

Widget _app(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: home),
);

void _phoneSized(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 1200) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  group('HourlyRateSheet', () {
    final saved = <int>[];
    bool? result;
    var saveSucceeds = true;

    setUp(() {
      saved.clear();
      result = null;
      saveSucceeds = true;
    });

    Future<void> openSheet(WidgetTester tester, {int current = 0}) async {
      _phoneSized(tester);
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () async {
                  result = await HourlyRateSheet.show(
                    context,
                    initialRatePiastres: current,
                    onSubmit: (rate) async {
                      saved.add(rate);
                      return saveSucceeds;
                    },
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    String fieldText(WidgetTester tester) => tester.widget<TextField>(find.byType(TextField)).controller!.text;

    testWidgets('starts empty when no rate has been set', (tester) async {
      await openSheet(tester);

      expect(fieldText(tester), isEmpty);
    });

    testWidgets('starts from the current rate', (tester) async {
      await openSheet(tester, current: 17550);

      expect(fieldText(tester), '175.50');
    });

    testWidgets('explains what the rate is for, and that old entries keep theirs', (tester) async {
      await openSheet(tester);

      expect(find.textContaining('net working time × your hourly rate'), findsOneWidget);
      expect(find.textContaining('keep the rate they were saved with'), findsOneWidget);
    });

    testWidgets('will not save without a rate', (tester) async {
      await openSheet(tester);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Enter an hourly rate.'), findsOneWidget);
      expect(saved, isEmpty);
    });

    testWidgets('will not save a rate of zero', (tester) async {
      await openSheet(tester);
      await tester.enterText(find.byType(TextField), '0');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Enter an hourly rate.'), findsOneWidget);
      expect(saved, isEmpty);
    });

    testWidgets('saves the rate in piastres and closes', (tester) async {
      await openSheet(tester);
      await tester.enterText(find.byType(TextField), '175.50');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(saved, [17550]);
      expect(result, isTrue);
      expect(find.byType(HourlyRateSheet), findsNothing);
    });

    testWidgets('stays open, ready to retry, when the save fails', (tester) async {
      saveSucceeds = false;
      await openSheet(tester);
      await tester.enterText(find.byType(TextField), '150');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.byType(HourlyRateSheet), findsOneWidget);
      expect(result, isNull);

      saveSucceeds = true;
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(saved, [15000, 15000]);
      expect(find.byType(HourlyRateSheet), findsNothing);
    });
  });

  group('TimesheetHeader\'s hourly rate', () {
    late FakeTimesheetRepository repo;
    late TimesheetCubit cubit;

    setUp(() {
      repo = FakeTimesheetRepository();
      final requestsRepo = FakeRequestsRepository();
      cubit = TimesheetCubit(
        inspectorId: 'insp-1',
        getMyTasks: GetMyTasks(requestsRepo),
        watchTimesheet: WatchTimesheet(repo),
        watchHourlyRate: WatchHourlyRate(repo),
        saveEntry: SaveTimesheetEntry(repo),
        saveHourlyRate: SaveHourlyRate(repo),
      );
    });

    tearDown(() => cubit.close());

    Future<void> pumpHeader(WidgetTester tester, {required int rate}) async {
      _phoneSized(tester);
      cubit.start();
      repo.rateController.add(rate);
      await tester.pumpWidget(BlocProvider.value(value: cubit, child: _app(const TimesheetHeader())));
      await tester.pump();
    }

    testWidgets('prompts for a rate when there is none', (tester) async {
      await pumpHeader(tester, rate: 0);

      expect(find.text('Set your hourly rate'), findsOneWidget);
    });

    testWidgets('shows the rate prices are worked out from', (tester) async {
      await pumpHeader(tester, rate: 15000);

      expect(find.text('Hourly rate · EGP 150.00 / hour'), findsOneWidget);
      expect(find.text('Set your hourly rate'), findsNothing);
    });

    testWidgets('tapping it lets the inspector set the rate', (tester) async {
      await pumpHeader(tester, rate: 0);

      await tester.tap(find.text('Set your hourly rate'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '175.50');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repo.savedRates, [('insp-1', 17550)]);
      expect(find.byType(HourlyRateSheet), findsNothing);
    });

    testWidgets('tapping it when a rate is set starts from that rate', (tester) async {
      await pumpHeader(tester, rate: 15000);

      await tester.tap(find.text('Hourly rate · EGP 150.00 / hour'));
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '150');
    });
  });
}
