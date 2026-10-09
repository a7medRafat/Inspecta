/// Where a logged entry stands with the coordinator who reviews it.
enum TimesheetEntryStatus {
  /// Saved by the inspector, waiting on a coordinator — also what every
  /// save puts an entry back to, including after a return.
  pending('pending'),

  /// A coordinator accepted the time and price. Locked: the inspector can
  /// no longer change it.
  approved('approved'),

  /// A coordinator sent it back with a note; the inspector fixes it and
  /// saves again, which makes it [pending] once more.
  returned('returned');

  final String value;

  const TimesheetEntryStatus(this.value);

  /// An unknown or missing value reads as [pending]: entries logged before
  /// review existed have no status, and they're awaiting review like any
  /// other.
  static TimesheetEntryStatus fromValue(Object? value) {
    for (final status in values) {
      if (status.value == value) return status;
    }
    return pending;
  }
}
