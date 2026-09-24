import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/builder/flow_state.dart';
import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_notice.dart';
import '../../../../core/shared/m_password_field.dart';
import '../../../../core/shared/m_primary_button.dart';
import '../../../../core/shared/m_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/sign_in_cubit.dart';
import '../widgets/auth_labels.dart';
import 'forgot_password_page.dart';

/// US-01.1 / US-01.2: email + password sign in with "Keep me signed in".
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SignInCubit>(),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatefulWidget {
  const _SignInView();

  @override
  State<_SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<_SignInView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _keepSignedIn = true;

  /// Field errors appear only after the first submit, then update live.
  bool _submitted = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is Unauthenticated && authState.reason != null) {
      context.read<SignInCubit>().showFailure(authState.reason!);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validate(AppLocalizations t) {
    final email = _emailController.text.trim();
    _emailError = email.isEmpty
        ? t.errorEmailRequired
        : !Validators.isEmail(email)
        ? t.errorEmailInvalid
        : null;
    _passwordError = _passwordController.text.isEmpty
        ? t.errorPasswordRequired
        : null;
  }

  void _onChanged(String _) {
    context.read<SignInCubit>().clearFailure();
    if (_submitted) setState(() => _validate(AppLocalizations.of(context)!));
  }

  void _submit() {
    final t = AppLocalizations.of(context)!;
    setState(() {
      _submitted = true;
      _validate(t);
    });
    if (_emailError != null || _passwordError != null) return;

    FocusScope.of(context).unfocus();
    TextInput.finishAutofillContext();
    context.read<SignInCubit>().submit(
      email: _emailController.text,
      password: _passwordController.text,
      keepSignedIn: _keepSignedIn,
    );
  }

  void _openForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ForgotPasswordPage(initialEmail: _emailController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (_, current) =>
          current is Unauthenticated && current.reason != null,
      listener: (context, state) => context.read<SignInCubit>().showFailure(
        (state as Unauthenticated).reason!,
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    const _Header(),
                    Expanded(child: _buildForm(t)),
                    SafeArea(
                      top: false,
                      minimum: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                      child: Text(
                        t.noAccount,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations t) {
    return BlocBuilder<SignInCubit, FlowState>(
      builder: (context, state) {
        final cubit = context.read<SignInCubit>();
        final submitting = cubit.isSubmitting;
        final failure = cubit.failure;

        return Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (failure != null) ...[
                  MNotice(type: MNoticeType.error, message: failure.message(t)),
                  const SizedBox(height: 18),
                ],

                const SizedBox(height: 8),

                MTextField(
                  controller: _emailController,
                  label: t.workEmail,
                  hintText: t.emailHint,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.email,
                    AutofillHints.username,
                  ],
                  enabled: !submitting,
                  errorText: _emailError,
                  onChanged: _onChanged,
                ),
                const SizedBox(height: 18),
                MPasswordField(
                  controller: _passwordController,
                  label: t.password,
                  enabled: !submitting,
                  errorText: _passwordError,
                  onChanged: _onChanged,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _KeepSignedInCheckbox(
                        value: _keepSignedIn,
                        label: t.keepMeSignedIn,
                        onChanged: submitting
                            ? null
                            : (v) => setState(() => _keepSignedIn = v),
                      ),
                    ),
                    TextButton(
                      onPressed: submitting ? null : _openForgotPassword,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColours.primaryDark,
                        textStyle: AppTextStyles.link,
                        minimumSize: const Size(44, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: Text(t.forgotPassword),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                MPrimaryButton(
                  label: t.signIn,
                  loading: submitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(28, math.max(56, topInset + 32), 28, 64),
      decoration: const BoxDecoration(
        color: AppColours.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColours.ink.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              size: 34,
              color: AppColours.primaryDark,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            t.signInTitle,
            style: AppTextStyles.pageTitle.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            t.signInSubtitle,
            style: AppTextStyles.body.copyWith(
              color: AppColours.onPrimaryMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeepSignedInCheckbox extends StatelessWidget {
  final bool value;
  final String label;
  final ValueChanged<bool>? onChanged;

  const _KeepSignedInCheckbox({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged == null ? null : (v) => onChanged!(v!),
                activeColor: AppColours.primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColours.inkBody,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
