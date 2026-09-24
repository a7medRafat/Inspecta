import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/enums/job_status.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/inspection_request.dart';
import 'status_chip.dart';

/// One row in the requests inbox. Renders as a compact "client replied"
/// prompt when [InspectionRequest.hasUnreadClientReply] is set (BR-03.6),
/// otherwise as the full card with a "Review & quote" CTA for New items.
class RequestCard extends StatelessWidget {
  final InspectionRequest request;
  final VoidCallback onTap;

  const RequestCard({super.key, required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      onTap: onTap,
      child: request.hasUnreadClientReply
          ? _ReplyRow(request: request)
          : _FullCard(request: request),
    );
  }
}

class _CardShell extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _CardShell({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColours.ink.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(color: AppColours.ink.withValues(alpha: 0.04), blurRadius: 2),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  final IconData icon;

  const _IconTile(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColours.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 22, color: AppColours.primaryDark),
    );
  }
}

class _ReplyRow extends StatelessWidget {
  final InspectionRequest request;

  const _ReplyRow({required this.request});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Row(
      children: [
        const _IconTile(Icons.mail_outline_rounded),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.clientReplied(request.clientName),
                style: AppTextStyles.cardTitle,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                request.lastReplySnippet ?? request.equipmentTitle,
                style: AppTextStyles.subtitle,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: AppColours.chipBlueBackground,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            t.reply,
            style: AppTextStyles.badge.copyWith(color: AppColours.chipBlueText),
          ),
        ),
      ],
    );
  }
}

class _FullCard extends StatelessWidget {
  final InspectionRequest request;

  const _FullCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final waiting = request.isWaitingOver24h();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _IconTile(Icons.precision_manufacturing_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    request.equipmentTitle,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${request.clientName} · ${t.unitsCount(request.totalUnits)}',
                          style: AppTextStyles.subtitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (request.isNewClient) ...[
                        const SizedBox(width: 6),
                        _NewClientTag(label: t.newClientTag),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusChip(status: request.status),
                if (waiting) ...[const SizedBox(height: 6), const WaitingChip()],
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _MetaItem(icon: Icons.location_on_outlined, label: request.location),
            const SizedBox(width: 16),
            _MetaItem(
              icon: Icons.schedule_outlined,
              label: RelativeDuration.since(request.receivedAt).label(t),
            ),
          ],
        ),
        if (request.isNew) ...[
          const SizedBox(height: 14),
          _ReviewCta(primary: request.status == JobStatus.requestReceived),
        ],
      ],
    );
  }
}

class _NewClientTag extends StatelessWidget {
  final String label;

  const _NewClientTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColours.chipGreyBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(
          fontSize: 10.5,
          color: AppColours.chipGreyText,
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColours.inkSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.subtitle.copyWith(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// New items get a CTA: filled ("Review & quote") for an untouched
/// request, outlined ("Continue quote") when a draft is already started.
class _ReviewCta extends StatelessWidget {
  final bool primary;

  const _ReviewCta({required this.primary});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final label = primary ? t.reviewAndQuote : t.continueQuote;
    const height = 46.0;
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: AppTextStyles.buttonLabel.copyWith(fontSize: 15)),
        if (primary) ...[
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
        ],
      ],
    );

    // Purely visual: the whole card already navigates on tap.
    return IgnorePointer(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: primary
            ? FilledButton(
                onPressed: null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColours.primaryColor,
                  disabledBackgroundColor: AppColours.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: child,
              )
            : OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  disabledForegroundColor: AppColours.primaryDark,
                  side: const BorderSide(color: AppColours.primaryTint, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: DefaultTextStyle.merge(
                  style: const TextStyle(color: AppColours.primaryDark),
                  child: child,
                ),
              ),
      ),
    );
  }
}
