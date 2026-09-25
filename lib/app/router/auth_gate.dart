import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/home/presentation/pages/coordinator_root_page.dart';
import '../../features/home/presentation/pages/inspector_root_page.dart';
import '../../features/home/presentation/pages/role_home_page.dart';
import '../../features/home/presentation/pages/supervisor_root_page.dart';
import '../../features/splash/presentation/views/splash_screen.dart';

/// Root route: splash while the session is unknown, sign in when signed
/// out, the role home when signed in.
///
/// Any screens pushed on top (forgot password, profile, ...) are popped
/// whenever the session changes, so signing out — or being signed out by a
/// deactivation — always lands back on the sign-in screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static bool _sessionChanged(AuthState previous, AuthState current) {
    if (previous.runtimeType != current.runtimeType) return true;
    return previous is Authenticated &&
        current is Authenticated &&
        (previous.user.id != current.user.id ||
            previous.user.role != current.user.role);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: _sessionChanged,
      listener: (context, _) =>
          Navigator.of(context).popUntil((route) => route.isFirst),
      buildWhen: _sessionChanged,
      builder: (context, state) => switch (state) {
        AuthUnknown() => const SplashScreen(),
        Unauthenticated() => const SignInPage(),
        Authenticated(:final user) => KeyedSubtree(
          key: ValueKey((user.id, user.role)),
          child: switch (user.role) {
            UserRole.supervisor => const SupervisorRootPage(),
            UserRole.coordinator => const CoordinatorRootPage(),
            UserRole.inspector => const InspectorRootPage(),
            _ => const RoleHomePage(),
          },
        ),
      },
    );
  }
}
