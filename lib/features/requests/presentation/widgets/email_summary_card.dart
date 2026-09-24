import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/shared/m_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/inspection_request.dart';

/// The intake email's summary, with a link into the full thread (US-02.3).
/// Reading the full thread isn't built yet — see [RequestDetailPage].
class EmailSummaryCard extends StatelessWidget {
  final InspectionRequest request;
  final VoidCallback onReadFullEmail;

  const EmailSummaryCard({
    super.key,
    required this.request,
    required this.onReadFullEmail,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final initials = request.clientName.isEmpty
        ? '?'
        : request.clientName.trim()[0].toUpperCase();
    final time = DateFormat.Hm().format(request.receivedAt);

    return MCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColours.primarySoft,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColours.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      request.clientName,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      request.emailFrom == null
                          ? time
                          : '${request.emailFrom} · $time',
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (request.emailPreview != null) ...[
            const SizedBox(height: 10),
            Text(
              request.emailPreview!,
              style: AppTextStyles.body.copyWith(fontSize: 14),
            ),
          ],
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onReadFullEmail,
            child: Text(t.readFullEmail, style: AppTextStyles.link),
          ),
        ],
      ),
    );
  }
}
