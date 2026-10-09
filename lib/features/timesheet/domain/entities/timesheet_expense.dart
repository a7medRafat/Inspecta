/// A cost an inspector incurred on a job, in money rather than time. An
/// entry records an amount against each, kept apart from the price the
/// inspector sets so the two stay distinguishable.
enum TimesheetExpense {
  internalTransport('internalTransportPiastres'),
  externalTransport('externalTransportPiastres');

  /// The Firestore field this expense's amount is stored under, in integer
  /// piastres (BR-03.10).
  final String field;

  const TimesheetExpense(this.field);
}
