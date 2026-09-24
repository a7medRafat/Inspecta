import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/enums/job_status.dart';
import '../../../../core/framework/mtoast.dart';
import '../../../../core/shared/m_back_button.dart';
import '../../../../core/shared/m_card.dart';
import '../../../../core/shared/m_notice.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../quotation/presentation/bloc/quotation_form_cubit.dart';
import '../../../quotation/presentation/pages/quotation_detail_page.dart';
import '../../../quotation/presentation/widgets/quotation_footer.dart';
import '../../../quotation/presentation/widgets/quotation_reply_card.dart';
import '../../domain/entities/inspection_request.dart';
import '../widgets/email_summary_card.dart';
import '../widgets/equipment_grid.dart';
import '../widgets/job_stepper.dart';
import '../widgets/status_chip.dart';

/// Feature 02 §5's "Request detail" screen: the six-step progress bar,
/// the intake email, the equipment, and — only while the request is
/// still New/a draft — Feature 03's reply panel. Once a quote has gone
/// out (any [JobStatus] beyond `requestReceived`/`quoteDraft`), the
/// request's story continues in Quotations (see `requests_tab.dart`),
/// so this screen shows a read-only status instead of repeating the
/// same reply picker.
class RequestDetailPage extends StatelessWidget {
  final InspectionRequest request;

  const RequestDetailPage({super.key, required this.request});

  /// Whether this request can still receive a first reply here — it
  /// hasn't been quoted yet (BR-02.5) and has enough data to quote.
  bool get _quotable => request.isNew && request.isReadyToQuote;

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
              Expanded(child: _Body(request: request, quotable: _quotable)),
              if (_quotable)
                QuotationFooter(
                  unitsLabel: AppLocalizations.of(context)!.unitsCount(request.totalUnits),
                  // The request has left New/Negotiating for the supervisor
                  // once sent or rejected — back to the inbox.
                  onSent: () => Navigator.of(context).pop(),
                )
              else if (request.isNew)
                const _NotReadyNotice()
              else
                _MovedOnNotice(request: request),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final InspectionRequest request;
  final bool quotable;

  const _Body({required this.request, required this.quotable});

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
        if (quotable) ...[
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

/// Shown once the request has left New/draft: a quote already exists
/// for it, so replying again here would just regress its status —
/// point the supervisor at Quotations instead of repeating the picker.
class _MovedOnNotice extends StatelessWidget {
  final InspectionRequest request;

  const _MovedOnNotice({required this.request});

  static MNoticeType _typeFor(JobStatus status) => switch (status) {
    JobStatus.quoteRejected ||
    JobStatus.clientDeclined ||
    JobStatus.certificateReturned => MNoticeType.error,
    JobStatus.quoteSent || JobStatus.clientCountered => MNoticeType.info,
    _ => MNoticeType.success,
  };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final status = request.status;
    final reason = request.rejectReason;
    final message = status == JobStatus.quoteRejected && reason != null && reason.isNotEmpty
        ? t.requestRejectedReasonMessage(reason)
        : t.requestMovedOnMessage(status.label(t));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColours.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MNotice(type: _typeFor(status), title: status.label(t), message: message),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => QuotationDetailPage(requestId: request.id),
                ),
              ),
              icon: const Icon(Icons.description_outlined, size: 18),
              label: Text(t.viewInQuotationsAction),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColours.primaryDark,
                side: const BorderSide(color: AppColours.primaryTint, width: 1.5),
                textStyle: AppTextStyles.buttonLabel.copyWith(fontSize: 14, color: AppColours.primaryDark),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
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
