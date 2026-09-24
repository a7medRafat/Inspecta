import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/clients_list_cubit.dart';

/// The three pill filters above the client roster. "Due soon" stays
/// amber-tinted even unselected — it's the one that needs to catch the
/// eye, not just blend in as a neutral option (design).
class ClientsFilterChips extends StatelessWidget {
  final ClientsFilter selected;
  final int allCount;
  final int openJobsCount;
  final int dueSoonCount;
  final ValueChanged<ClientsFilter> onChanged;

  const ClientsFilterChips({
    super.key,
    required this.selected,
    required this.allCount,
    required this.openJobsCount,
    required this.dueSoonCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Row(
      children: [
        _Chip(
          label: '${t.clientsFilterAll} · $allCount',
          selected: selected == ClientsFilter.all,
          onTap: () => onChanged(ClientsFilter.all),
        ),
        const SizedBox(width: 8),
        _Chip(
          label: '${t.clientsFilterOpenJobs} · $openJobsCount',
          selected: selected == ClientsFilter.openJobs,
          onTap: () => onChanged(ClientsFilter.openJobs),
        ),
        const SizedBox(width: 8),
        _Chip(
          label: '${t.clientsFilterDueSoon} · $dueSoonCount',
          selected: selected == ClientsFilter.dueSoon,
          warning: true,
          onTap: () => onChanged(ClientsFilter.dueSoon),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool warning;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color text;
    final Color? border;
    if (warning) {
      background = selected ? AppColours.chipAmberText : const Color(0xFFFFFBEB);
      text = selected ? Colors.white : AppColours.chipAmberText;
      border = const Color(0xFFFCD34D);
    } else if (selected) {
      background = AppColours.primaryColor;
      text = Colors.white;
      border = null;
    } else {
      background = Colors.white;
      text = AppColours.inkBody;
      border = const Color(0xFFD6E0F2);
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: border == null ? null : Border.all(color: border, width: 1.5),
          ),
          child: Text(
            label,
            style: AppTextStyles.badge.copyWith(fontSize: 13, color: text),
          ),
        ),
      ),
    );
  }
}
