/// One way an inspector's time on a job was spent. An entry records minutes
/// against each. Money — transportation costs — is recorded separately, as a
/// `TimesheetExpense`.
enum TimesheetActivity {
  inspection('inspectionMinutes'),
  reportPreparation('reportMinutes'),
  waiting('waitingMinutes'),
  unpaidBreak('unpaidBreakMinutes');

  /// The Firestore field this activity's minutes are stored under.
  final String field;

  const TimesheetActivity(this.field);

  /// Everything counts towards the inspector's working time except an
  /// unpaid break, which is deducted from it.
  bool get isPaid => this != unpaidBreak;
}
