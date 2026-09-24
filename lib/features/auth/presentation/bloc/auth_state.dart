part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Startup: we don't know yet whether a session exists.
final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

final class Authenticated extends AuthState {
  final AppUser user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

final class Unauthenticated extends AuthState {
  /// Why the user was signed out without asking (e.g. deactivated by an
  /// admin), shown once on the sign-in screen. `null` for a normal sign out.
  final AuthFailureCode? reason;

  const Unauthenticated({this.reason});

  @override
  List<Object?> get props => [reason];
}
