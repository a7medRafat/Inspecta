/// How the client answered a sent quotation (BR-03.6).
enum ClientResponseOutcome {
  counter('counter'),
  accepted('accepted'),
  declined('declined');

  final String value;

  const ClientResponseOutcome(this.value);

  static ClientResponseOutcome? fromValue(Object? value) {
    for (final outcome in values) {
      if (outcome.value == value) return outcome;
    }
    return null;
  }
}
