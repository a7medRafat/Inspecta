import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_out.dart';

part 'auth_state.dart';

/// App-wide session state. The app's root reads it to choose between the
/// sign-in flow and the signed-in user's role home.
class AuthCubit extends Cubit<AuthState> {
  final GetCurrentUser _getCurrentUser;
  final SignOut _signOut;

  StreamSubscription<AppUser?>? _subscription;
  AuthFailureCode? _pendingReason;

  AuthCubit(this._getCurrentUser, this._signOut) : super(const AuthUnknown());

  AppUser? get user => switch (state) {
    Authenticated(:final user) => user,
    _ => null,
  };

  /// Starts listening to the session. Safe to call more than once.
  Future<void> start() async {
    if (_subscription != null) return;
    try {
      await _getCurrentUser.applySessionPolicy();
    } on AuthFailure catch (failure) {
      _pendingReason = failure.code;
    }
    _subscription = _getCurrentUser.watch().listen(
      (user) {
        if (user == null) {
          emit(Unauthenticated(reason: _pendingReason));
        } else {
          emit(Authenticated(user));
        }
        _pendingReason = null;
      },
      onError: (Object error) {
        _pendingReason = error is AuthFailure
            ? error.code
            : AuthFailureCode.unknown;
      },
    );
  }

  Future<void> signOut() async {
    try {
      await _signOut();
    } on AuthFailure {
      // The local session is cleared even if the network call fails, and
      // the watch stream emits the signed-out state either way.
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
