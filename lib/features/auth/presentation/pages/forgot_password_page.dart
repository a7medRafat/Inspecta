import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/builder/flow_state.dart';
import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_notice.dart';
import '../../../../core/shared/m_primary_button.dart';
import '../../../../core/shared/m_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/forgot_password_cubit.dart';
import '../widgets/auth_labels.dart';

/// US-01.3: request a password reset link by email.
class ForgotPasswordPage extends StatelessWidget {
  /// Pre-filled from whatever was typed on the sign-in screen.
  final String initialEmail;

  const ForgotPasswordPage({super.key, this.initialEmail = ''});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ForgotPasswordCubit>(),
      child: _ForgotPasswordView(initialEmail: initialEmail),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  final String initialEmail;

  const _ForgotPasswordView({required this.initialEmail});

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  late final _emailController = TextEditingController(
    text: widget.initialEmail,
  );
  bool _submitted = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validate(AppLocalizations t) {
    final email = _emailController.text.trim();
    _emailError = email.isEmpty
        ? t.errorEmailRequired
        : !Validators.isEmail(email)
        ? t.errorEmailInvalid
        : null;
  }

  void _submit() {
    final t = AppLocalizations.of(context)!;
    setState(() {
      _submitted = true;
      _validate(t);
    });
    if (_emailError != null) return;

    FocusScope.of(context).unfocus();
    context.read<ForgotPasswordCubit>().submit(
      email: _emailController.text,
      languageCode: Localizations.localeOf(context).languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildForm(t)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(t.rememberedIt, style: AppTextStyles.subtitle),
                        TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColours.primaryDark,
                            textStyle: AppTextStyles.link,
                            minimumSize: const Size(44, 44),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          child: Text(t.backToSignIn),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations t) {
    return BlocBuilder<ForgotPasswordCubit, FlowState>(
      builder: (context, state) {
        final cubit = context.read<ForgotPasswordCubit>();
        final failure = cubit.failure;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColours.primarySoft,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  size: 34,
                  color: AppColours.primaryDark,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                t.resetTitle,
                style: AppTextStyles.pageTitle.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(t.resetSubtitle, style: AppTextStyles.body),
              const SizedBox(height: 22),
              MTextField(
                controller: _emailController,
                label: t.workEmail,
                hintText: t.emailHint,
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.send,
                autofillHints: const [AutofillHints.email],
                enabled: !cubit.isSending,
                errorText: _emailError,
                onChanged: (_) {
                  if (_submitted) setState(() => _validate(t));
                },
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 22),
              MPrimaryButton(
                label: cubit.isSent ? t.resendResetLink : t.sendResetLink,
                loading: cubit.isSending,
                onPressed: _submit,
              ),
              if (cubit.isSent) ...[
                const SizedBox(height: 22),
                MNotice(
                  type: MNoticeType.success,
                  title: t.checkInboxTitle,
                  message: t.checkInboxMessage,
                ),
              ],
              if (failure != null) ...[
                const SizedBox(height: 22),
                MNotice(type: MNoticeType.error, message: failure.message(t)),
              ],
            ],
          ),
        );
      },
    );
  }
}
