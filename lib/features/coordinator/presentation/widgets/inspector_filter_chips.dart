import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

/// The roster's "All · 8 / Lifts / Cranes / Pressure" filter row — a
/// scrollable row of pills, since the category list is whatever
/// qualifications are actually on file rather than a fixed set.
class InspectorFilterChips extends StatelessWidget {
  final List<String> categories;
  final int totalCount;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const InspectorFilterChips({
    super.key,
    required this.categories,
    required this.totalCount,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _Chip(
            label: t.tabCount(t.filterAll, totalCount),
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final category in categories) ...[
            const SizedBox(width: 8),
            _Chip(label: category, selected: selected == category, onTap: () => onSelected(category)),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.selected, required this.onTap});

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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColours.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: selected ? null : Border.all(color: AppColours.border, width: 1.5),
          ),
          child: Text(
            label,
            style: AppTextStyles.emphasis.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColours.inkBody,
            ),
          ),
        ),
      ),
    );
  }
}
