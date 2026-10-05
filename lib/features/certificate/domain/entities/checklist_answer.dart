/// A Pass / Fail / N/A answer on a [Certificate] (Feature 05) — today just
/// the item's "Function check".
enum ChecklistAnswer {
  unanswered('unanswered'),
  pass('pass'),
  fail('fail'),
  na('na');

  final String value;

  const ChecklistAnswer(this.value);

  static ChecklistAnswer fromValue(Object? value) {
    for (final answer in values) {
      if (answer.value == value) return answer;
    }
    return ChecklistAnswer.unanswered;
  }
}
