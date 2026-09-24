/// Base type for the expected errors a repository throws. Presentation code
/// catches [Failure]s and shows a message; anything else is a bug.
abstract class Failure implements Exception {
  const Failure();
}
