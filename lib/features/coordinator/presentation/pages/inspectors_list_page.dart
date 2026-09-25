import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_layout.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/loading.dart';
import '../../../../core/shared/m_notice.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/coordinator_failure.dart';
import '../bloc/inspectors_list_cubit.dart';
import '../widgets/coordinator_labels.dart';
import '../widgets/inspector_filter_chips.dart';
import '../widgets/inspector_list_card.dart';
import '../widgets/inspectors_list_header.dart';
import 'inspector_detail_page.dart';

/// Feature 04 §5's Inspectors tab: the roster, who's free/busy/on leave
/// today, and a search/category filter over it.
class InspectorsListPage extends StatefulWidget {
  const InspectorsListPage({super.key});

  @override
  State<InspectorsListPage> createState() => _InspectorsListPageState();
}

class _InspectorsListPageState extends State<InspectorsListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InspectorsListCubit>()..start(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColours.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                InspectorsListHeader(searchController: _searchController),
                const SizedBox(height: 16),
                BlocBuilder<InspectorsListCubit, InspectorsListState>(
                  buildWhen: (previous, current) =>
                      previous.categories != current.categories ||
                      previous.categoryFilter != current.categoryFilter ||
                      previous.inspectors.length != current.inspectors.length,
                  builder: (context, state) => InspectorFilterChips(
                    categories: state.categories,
                    totalCount: state.inspectors.length,
                    selected: state.categoryFilter,
                    onSelected: context.read<InspectorsListCubit>().setCategory,
                  ),
                ),
                const SizedBox(height: 14),
                const Expanded(child: _Body()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocBuilder<InspectorsListCubit, InspectorsListState>(
      builder: (context, state) {
        if (state.status == InspectorsListStatus.loading) {
          return Loading.loader(context);
        }
        if (state.status == InspectorsListStatus.error) {
          return _ErrorState(failure: state.failure!);
        }

        final visible = state.visible;
        if (visible.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.groups_outlined,
                    size: 40,
                    color: AppColours.inkMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.emptyInspectorsRoster,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            AppLayout.bottomNavClearance,
          ),
          itemCount: visible.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final inspector = visible[index];
            return InspectorListCard(
              key: ValueKey(inspector.id),
              inspector: inspector,
              summary: state.summaryFor(inspector),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => InspectorDetailPage(inspector: inspector),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final CoordinatorFailureCode failure;

  const _ErrorState({required this.failure});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MNotice(type: MNoticeType.error, message: failure.message(t)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: context.read<InspectorsListCubit>().retry,
              child: Text(t.retry),
            ),
          ],
        ),
      ),
    );
  }
}
