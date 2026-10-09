import 'package:flutter_test/flutter_test.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_activity.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_entry.dart';
import 'package:inspecta/features/timesheet/domain/entities/timesheet_expense.dart';
import 'package:inspecta/features/timesheet/domain/timesheet_pricing.dart';

// An EGP 150 hourly rate, in piastres.
const _rate150 = 15000;

int _price(int netMinutes, int rate) => TimesheetPricing.priceFor(netMinutes: netMinutes, hourlyRatePiastres: rate);

void main() {
  group('TimesheetPricing.priceFor', () {
    test('is the time at the hourly rate: 8.5 h at EGP 150 is EGP 1,275', () {
      expect(_price(510, _rate150), 127500);
    });

    test('whole hours are the rate times the hours', () {
      expect(_price(60, _rate150), 15000);
      expect(_price(480, _rate150), 120000);
    });

    test('part hours are prorated by the minute', () {
      expect(_price(30, _rate150), 7500);
      expect(_price(45, _rate150), 11250);
      expect(_price(1, _rate150), 250);
    });

    test('rounds half up to the piastre', () {
      // 1 minute at 1.50 an hour is exactly 2.5 piastres: up to 3.
      expect(_price(1, 150), 3);
      // 1 minute at 1.49 an hour is 2.483…: down to 2.
      expect(_price(1, 149), 2);
      // 7 minutes at 1.00 an hour is 11.666…: up to 12.
      expect(_price(7, 100), 12);
    });

    test('is nothing without time, or without a rate', () {
      expect(_price(0, _rate150), 0);
      expect(_price(-30, _rate150), 0);
      expect(_price(120, 0), 0);
      expect(_price(0, 0), 0);
    });

    test('stays exact for long months of work, with no floating-point drift', () {
      // 300 hours at EGP 1,234.56 an hour.
      expect(_price(300 * 60, 123456), 37036800);
    });
  });

  group('TimesheetEntry.priced', () {
    TimesheetEntry priced(Map<TimesheetActivity, int> activities, {int rate = _rate150, Map<TimesheetExpense, int>? expenses}) =>
        TimesheetEntry.priced(
          requestId: 'REQ-1',
          inspectorId: 'insp-1',
          activities: activities,
          expenses: expenses ?? const {},
          hourlyRatePiastres: rate,
        );

    test('prices the net working time — the unpaid break is not paid for', () {
      final entry = priced({
        TimesheetActivity.inspection: 330,
        TimesheetActivity.reportPreparation: 60,
        TimesheetActivity.unpaidBreak: 60,
      });

      // 330 + 60 worked, at EGP 150 an hour.
      expect(entry.minutes, 390);
      expect(entry.pricePiastres, 97500);
    });

    test('records the rate it was priced with, so a later change does not rewrite it', () {
      final entry = priced({TimesheetActivity.inspection: 120}, rate: 20000);

      expect(entry.hourlyRatePiastres, 20000);
      expect(entry.pricePiastres, 40000);
    });

    test('every paid activity is paid at the same rate', () {
      final entry = priced({
        TimesheetActivity.inspection: 60,
        TimesheetActivity.reportPreparation: 60,
        TimesheetActivity.waiting: 60,
      });

      expect(entry.pricePiastres, 3 * _rate150);
    });

    test('a break alone earns nothing', () {
      expect(priced({TimesheetActivity.unpaidBreak: 90}).pricePiastres, 0);
    });

    test('transportation is not priced by the hour: it adds nothing to the price', () {
      final entry = priced(
        {TimesheetActivity.inspection: 60},
        expenses: {TimesheetExpense.internalTransport: 5000, TimesheetExpense.externalTransport: 20000},
      );

      expect(entry.pricePiastres, _rate150);
      expect(entry.expensesPiastres, 25000);
      expect(entry.totalPiastres, _rate150 + 25000);
    });

    test('has no price until a rate is set', () {
      final entry = priced({TimesheetActivity.inspection: 240}, rate: 0);

      expect(entry.pricePiastres, 0);
      expect(entry.hourlyRatePiastres, 0);
      expect(entry.minutes, 240);
    });
  });
}
