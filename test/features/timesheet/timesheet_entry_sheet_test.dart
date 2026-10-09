import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspecta/core/enums/job_status.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_activity.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_entry.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_expense.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_row.dart';
import 'package:inspecta/features/timesheet/presentation/widgets/timesheet_entry_sheet.dart';
import 'package:inspecta/l10n/app_localizations.dart';

import '../requests/fake_requests_repository.dart';
import 'fake_timesheet_repository.dart';

typedef _Submission = ({Map<TimesheetActivity, int> activities, Map<TimesheetExpense, int> expenses});

// An EGP 150 hourly rate, in piastres.
const _rate150 = 15000;

void main() {
  final submissions = <_Submission>[];
  bool? sheetResult;
  var saveSucceeds = true;

  setUp(() {
    submissions.clear();
    sheetResult = null;
    saveSucceeds = true;
  });

  TimesheetRow rowFor({TimesheetEntry? entry}) => TimesheetRow(
    request: sampleRequest(
      status: JobStatus.taskAccepted,
      scheduledAt: DateTime(2026, 10, 5, 9),
    ),
    entry: entry,
  );

  Future<void> openSheet(WidgetTester tester, {TimesheetEntry? entry, int hourlyRate = _rate150}) async {
    tester.view.physicalSize = const Size(390, 1800) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  sheetResult = await TimesheetEntrySheet.show(
                    context,
                    row: rowFor(entry: entry),
                    hourlyRatePiastres: hourlyRate,
                    onSubmit: ({required activities, required expenses}) async {
                      submissions.add((activities: activities, expenses: expenses));
                      return saveSucceeds;
                    },
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder hoursField(TimesheetActivity a) => find.byKey(Key('${a.name}-hours'));

  Finder minutesField(TimesheetActivity a) => find.byKey(Key('${a.name}-minutes'));

  // A cost's amount sits in a price field inside its row.
  Finder costField(TimesheetExpense e) =>
      find.descendant(of: find.byKey(Key('${e.name}-cost')), matching: find.byType(TextField));

  String textOf(WidgetTester tester, Finder field) => tester.widget<TextField>(field).controller!.text;

  Future<void> enter(
    WidgetTester tester,
    TimesheetActivity activity, {
    String hours = '',
    String minutes = '',
  }) async {
    if (hours.isNotEmpty) await tester.enterText(hoursField(activity), hours);
    if (minutes.isNotEmpty) await tester.enterText(minutesField(activity), minutes);
  }

  // Taps the field before typing, as a person would: the keyboard has to
  // move to it first, or the text goes to whichever field had focus.
  Future<void> enterCost(WidgetTester tester, TimesheetExpense expense, String amount) async {
    await tester.tap(costField(expense));
    await tester.pump();
    await tester.enterText(costField(expense), amount);
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('offers time for each activity, including the unpaid break', (tester) async {
    await openSheet(tester);

    expect(find.text('Inspection & load testing'), findsOneWidget);
    expect(find.text('Report preparation'), findsOneWidget);
    expect(find.text('Waiting'), findsOneWidget);
    expect(find.text('Unpaid break'), findsOneWidget);
  });

  testWidgets('asks for transportation as an amount of money, not time', (tester) async {
    await openSheet(tester);

    expect(find.text('Transportation costs'), findsOneWidget);
    expect(find.text('Internal transportation'), findsOneWidget);
    expect(find.text('External transportation'), findsOneWidget);
    // Money fields, with no hours/minutes boxes beside them.
    expect(costField(TimesheetExpense.internalTransport), findsOneWidget);
    expect(costField(TimesheetExpense.externalTransport), findsOneWidget);
    expect(find.text('EGP'), findsNWidgets(2));
    expect(find.byKey(const Key('internalTransport-hours')), findsNothing);
    expect(find.byKey(const Key('externalTransport-minutes')), findsNothing);
  });

  testWidgets('has no price field: the price is calculated, not entered', (tester) async {
    await openSheet(tester);

    // Hours and minutes for each activity, and an amount for each cost — and
    // nothing else to type into.
    expect(find.byType(TextField), findsNWidgets(TimesheetActivity.values.length * 2 + TimesheetExpense.values.length));
    expect(find.text('Price'), findsNothing);
  });

  testWidgets('starts empty for a job with nothing logged', (tester) async {
    await openSheet(tester);

    for (final activity in TimesheetActivity.values) {
      expect(textOf(tester, hoursField(activity)), isEmpty);
      expect(textOf(tester, minutesField(activity)), isEmpty);
    }
    for (final expense in TimesheetExpense.values) {
      expect(textOf(tester, costField(expense)), isEmpty);
    }
    // No summaries until there's something to sum.
    expect(find.text('Net working time'), findsNothing);
    expect(find.text('Transportation'), findsNothing);
    expect(find.text('Price'), findsNothing);
  });

  testWidgets('starts from the saved entry when editing', (tester) async {
    await openSheet(
      tester,
      entry: sampleEntry(
        activities: {
          TimesheetActivity.inspection: 150,
          TimesheetActivity.reportPreparation: 20,
          TimesheetActivity.unpaidBreak: 60,
        },
        expenses: {TimesheetExpense.internalTransport: 5000, TimesheetExpense.externalTransport: 15050},
      ),
    );

    expect(textOf(tester, hoursField(TimesheetActivity.inspection)), '2');
    expect(textOf(tester, minutesField(TimesheetActivity.inspection)), '30');
    expect(textOf(tester, hoursField(TimesheetActivity.reportPreparation)), isEmpty);
    expect(textOf(tester, minutesField(TimesheetActivity.reportPreparation)), '20');
    expect(textOf(tester, hoursField(TimesheetActivity.unpaidBreak)), '1');
    expect(textOf(tester, minutesField(TimesheetActivity.unpaidBreak)), isEmpty);
    expect(textOf(tester, costField(TimesheetExpense.internalTransport)), '50');
    expect(textOf(tester, costField(TimesheetExpense.externalTransport)), '150.50');
  });

  testWidgets('will not save with nothing at all', (tester) async {
    await openSheet(tester);

    await tapSave(tester);

    expect(find.text('Enter the time spent or a transportation cost.'), findsOneWidget);
    expect(submissions, isEmpty);
  });

  testWidgets('rejects 60 or more minutes in any activity', (tester) async {
    await openSheet(tester);
    await enter(tester, TimesheetActivity.inspection, hours: '1');
    await enter(tester, TimesheetActivity.waiting, minutes: '75');

    await tapSave(tester);

    expect(find.text('Minutes must be between 0 and 59.'), findsOneWidget);
    expect(submissions, isEmpty);
  });

  testWidgets('saves time as minutes per activity and costs in piastres — and no price', (tester) async {
    await openSheet(tester);
    await enter(tester, TimesheetActivity.inspection, hours: '2', minutes: '30');
    await enter(tester, TimesheetActivity.reportPreparation, minutes: '20');
    await enter(tester, TimesheetActivity.waiting, hours: '1');
    await enter(tester, TimesheetActivity.unpaidBreak, hours: '1');
    await enterCost(tester, TimesheetExpense.internalTransport, '50');
    await enterCost(tester, TimesheetExpense.externalTransport, '150.50');

    await tapSave(tester);

    expect(submissions, hasLength(1));
    expect(submissions.single.activities, {
      TimesheetActivity.inspection: 150,
      TimesheetActivity.reportPreparation: 20,
      TimesheetActivity.waiting: 60,
      TimesheetActivity.unpaidBreak: 60,
    });
    expect(submissions.single.expenses, {
      TimesheetExpense.internalTransport: 5000,
      TimesheetExpense.externalTransport: 15050,
    });
    expect(sheetResult, isTrue);
    expect(find.byType(TimesheetEntrySheet), findsNothing);
  });

  testWidgets('leaves out activities and costs with nothing on them', (tester) async {
    await openSheet(tester);
    await enter(tester, TimesheetActivity.waiting, minutes: '15');
    await enter(tester, TimesheetActivity.reportPreparation, hours: '0', minutes: '0');
    await enterCost(tester, TimesheetExpense.internalTransport, '0');

    await tapSave(tester);

    expect(submissions.single.activities, {TimesheetActivity.waiting: 15});
    expect(submissions.single.expenses, isEmpty);
  });

  testWidgets('shows the live total, the break deducted, and the net working time', (tester) async {
    await openSheet(tester);
    await enter(tester, TimesheetActivity.inspection, hours: '4');
    await enter(tester, TimesheetActivity.reportPreparation, hours: '1');
    await enter(tester, TimesheetActivity.unpaidBreak, hours: '1');
    await tester.pump();

    expect(find.text('Total elapsed'), findsOneWidget);
    expect(find.text('6h'), findsOneWidget);
    expect(find.text('− 1h'), findsOneWidget);
    expect(find.text('Net working time'), findsOneWidget);
    expect(find.text('5h'), findsOneWidget);
  });

  testWidgets('costs never change the time summary', (tester) async {
    await openSheet(tester);
    await enter(tester, TimesheetActivity.inspection, hours: '2');
    await tester.pump();
    expect(find.text('2h'), findsNWidgets(2)); // total elapsed and net working time

    await enterCost(tester, TimesheetExpense.externalTransport, '300');
    await tester.pump();

    expect(find.text('2h'), findsNWidgets(2));
  });

  testWidgets('the time summary follows edits', (tester) async {
    await openSheet(tester);
    await enter(tester, TimesheetActivity.inspection, hours: '2');
    await tester.pump();
    expect(find.text('2h'), findsNWidgets(2));

    await enter(tester, TimesheetActivity.unpaidBreak, minutes: '30');
    await tester.pump();

    expect(find.text('2h 30m'), findsOneWidget);
    expect(find.text('− 30m'), findsOneWidget);
    expect(find.text('2h'), findsOneWidget);
  });

  group('the calculated price', () {
    testWidgets('is the net time at the hourly rate, shown with its working', (tester) async {
      await openSheet(tester);

      await enter(tester, TimesheetActivity.inspection, hours: '2', minutes: '30');
      await tester.pump();

      // 2.5 hours at EGP 150 an hour.
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('EGP 375.00'), findsOneWidget);
      expect(find.text('2h 30m × EGP 150.00 per hour'), findsOneWidget);
    });

    testWidgets('does not pay for the unpaid break', (tester) async {
      await openSheet(tester);

      await enter(tester, TimesheetActivity.inspection, hours: '4');
      await enter(tester, TimesheetActivity.unpaidBreak, hours: '1');
      await tester.pump();

      // 4 hours worked, not 5.
      expect(find.text('EGP 600.00'), findsOneWidget);
      expect(find.text('4h × EGP 150.00 per hour'), findsOneWidget);
    });

    testWidgets('follows the rate it is given', (tester) async {
      await openSheet(tester, hourlyRate: 20000);

      await enter(tester, TimesheetActivity.inspection, hours: '3');
      await tester.pump();

      expect(find.text('EGP 600.00'), findsOneWidget);
      expect(find.text('3h × EGP 200.00 per hour'), findsOneWidget);
    });

    testWidgets('keeps transportation separate: costs are added to the total, not the price', (tester) async {
      await openSheet(tester);
      await enter(tester, TimesheetActivity.inspection, hours: '1');

      await enterCost(tester, TimesheetExpense.internalTransport, '50');
      await enterCost(tester, TimesheetExpense.externalTransport, '150');
      await tester.pump();

      expect(find.text('EGP 150.00'), findsOneWidget); // the price, unchanged
      expect(find.text('Transportation'), findsOneWidget);
      expect(find.text('EGP 200.00'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('EGP 350.00'), findsOneWidget);
    });

    testWidgets('has no transportation or total line when nothing was spent on it', (tester) async {
      await openSheet(tester);

      await enter(tester, TimesheetActivity.inspection, hours: '1');
      await tester.pump();

      expect(find.text('Transportation'), findsNothing);
      expect(find.text('Total'), findsNothing);
    });

    testWidgets('says to set a rate when there is none, and prices at nothing', (tester) async {
      await openSheet(tester, hourlyRate: 0);

      await enter(tester, TimesheetActivity.inspection, hours: '2');
      await tester.pump();

      expect(find.text('Set your hourly rate on the Timesheet tab to price this entry.'), findsOneWidget);
      expect(find.text('EGP 0.00'), findsOneWidget);
      expect(find.textContaining('per hour'), findsNothing);
    });

    testWidgets('can still be saved without a rate', (tester) async {
      await openSheet(tester, hourlyRate: 0);
      await enter(tester, TimesheetActivity.inspection, hours: '2');

      await tapSave(tester);

      expect(submissions.single.activities, {TimesheetActivity.inspection: 120});
    });
  });

  testWidgets('time alone is enough', (tester) async {
    await openSheet(tester);
    await enter(tester, TimesheetActivity.inspection, minutes: '45');

    await tapSave(tester);

    expect(submissions, hasLength(1));
    expect(submissions.single.activities, {TimesheetActivity.inspection: 45});
    expect(submissions.single.expenses, isEmpty);
  });

  testWidgets('a transportation cost alone is enough', (tester) async {
    await openSheet(tester);
    await enterCost(tester, TimesheetExpense.externalTransport, '75.25');

    await tapSave(tester);

    expect(submissions, hasLength(1));
    expect(submissions.single.activities, isEmpty);
    expect(submissions.single.expenses, {TimesheetExpense.externalTransport: 7525});
  });

  testWidgets('stays open, ready to retry, when the save fails', (tester) async {
    saveSucceeds = false;
    await openSheet(tester);
    await enter(tester, TimesheetActivity.inspection, minutes: '30');

    await tapSave(tester);

    expect(find.byType(TimesheetEntrySheet), findsOneWidget);
    expect(sheetResult, isNull);

    saveSucceeds = true;
    await tapSave(tester);

    // Both attempts sent the same thing.
    expect(submissions, hasLength(2));
    expect(submissions.every((s) => s.activities.length == 1 && s.activities[TimesheetActivity.inspection] == 30), isTrue);
    expect(find.byType(TimesheetEntrySheet), findsNothing);
  });
}
