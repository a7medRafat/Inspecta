import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_search_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/widgets/auth_labels.dart';
import '../bloc/inspectors_list_cubit.dart';

/// The Inspectors tab's blue header: today's date, the title, the three
/// availability tiles, and the search box.
class InspectorsListHeader extends StatelessWidget {
  final TextEditingController searchController;

  const InspectorsListHeader({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = context.select((AuthCubit cubit) => cubit.user);
    if (user == null) return const SizedBox.shrink();
    final dateLabel = DateFormat(
      'EEE d MMM',
      Localizations.localeOf(context).languageCode,
    ).format(DateTime.now());

    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 24, 20, 22),
      decoration: const BoxDecoration(
        color: AppColours.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${user.role.label(t)} · $dateLabel',
            style: AppTextStyles.caption.copyWith(color: AppColours.onPrimaryMuted),
          ),
          Text(
            t.inspectorsTitle,
            style: AppTextStyles.pageTitle.copyWith(color: Colors.white, fontSize: 26),
          ),
          const SizedBox(height: 18),
          BlocBuilder<InspectorsListCubit, InspectorsListState>(
            builder: (context, state) {
              return Row(
                children: [
                  Expanded(
                    child: _StatTile(value: state.freeTodayCount, label: t.statFreeToday, emphasised: true),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _StatTile(value: state.busyCount, label: t.statBusy)),
                  const SizedBox(width: 8),
                  Expanded(child: _StatTile(value: state.onLeaveCount, label: t.statOnLeave)),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          ISearchField(
            controller: searchController,
            onChanged: context.read<InspectorsListCubit>().setQuery,
            hintText: t.searchInspectorsHint,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final int value;
  final String label;
  final bool emphasised;

  const _StatTile({required this.value, required this.label, this.emphasised = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: emphasised ? Colors.white : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: emphasised ? AppColours.successIcon : Colors.white,
            ),
          ),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: emphasised ? AppColours.inkSecondary : AppColours.onPrimaryMuted,
            ),
          ),
        ],
      ),
    );
  }
}
