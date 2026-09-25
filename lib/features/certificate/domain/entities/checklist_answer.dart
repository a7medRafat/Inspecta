/// One checklist item's answer on a [Certificate] (Feature 05's inspection
/// certificate).
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
