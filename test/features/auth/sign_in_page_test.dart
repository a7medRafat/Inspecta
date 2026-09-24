import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspecta/features/auth/domain/entities/auth_failure.dart';
import 'package:inspecta/features/auth/domain/usecases/get_current_user.dart';
import 'package:inspecta/features/auth/domain/usecases/sign_in.dart';
import 'package:inspecta/features/auth/domain/usecases/sign_out.dart';
import 'package:inspecta/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:inspecta/features/auth/presentation/bloc/sign_in_cubit.dart';
import 'package:inspecta/features/auth/presentation/pages/sign_in_page.dart';
import 'package:inspecta/injection.dart';
import 'package:inspecta/l10n/app_localizations.dart';

import 'fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repo;
  late AuthCubit authCubit;

  setUp(() {
    repo = FakeAuthRepository();
    authCubit = AuthCubit(GetCurrentUser(repo), SignOut(repo));
    getIt.registerFactory(() => SignInCubit(SignIn(repo)));
  });

  tearDown(() async {
    await authCubit.close();
    await getIt.reset();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    // A phone-sized screen, like the mockup.
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BlocProvider.value(
        value: authCubit,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SignInPage(),
        ),
      ),
    );
  }

  Finder field(int index) => find.byType(TextField).at(index);

  testWidgets('shows field errors instead of submitting empty fields', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Enter your work email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(repo.signInCalls, isEmpty);

    await tester.enterText(field(0), 'not-an-email');
    await tester.pump();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('submits valid credentials with "keep me signed in"', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.enterText(field(0), 'karim.adel@company.com');
    await tester.enterText(field(1), 'secret');
    await tester.tap(find.text('Keep me signed in'));
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(repo.signInCalls.single.email, 'karim.adel@company.com');
    expect(repo.signInCalls.single.password, 'secret');
    expect(repo.signInCalls.single.keep, isFalse);
  });

  testWidgets('shows the server error', (tester) async {
    repo.signInFailure = const AuthFailure(AuthFailureCode.tooManyAttempts);
    await pumpPage(tester);

    await tester.enterText(field(0), 'karim.adel@company.com');
    await tester.enterText(field(1), 'wrong');
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(
      find.text('Too many failed attempts. Wait a few minutes and try again.'),
      findsOneWidget,
    );
  });
}
