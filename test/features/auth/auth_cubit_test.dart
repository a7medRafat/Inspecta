import 'package:flutter_test/flutter_test.dart';
import 'package:inspecta/core/builder/flow_state.dart';
import 'package:inspecta/features/auth/domain/entities/auth_failure.dart';
import 'package:inspecta/features/auth/domain/usecases/get_current_user.dart';
import 'package:inspecta/features/auth/domain/usecases/reset_password.dart';
import 'package:inspecta/features/auth/domain/usecases/sign_in.dart';
import 'package:inspecta/features/auth/domain/usecases/sign_out.dart';
import 'package:inspecta/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:inspecta/features/auth/presentation/bloc/forgot_password_cubit.dart';
import 'package:inspecta/features/auth/presentation/bloc/sign_in_cubit.dart';

import 'fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repo;

  setUp(() => repo = FakeAuthRepository());

  group('AuthCubit', () {
    late AuthCubit cubit;

    setUp(() async {
      cubit = AuthCubit(GetCurrentUser(repo), SignOut(repo));
      await cubit.start();
    });

    tearDown(() => cubit.close());

    test('starts unknown, then follows the session', () async {
      expect(cubit.state, const AuthUnknown());

      repo.session.add(null);
      await pumpEventQueue();
      expect(cubit.state, const Unauthenticated());

      repo.session.add(inspector);
      await pumpEventQueue();
      expect(cubit.state, const Authenticated(inspector));
      expect(cubit.user, inspector);
    });

    test('a forced sign out carries its reason to the sign-in screen', () async {
      repo.session.add(inspector);
      await pumpEventQueue();

      // What the repository emits when an admin deactivates the user.
      repo.session.addError(const AuthFailure(AuthFailureCode.accountDisabled));
      repo.session.add(null);
      await pumpEventQueue();

      expect(
        cubit.state,
        const Unauthenticated(reason: AuthFailureCode.accountDisabled),
      );
    });

    test('a normal sign out has no reason', () async {
      repo.session.add(inspector);
      await pumpEventQueue();

      await cubit.signOut();
      await pumpEventQueue();

      expect(repo.signOutCalls, 1);
      expect(cubit.state, const Unauthenticated());
    });
  });

  group('SignInCubit', () {
    test('trims the email and forwards keepSignedIn', () async {
      final cubit = SignInCubit(SignIn(repo));
      await cubit.submit(
        email: '  karim.adel@company.com ',
        password: 'secret',
        keepSignedIn: false,
      );

      expect(repo.signInCalls.single.email, 'karim.adel@company.com');
      expect(repo.signInCalls.single.keep, isFalse);
      expect(cubit.state.type, StateType.success);
    });

    test('exposes the failure code', () async {
      repo.signInFailure = const AuthFailure(
        AuthFailureCode.invalidCredentials,
      );
      final cubit = SignInCubit(SignIn(repo));
      await cubit.submit(email: 'a@b.co', password: 'x', keepSignedIn: true);

      expect(cubit.failure, AuthFailureCode.invalidCredentials);
      cubit.clearFailure();
      expect(cubit.failure, isNull);
    });
  });

  group('ForgotPasswordCubit', () {
    test('marks the link as sent', () async {
      final cubit = ForgotPasswordCubit(ResetPassword(repo));
      await cubit.submit(email: 'karim.adel@company.com', languageCode: 'en');

      expect(repo.resetCalls, ['karim.adel@company.com']);
      expect(cubit.isSent, isTrue);
    });

    test('exposes the failure code', () async {
      repo.resetFailure = const AuthFailure(AuthFailureCode.network);
      final cubit = ForgotPasswordCubit(ResetPassword(repo));
      await cubit.submit(email: 'a@b.co', languageCode: 'en');

      expect(cubit.isSent, isFalse);
      expect(cubit.failure, AuthFailureCode.network);
    });
  });
}
