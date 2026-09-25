/// Business rules Feature 04's roster needs that the backend doesn't
/// track per-inspector yet — a flat rule applied to everyone rather than
/// a per-inspector setting, until there's a real field for it.
class CoordinatorConsts {
  CoordinatorConsts._();

  /// Jobs an inspector can be scheduled for on one day before their day
  /// reads as "fully booked" on the weekly calendar.
  static const int dailySlotCapacity = 4;

  /// The weekend (Egypt) — always "off" on the weekly calendar regardless
  /// of what's scheduled.
  static const List<int> weekendWeekdays = [DateTime.friday, DateTime.saturday];

  /// Feature 04 §5's "license expiring soon" warning window.
  static const Duration qualificationExpiryWarning = Duration(days: 30);

  /// The Schedule tab's day timeline (Feature 04 §5, scope-cut #1): the
  /// visible workday window and the nominal span drawn for each task
  /// block — there's no stored job duration, so every block reads as
  /// this fixed length starting at `scheduledAt`.
  static const int scheduleStartHour = 7;
  static const int scheduleEndHour = 19;
  static const double scheduleBlockHours = 2;
}
