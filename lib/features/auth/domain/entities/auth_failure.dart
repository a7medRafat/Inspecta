import '../../../../core/error/failure.dart';

enum AuthFailureCode {
  invalidEmail,
  invalidCredentials,

  /// The user's profile has `active: false` (BR-01.4), or Firebase has
  /// disabled the account.
  accountDisabled,

  /// Signed in to Firebase, but there is no `users/{uid}` profile with a
  /// valid role, so we can't pick a home screen.
  noProfile,
  tooManyAttempts,
  network,

  /// Firebase isn't initialised (e.g. `flutterfire configure` not run yet).
  unavailable,
  unknown,
}

class AuthFailure extends Failure {
  final AuthFailureCode code;

  const AuthFailure(this.code);

  @override
  String toString() => 'AuthFailure(${code.name})';
}
