import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/builder/flow_state.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/usecases/reset_password.dart';

/// Reset-link request. States: [StateType.loading] while sending,
/// [StateType.success] once sent, [StateType.error] with an
/// [AuthFailureCode] in `data`.
class ForgotPasswordCubit extends Cubit<FlowState> {
  final ResetPassword _resetPassword;

  ForgotPasswordCubit(this._resetPassword) : super(const FlowState());

  bool get isSending => state.type == StateType.loading;

  bool get isSent => state.type == StateType.success;

  AuthFailureCode? get failure =>
      state.type == StateType.error ? state.data as AuthFailureCode? : null;

  Future<void> submit({
    required String email,
    required String languageCode,
  }) async {
    if (isSending) return;
    emit(const FlowState(type: StateType.loading));
    try {
      await _resetPassword(email: email, languageCode: languageCode);
      if (!isClosed) emit(const FlowState(type: StateType.success));
    } on AuthFailure catch (f) {
      if (!isClosed) emit(FlowState(type: StateType.error, data: f.code));
    }
  }
}
