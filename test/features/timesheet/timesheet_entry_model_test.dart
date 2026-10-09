import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspecta/features/timesheet/data/models/timesheet_entry_model.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_activity.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_entry_status.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_expense.dart';

import 'fake_timesheet_repository.dart';

void main() {
  group('TimesheetEntryModel', () {
    test('writes every activity and expense — zeros included — plus the net minutes', () {
      final entry = sampleEntry(
        requestId: 'REQ-9',
        activities: {
          TimesheetActivity.inspection: 240,
          TimesheetActivity.reportPreparation: 45,
          TimesheetActivity.unpaidBreak: 60,
        },
        expenses: {TimesheetExpense.externalTransport: 15050},
        pricePiastres: 450050,
        hourlyRatePiastres: 15000,
      );

      final json = TimesheetEntryModel.fromEntity(entry).toJson();

      expect(json, {
        'inspectorId': 'insp-1',
        // 240 + 45 worked; the break is deducted, not counted.
        'minutes': 285,
        'inspectionMinutes': 240,
        'reportMinutes': 45,
        'waitingMinutes': 0,
        'unpaidBreakMinutes': 60,
        'hourlyRatePiastres': 15000,
        'pricePiastres': 450050,
        'internalTransportPiastres': 0,
        'externalTransportPiastres': 15050,
        'status': 'pending',
      });
    });

    test('transportation is money, never minutes: it does not touch the time', () {
      final entry = sampleEntry(
        activities: {TimesheetActivity.inspection: 120},
        expenses: {TimesheetExpense.internalTransport: 5000, TimesheetExpense.externalTransport: 20000},
      );

      final json = TimesheetEntryModel.fromEntity(entry).toJson();

      expect(json['minutes'], 120);
      expect(json.keys, isNot(contains('internalTransportMinutes')));
      expect(json.keys, isNot(contains('externalTransportMinutes')));
    });

    test('round-trips an entry without repeating the doc id in the body', () {
      final entry = sampleEntry(
        requestId: 'REQ-9',
        activities: {TimesheetActivity.inspection: 150, TimesheetActivity.waiting: 20},
        expenses: {TimesheetExpense.internalTransport: 7550},
        pricePiastres: 450050,
        hourlyRatePiastres: 15000,
      );

      final json = TimesheetEntryModel.fromEntity(entry).toJson();

      expect(TimesheetEntryModel.fromJson('REQ-9', json).toEntity(), entry);
    });

    test('an inspector\'s write always resubmits for review and never carries review fields', () {
      final reviewed = sampleEntry(
        status: TimesheetEntryStatus.returned,
        reviewNote: 'Too high',
        reviewerName: 'Mona',
        reviewedAt: DateTime(2026, 10, 9),
      );

      final json = TimesheetEntryModel.fromEntity(reviewed).toJson();

      expect(json['status'], 'pending');
      expect(json.keys.toSet().intersection({'reviewNote', 'reviewedBy', 'reviewerName', 'reviewedAt'}), isEmpty);
    });

    test('reads each activity and expense back from its own field', () {
      final model = TimesheetEntryModel.fromJson('REQ-1', {
        'inspectorId': 'insp-1',
        'minutes': 75,
        'inspectionMinutes': 60,
        'reportMinutes': 15,
        'waitingMinutes': 0,
        'unpaidBreakMinutes': 30,
        'pricePiastres': 0,
        'internalTransportPiastres': 4000,
        'externalTransportPiastres': 0,
      });

      expect(model.activities, {
        TimesheetActivity.inspection: 60,
        TimesheetActivity.reportPreparation: 15,
        TimesheetActivity.unpaidBreak: 30,
      });
      expect(model.expenses, {TimesheetExpense.internalTransport: 4000});
      expect(model.toEntity().minutes, 75);
    });

    test('reads the hourly rate the price was worked out at', () {
      final model = TimesheetEntryModel.fromJson('REQ-1', {
        'inspectorId': 'insp-1',
        'inspectionMinutes': 120,
        'hourlyRatePiastres': 17550,
        'pricePiastres': 35100,
      });

      expect(model.hourlyRatePiastres, 17550);
      expect(model.toEntity().hourlyRatePiastres, 17550);
    });

    test('an entry from before rates reads as having none', () {
      final model = TimesheetEntryModel.fromJson('REQ-1', {
        'inspectorId': 'insp-1',
        'minutes': 90,
        'pricePiastres': 450000,
      });

      expect(model.hourlyRatePiastres, 0);
      // Its typed-in price is still what it was.
      expect(model.pricePiastres, 450000);
    });

    test('an entry saved with only a total reads as inspection time', () {
      final model = TimesheetEntryModel.fromJson('REQ-1', {
        'inspectorId': 'insp-1',
        'minutes': 90,
        'pricePiastres': 450000,
      });

      expect(model.activities, {TimesheetActivity.inspection: 90});
      expect(model.expenses, isEmpty);
      expect(model.toEntity().minutes, 90);
    });

    test('ignores the transport minutes an earlier version wrote', () {
      final model = TimesheetEntryModel.fromJson('REQ-1', {
        'inspectorId': 'insp-1',
        'minutes': 150,
        'inspectionMinutes': 120,
        'internalTransportMinutes': 20,
        'externalTransportMinutes': 10,
        'pricePiastres': 0,
      });

      expect(model.activities, {TimesheetActivity.inspection: 120});
      expect(model.expenses, isEmpty);
    });

    test('reads the coordinator\'s review', () {
      final reviewedAt = DateTime.utc(2026, 10, 9, 12);
      final model = TimesheetEntryModel.fromJson('REQ-1', {
        'inspectorId': 'insp-1',
        'inspectionMinutes': 90,
        'pricePiastres': 450000,
        'status': 'returned',
        'reviewNote': 'Too high',
        'reviewedBy': 'coord-1',
        'reviewerName': 'Mona',
        'reviewedAt': Timestamp.fromDate(reviewedAt),
      });

      final entry = model.toEntity();

      expect(entry.status, TimesheetEntryStatus.returned);
      expect(entry.reviewNote, 'Too high');
      expect(entry.reviewedBy, 'coord-1');
      expect(entry.reviewerName, 'Mona');
      // `Timestamp.toDate()` is local time; `==` also compares the UTC flag.
      expect(entry.reviewedAt!.isAtSameMomentAs(reviewedAt), isTrue);
    });

    test('reads whole numbers Firestore returned as doubles', () {
      final model = TimesheetEntryModel.fromJson('REQ-1', {
        'inspectorId': 'insp-1',
        'inspectionMinutes': 90.0,
        'externalTransportPiastres': 12000.0,
        'pricePiastres': 450000.0,
      });

      expect(model.activities, {TimesheetActivity.inspection: 90});
      expect(model.expenses, {TimesheetExpense.externalTransport: 12000});
      expect(model.pricePiastres, 450000);
    });

    test('treats missing numbers as nothing logged', () {
      final model = TimesheetEntryModel.fromJson('REQ-1', {'inspectorId': 'insp-1'});

      expect(model.activities, isEmpty);
      expect(model.expenses, isEmpty);
      expect(model.pricePiastres, 0);
    });

    test('an entry logged before review existed reads as pending', () {
      final model = TimesheetEntryModel.fromJson('REQ-1', {
        'inspectorId': 'insp-1',
        'minutes': 90,
        'pricePiastres': 450000,
      });

      expect(model.toEntity().status, TimesheetEntryStatus.pending);
    });
  });

  group('TimesheetEntryStatus.fromValue', () {
    test('maps each stored value, and anything else to pending', () {
      expect(TimesheetEntryStatus.fromValue('pending'), TimesheetEntryStatus.pending);
      expect(TimesheetEntryStatus.fromValue('approved'), TimesheetEntryStatus.approved);
      expect(TimesheetEntryStatus.fromValue('returned'), TimesheetEntryStatus.returned);
      expect(TimesheetEntryStatus.fromValue('something-new'), TimesheetEntryStatus.pending);
      expect(TimesheetEntryStatus.fromValue(null), TimesheetEntryStatus.pending);
    });
  });

  group('TimesheetEntry', () {
    test('only an approved entry is locked', () {
      expect(sampleEntry(status: TimesheetEntryStatus.pending).isEditable, isTrue);
      expect(sampleEntry(status: TimesheetEntryStatus.returned).isEditable, isTrue);
      expect(sampleEntry(status: TimesheetEntryStatus.approved).isEditable, isFalse);
    });

    test('net working time is everything logged less the unpaid break', () {
      final entry = sampleEntry(
        activities: {
          TimesheetActivity.inspection: 330,
          TimesheetActivity.reportPreparation: 60,
          TimesheetActivity.waiting: 15,
          TimesheetActivity.unpaidBreak: 60,
        },
      );

      expect(entry.elapsedMinutes, 465);
      expect(entry.unpaidBreakMinutes, 60);
      expect(entry.minutes, 405);
    });

    test('a break alone leaves no working time, and never a negative one', () {
      final entry = sampleEntry(activities: {TimesheetActivity.unpaidBreak: 45});

      expect(entry.minutes, 0);
      expect(entry.hasTime, isTrue);
    });

    test('costs are added up apart from the price, and make the total', () {
      final entry = sampleEntry(
        pricePiastres: 300000,
        expenses: {TimesheetExpense.internalTransport: 5000, TimesheetExpense.externalTransport: 20050},
      );

      expect(entry.pricePiastres, 300000);
      expect(entry.expensesPiastres, 25050);
      expect(entry.totalPiastres, 325050);
      expect(entry.hasExpenses, isTrue);
    });

    test('an entry with no costs totals just its price', () {
      final entry = sampleEntry(pricePiastres: 300000);

      expect(entry.hasExpenses, isFalse);
      expect(entry.totalPiastres, 300000);
    });

    test('only an unpaid break is unpaid', () {
      expect(
        TimesheetActivity.values.where((a) => !a.isPaid),
        [TimesheetActivity.unpaidBreak],
      );
    });

    test('no two activities or expenses share a field', () {
      final fields = [
        ...TimesheetActivity.values.map((a) => a.field),
        ...TimesheetExpense.values.map((e) => e.field),
      ];

      expect(fields.toSet(), hasLength(fields.length));
    });
  });
}
