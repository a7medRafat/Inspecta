import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_search_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/certificates_list_cubit.dart';

/// The Certificates tab's blue header: title, the three status tiles,
/// and the search box (Feature 05).
class CertificatesListHeader extends StatelessWidget {
  final TextEditingController searchController;

  const CertificatesListHeader({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 20, 20, 18),
      decoration: const BoxDecoration(
        color: AppColours.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.myCertificatesTitle,
            style: AppTextStyles.pageTitle.copyWith(color: Colors.white, fontSize: 22),
          ),
          const SizedBox(height: 16),
          BlocBuilder<CertificatesListCubit, CertificatesListState>(
            buildWhen: (previous, current) =>
                previous.actionCount != current.actionCount ||
                previous.submittedCount != current.submittedCount ||
                previous.sentCount != current.sentCount,
            builder: (context, state) {
              return Row(
                children: [
                  Expanded(
                    child: _StatTile(value: state.actionCount, label: t.statNeedsAction, emphasised: true),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _StatTile(value: state.submittedCount, label: t.statAwaitingReview)),
                  const SizedBox(width: 8),
                  Expanded(child: _StatTile(value: state.sentCount, label: t.statSentThisMonth)),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          ISearchField(
            controller: searchController,
            onChanged: context.read<CertificatesListCubit>().setQuery,
            hintText: t.searchCertificatesHint,
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
              color: emphasised ? AppColours.chipAmberTextStrong : Colors.white,
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
