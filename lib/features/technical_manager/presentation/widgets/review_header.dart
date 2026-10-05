import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/widgets/auth_labels.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The technical manager tabs' blue header: avatar (opens Profile), role
/// and screen title, notifications, and an optional [child] beneath (the
/// stat tiles on the Review tab).
class ReviewHeader extends StatelessWidget {
  final String title;
  final VoidCallback onOpenProfile;
  final Widget? child;

  const ReviewHeader({super.key, required this.title, required this.onOpenProfile, this.child});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = context.select((AuthCubit cubit) => cubit.user);
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 24, 20, 22),
      decoration: const BoxDecoration(
        color: AppColours.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onOpenProfile,
                  child: SizedBox.square(
                    dimension: 44,
                    child: Center(
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColours.primaryDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.role.label(t),
                      style: AppTextStyles.caption.copyWith(color: AppColours.onPrimaryMuted),
                    ),
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.emphasis.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: null,
                tooltip: t.notifications,
                style: IconButton.styleFrom(
                  fixedSize: const Size.square(44),
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.16),
                ),
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
            ],
          ),
          if (child != null) ...[const SizedBox(height: 18), child!],
        ],
      ),
    );
  }
}
