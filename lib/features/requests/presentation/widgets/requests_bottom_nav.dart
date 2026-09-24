import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

/// The three real tabs this bar switches between in place. Profile is a
/// push, not a tab — see [RequestsBottomNav].
enum SupervisorTab { requests, quotations, clients }

/// The Requests / Quotations / Clients / Profile bar. Requests,
/// Quotations and Clients are real tabs — tapping one switches the
/// root's body in place, the same Scaffold and bar staying put, exactly
/// like tapping between them should feel. Profile pushes its own screen
/// since it isn't a tab.
class RequestsBottomNav extends StatelessWidget {
  final SupervisorTab selected;
  final ValueChanged<SupervisorTab> onSelectTab;
  final VoidCallback onProfile;

  const RequestsBottomNav({
    super.key,
    required this.selected,
    required this.onSelectTab,
    required this.onProfile,
  });

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
                  label: t.navRequests,
                  selected: selected == SupervisorTab.requests,
                  onTap: () => onSelectTab(SupervisorTab.requests),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.description_outlined,
                  label: t.navQuotations,
                  selected: selected == SupervisorTab.quotations,
                  onTap: () => onSelectTab(SupervisorTab.quotations),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.groups_outlined,
                  label: t.navClients,
                  selected: selected == SupervisorTab.clients,
                  onTap: () => onSelectTab(SupervisorTab.clients),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: t.profile,
                  selected: false,
                  onTap: onProfile,
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
