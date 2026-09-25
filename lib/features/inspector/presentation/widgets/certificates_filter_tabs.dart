import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/certificates_list_cubit.dart';

/// Action / Submitted / Sent / All — Action shows a red badge with its
/// count (Feature 05).
class CertificatesFilterTabs extends StatelessWidget {
  const CertificatesFilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocBuilder<CertificatesListCubit, CertificatesListState>(
      builder: (context, state) {
        final cubit = context.read<CertificatesListCubit>();
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppColours.surfaceMuted, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Expanded(
                child: _Tab(
                  label: t.filterActionTab,
                  badgeCount: state.actionCount,
                  selected: state.filter == CertificatesFilter.action,
                  onTap: () => cubit.setFilter(CertificatesFilter.action),
                ),
              ),
              Expanded(
                child: _Tab(
                  label: t.filterSubmittedTab,
                  selected: state.filter == CertificatesFilter.submitted,
                  onTap: () => cubit.setFilter(CertificatesFilter.submitted),
                ),
              ),
              Expanded(
                child: _Tab(
                  label: t.filterSentTab,
                  selected: state.filter == CertificatesFilter.sent,
                  onTap: () => cubit.setFilter(CertificatesFilter.sent),
                ),
              ),
              Expanded(
                child: _Tab(
                  label: t.filterAll,
                  selected: state.filter == CertificatesFilter.all,
                  onTap: () => cubit.setFilter(CertificatesFilter.all),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final int? badgeCount;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({required this.label, this.badgeCount, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.badge.copyWith(
                  fontSize: 12,
                  color: selected ? AppColours.primaryDark : AppColours.inkSecondary,
                ),
              ),
              if (badgeCount != null && badgeCount! > 0) ...[
                const SizedBox(width: 5),
                Container(
                  constraints: const BoxConstraints(minWidth: 17),
                  height: 17,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppColours.errorIcon, shape: BoxShape.circle),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
