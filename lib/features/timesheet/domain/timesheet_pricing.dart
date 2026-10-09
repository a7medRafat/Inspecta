/// How an entry's price is worked out. The price is never typed in: it is
/// the net working time at the inspector's hourly rate.
///
/// firestore.rules enforces this same formula on every save, so the two
/// must stay in step — change one and the other has to change with it.
class TimesheetPricing {
  TimesheetPricing._();

  static const minutesPerHour = 60;

  /// [netMinutes] at [hourlyRatePiastres] an hour, in piastres, rounded half
  /// up to the whole piastre (BR-03.10). Done in whole numbers — no
  /// floating point — so the app and the rules always agree to the
  /// piastre.
  ///
  /// [netMinutes] is working time: the unpaid break is already deducted.
  /// Transportation costs are not part of it — they're a separate cost.
  static int priceFor({required int netMinutes, required int hourlyRatePiastres}) {
    if (netMinutes <= 0 || hourlyRatePiastres <= 0) return 0;
    return (netMinutes * hourlyRatePiastres + minutesPerHour ~/ 2) ~/ minutesPerHour;
  }
}
