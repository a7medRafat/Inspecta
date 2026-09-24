/// How an [InspectionRequest] entered the system (BR-02.1, US-02.5).
enum RequestSource {
  email('email'),
  manual('manual');

  final String value;

  const RequestSource(this.value);

  static RequestSource fromValue(Object? value) {
    for (final source in values) {
      if (source.value == value) return source;
    }
    // A request always has a source; email is intake's default path.
    return RequestSource.email;
  }
}
