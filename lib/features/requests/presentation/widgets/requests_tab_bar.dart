import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/requests_tab.dart';

/// The inbox's three-segment New / Negotiating / Closed switch, with a
/// live count on each (BR-02.7).
class RequestsTabBar extends StatelessWidget {
  final RequestsTab selected;
  final int Function(RequestsTab tab) countOf;
  final ValueChanged<RequestsTab> onChanged;

  const RequestsTabBar({
    super.key,
    required this.selected,
    required this.countOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColours.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final tab in RequestsTab.values)
            Expanded(
              child: _Segment(
                label: t.tabCount(_label(t, tab), countOf(tab)),
                selected: tab == selected,
                onTap: () => onChanged(tab),
              ),
            ),
        ],
      ),
    );
  }

  String _label(AppLocalizations t, RequestsTab tab) => switch (tab) {
    RequestsTab.newTab => t.tabNew,
    RequestsTab.all => t.tabAll,
  };
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            // Explicit white, not left to a Material/theme default, so the
            // selected segment always reads as a solid white pill (design).
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColours.ink.withValues(alpha: 0.1),
                      blurRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.emphasis.copyWith(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected
                  ? AppColours.primaryDark
                  : AppColours.inkSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
