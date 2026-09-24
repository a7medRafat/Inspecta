import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../injection.dart';
import '../../domain/entities/inspection_request.dart';
import '../bloc/requests_list_cubit.dart';
import '../widgets/requests_inbox_header.dart';
import '../widgets/requests_list_view.dart';
import 'request_detail_page.dart';

/// Feature 02's "Requests inbox": the header, search, tabs, and the list
/// itself. Content only — the bottom nav belongs to whichever role shell
/// hosts this screen (see `SupervisorRootPage`).
class RequestsInboxPage extends StatelessWidget {
  const RequestsInboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RequestsListCubit>()..start(),
      child: const _RequestsInboxView(),
    );
  }
}

class _RequestsInboxView extends StatefulWidget {
  const _RequestsInboxView();

  @override
  State<_RequestsInboxView> createState() => _RequestsInboxViewState();
}

class _RequestsInboxViewState extends State<_RequestsInboxView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(BuildContext context, InspectionRequest request) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RequestDetailPage(request: request),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColours.background,
        body: Column(
          children: [
            RequestsInboxHeader(searchController: _searchController),
            Expanded(child: RequestsListView(onOpen: _openDetail)),
          ],
        ),
      ),
    );
  }
}
