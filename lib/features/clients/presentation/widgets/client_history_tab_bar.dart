import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/client_detail_cubit.dart';

/// The client detail's Requests / Equipment / Certificates switch —
/// the same segmented-pill pattern as [RequestsTabBar] and
/// [QuoteBoardTabBar].
class ClientHistoryTabBar extends StatelessWidget {
  final ClientHistoryTab selected;
  final ValueChanged<ClientHistoryTab> onChanged;

  const ClientHistoryTabBar({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final tab in ClientHistoryTab.values)
            Expanded(
              child: _Segment(
                tab: tab,
                selected: tab == selected,
                onTap: () => onChanged(tab),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final ClientHistoryTab tab;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({required this.tab, required this.selected, required this.onTap});

  String _label(AppLocalizations t) => switch (tab) {
    ClientHistoryTab.requests => t.historyTabRequests,
    ClientHistoryTab.equipment => t.historyTabEquipment,
    ClientHistoryTab.certificates => t.historyTabCertificates,
  };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [BoxShadow(color: AppColours.ink.withValues(alpha: 0.1), blurRadius: 3)]
                : null,
          ),
          child: Text(
            _label(t),
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.emphasis.copyWith(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? AppColours.primaryDark : AppColours.inkSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
