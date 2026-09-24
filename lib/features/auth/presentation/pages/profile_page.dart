import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_back_button.dart';
import '../../../../core/shared/m_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';
import '../bloc/auth_cubit.dart';
import '../widgets/auth_labels.dart';

/// Name, role, contact details and sign out.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(t.signOutConfirmTitle),
        content: Text(t.signOutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColours.errorIcon),
            child: Text(t.signOut),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthCubit>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = context.select((AuthCubit cubit) => cubit.user);

    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: user == null
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                children: [
                  Row(
                    children: [
                      const MBackButton(),
                      const SizedBox(width: 12),
                      Text(
                        t.profile,
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _IdentityCard(user: user),
                  const SizedBox(height: 16),
                  _DetailsCard(user: user),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmSignOut(context),
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: Text(t.signOut),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColours.errorIcon,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColours.border),
                        textStyle: AppTextStyles.buttonLabel,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final AppUser user;

  const _IdentityCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return MCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColours.primarySoft,
            child: Text(
              user.initials,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColours.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColours.primarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              user.role.label(t),
              style: AppTextStyles.badge.copyWith(
                color: AppColours.primaryDark,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final AppUser user;

  const _DetailsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final phone = user.phone?.trim() ?? '';
    final showQualifications = user.role == UserRole.inspector;

    return MCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.mail_outline_rounded,
            label: t.email,
            child: Text(user.email, style: AppTextStyles.emphasis),
          ),
          const Divider(height: 1, color: AppColours.surfaceMuted),
          _DetailRow(
            icon: Icons.phone_outlined,
            label: t.phone,
            child: Text(
              phone.isEmpty ? t.notSet : phone,
              textDirection: TextDirection.ltr,
              style: phone.isEmpty
                  ? AppTextStyles.emphasis.copyWith(color: AppColours.inkMuted)
                  : AppTextStyles.emphasis,
            ),
          ),
          if (showQualifications) ...[
            const Divider(height: 1, color: AppColours.surfaceMuted),
            _DetailRow(
              icon: Icons.workspace_premium_outlined,
              label: t.qualifications,
              child: user.qualifications.isEmpty
                  ? Text(
                      t.notSet,
                      style: AppTextStyles.emphasis.copyWith(
                        color: AppColours.inkMuted,
                      ),
                    )
                  : Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final q in user.qualifications)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColours.surfaceMuted,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              q,
                              style: AppTextStyles.badge.copyWith(
                                color: AppColours.inkBody,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColours.inkMuted),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
