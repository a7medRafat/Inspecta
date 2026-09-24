import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_search_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../auth/presentation/widgets/auth_labels.dart';
import '../bloc/requests_list_cubit.dart';

/// One continuous rounded blue panel: the greeting row, then the search
/// box — both inside the same header, matching the mockup exactly (the
/// rounded bottom corners belong to the whole block, not just the top
/// row).
class RequestsInboxHeader extends StatelessWidget {
  final TextEditingController searchController;

  const RequestsInboxHeader({super.key, required this.searchController});

  static String _greeting(AppLocalizations t) {
    final hour = DateTime.now().hour;
    if (hour < 12) return t.requestsGreetingMorning;
    if (hour < 18) return t.requestsGreetingAfternoon;
    return t.requestsGreetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = context.select((AuthCubit cubit) => cubit.user);
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 32,
        20,
        30,
      ),
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
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
                  ),
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
                      _greeting(t),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColours.onPrimaryMuted,
                      ),
                    ),
                    Text(
                      t.requestsGreetingNameRole(user.name, user.role.label(t)),
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.emphasis.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
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
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          ISearchField(
            controller: searchController,
            onChanged: context.read<RequestsListCubit>().setQuery,
            hintText: t.searchRequestsHint,

          ),
        ],
      ),
    );
  }
}
