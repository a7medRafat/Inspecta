import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/entities/quote_board_tab.dart';
import 'quote_board_labels.dart';

/// The quote detail's 2×2 info grid: equipment, request, status, and the
/// current version's validity. Everything shown here already lives on
/// [current], so this doesn't have to wait on the request to load.
class QuoteDetailInfoCard extends StatelessWidget {
  final Quotation current;
  final VoidCallback onOpenRequest;

  const QuoteDetailInfoCard({
    super.key,
    required this.current,
    required this.onOpenRequest,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    final tab = QuoteBoardTabX.of(current) ?? QuoteBoardTab.open;
    final validUntil = current.validUntil;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColours.ink.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Field(label: t.equipmentLabel, value: current.equipmentSummary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _Field(
                  label: t.requestLabel,
                  value: current.requestNumber,
                  onTap: onOpenRequest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Field(label: t.statusLabel, value: tab.label(t))),
              const SizedBox(width: 16),
              Expanded(
                child: _Field(
                  label: t.validUntilLabel(t.quoteVersionLabel(current.version ?? 0)),
                  value: validUntil == null ? '—' : dateFormat.format(validUntil),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _Field({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTextStyles.emphasis.copyWith(
            fontSize: 14,
            color: onTap == null ? AppColours.ink : AppColours.primaryDark,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
    if (onTap == null) return content;
    return InkWell(borderRadius: BorderRadius.circular(8), onTap: onTap, child: content);
  }
}
