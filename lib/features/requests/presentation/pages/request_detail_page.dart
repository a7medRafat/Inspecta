import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/framework/mtoast.dart';
import '../../../../core/shared/m_back_button.dart';
import '../../../../core/shared/m_card.dart';
import '../../../../core/shared/m_notice.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../quotation/presentation/bloc/quotation_form_cubit.dart';
import '../../../quotation/presentation/widgets/quotation_footer.dart';
import '../../../quotation/presentation/widgets/quotation_reply_card.dart';
import '../../domain/entities/inspection_request.dart';
import '../widgets/email_summary_card.dart';
import '../widgets/equipment_grid.dart';
import '../widgets/job_stepper.dart';

/// Feature 02 §5's "Request detail" screen: the six-step progress bar,
/// the intake email, the equipment, and Feature 03's reply panel.
class RequestDetailPage extends StatelessWidget {
  final InspectionRequest request;

  const RequestDetailPage({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuotationFormCubit>(param1: request),
      child: Scaffold(
        backgroundColor: AppColours.background,
        body: SafeArea(
          child: Column(
            children: [
              _Header(request: request),
              Expanded(child: _Body(request: request)),
              if (request.isReadyToQuote)
                QuotationFooter(
                  unitsLabel: AppLocalizations.of(context)!.unitsCount(request.totalUnits),
                  // The request has left New/Negotiating for the supervisor
                  // once sent or rejected — back to the inbox.
                  onSent: () => Navigator.of(context).pop(),
                )
              else
                const _NotReadyNotice(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final InspectionRequest request;

  const _Body({required this.request});

  void _notBuiltYet(BuildContext context) {
    MToast.showError(message: AppLocalizations.of(context)!.quotationBackendNotBuiltYet);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (request.emailPreview != null || request.emailFrom != null) ...[
          EmailSummaryCard(
            request: request,
            onReadFullEmail: () => _notBuiltYet(context),
          ),
          const SizedBox(height: 14),
        ],
        EquipmentGrid(items: request.items, preferredDate: request.preferredDate),
        const SizedBox(height: 14),
        _LocationCard(location: request.location),
        if (request.accessNotes != null && request.accessNotes!.isNotEmpty) ...[
          const SizedBox(height: 14),
          _NotesCard(notes: request.accessNotes!),
        ],
        if (request.isReadyToQuote) ...[
          const SizedBox(height: 14),
          const QuotationReplyCard(),
        ],
      ],
    );
  }
}

class _NotReadyNotice extends StatelessWidget {
  const _NotReadyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColours.border)),
      ),
      child: MNotice(
        type: MNoticeType.info,
        message: AppLocalizations.of(context)!.notReadyToQuote,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final InspectionRequest request;

  const _Header({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColours.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const MBackButton(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      request.id,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppColours.inkMuted,
                      ),
                    ),
                    Text(
                      request.equipmentTitle,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          JobStepper(status: request.status),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String location;

  const _LocationCard({required this.location});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return MCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 20, color: AppColours.primaryDark),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t.locationLabel, style: AppTextStyles.caption),
                Text(location, style: AppTextStyles.emphasis.copyWith(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return MCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.accessNotesLabel, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(notes, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
