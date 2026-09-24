import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/builder/flow_state.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/usecases/sign_in.dart';

/// Sign-in form submission. On success [AuthCubit] picks up the new
/// session and the app moves to the role home by itself.
///
/// States: [StateType.loading] while submitting, [StateType.error] with an
/// [AuthFailureCode] in `data`, [StateType.none] otherwise.
class SignInCubit extends Cubit<FlowState> {
  final SignIn _signIn;

  SignInCubit(this._signIn) : super(const FlowState());

  bool get isSubmitting => state.type == StateType.loading;

  AuthFailureCode? get failure =>
      state.type == StateType.error ? state.data as AuthFailureCode? : null;

  Future<void> submit({
    required String email,
    required String password,
    required bool keepSignedIn,
  }) async {
    if (isSubmitting) return;
    emit(const FlowState(type: StateType.loading));
    try {
      await _signIn(
        email: email,
        password: password,
        keepSignedIn: keepSignedIn,
      );
      // The page is usually gone by now: AuthCubit already switched to the
      // role home.
      if (!isClosed) emit(const FlowState(type: StateType.success));
    } on AuthFailure catch (f) {
      if (!isClosed) emit(FlowState(type: StateType.error, data: f.code));
    }
  }

  /// Shows a reason the session ended on its own (see
  /// [Unauthenticated.reason]).
  void showFailure(AuthFailureCode code) {
    if (isSubmitting) return;
    emit(FlowState(type: StateType.error, data: code));
  }

  void clearFailure() {
    if (state.type == StateType.error) emit(const FlowState());
  }
}
