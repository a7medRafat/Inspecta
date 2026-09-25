import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

/// The four tabs on the coordinator's shell.
enum CoordinatorTab { queue, schedule, inspectors, profile }

/// Queue / Schedule / Inspectors / Profile — same shape as the
/// supervisor's `RequestsBottomNav`.
class CoordinatorBottomNav extends StatelessWidget {
  final CoordinatorTab selected;
  final ValueChanged<CoordinatorTab> onSelectTab;

  const CoordinatorBottomNav({super.key, required this.selected, required this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 76,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColours.border, width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.inbox_outlined,
                  label: t.navQueue,
                  selected: selected == CoordinatorTab.queue,
                  onTap: () => onSelectTab(CoordinatorTab.queue),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.calendar_today_outlined,
                  label: t.navSchedule,
                  selected: selected == CoordinatorTab.schedule,
                  onTap: () => onSelectTab(CoordinatorTab.schedule),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.groups_outlined,
                  label: t.navInspectors,
                  selected: selected == CoordinatorTab.inspectors,
                  onTap: () => onSelectTab(CoordinatorTab.inspectors),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: t.profile,
                  selected: selected == CoordinatorTab.profile,
                  onTap: () => onSelectTab(CoordinatorTab.profile),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColours.primaryDark : AppColours.inkMuted;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? AppColours.primarySoft : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
