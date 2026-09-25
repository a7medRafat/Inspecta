/// A certificate's final verdict (Feature 05's inspection certificate,
/// step 5).
enum CertificateResult {
  safeToOperate('safe_to_operate'),
  safeWithConditions('safe_with_conditions'),
  notSafe('not_safe');

  final String value;

  const CertificateResult(this.value);

  static CertificateResult? fromValue(Object? value) {
    for (final result in values) {
      if (result.value == value) return result;
    }
    return null;
  }
}
