import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/quote_board_tab.dart';

/// The four summary tiles inside the Quotations header. Each filters the
/// board when tapped. "Client replied" is the tile that matters most day
/// to day, so it's the one in white; the rest sit on tinted backgrounds
/// so they read as part of the blue header rather than a white card.
/// "Expiring soon" shares that same tinted background — only its count
/// is coloured, not the whole tile (design).
class QuoteSummaryTiles extends StatelessWidget {
  final int awaitingClient;
  final int clientReplied;
  final int expiringSoon;
  final int acceptedThisMonth;
  final ValueChanged<QuoteBoardTab> onTab;
  final VoidCallback onExpiringSoon;

  const QuoteSummaryTiles({
    super.key,
    required this.awaitingClient,
    required this.clientReplied,
    required this.expiringSoon,
    required this.acceptedThisMonth,
    required this.onTab,
    required this.onExpiringSoon,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 3,
      children: [
        _Tile(
          label: t.tileClientReplied,
          value: '$clientReplied',
          style: _TileStyle.highlighted,
          onTap: () => onTab(QuoteBoardTab.replied),
        ),
        _Tile(
          label: t.tileAwaitingClient,
          value: '$awaitingClient',
          style: _TileStyle.onHeader,
          onTap: () => onTab(QuoteBoardTab.open),
        ),
        _Tile(
          label: t.tileExpiringSoon,
          value: '$expiringSoon',
          style: _TileStyle.warning,
          onTap: onExpiringSoon,
        ),
        _Tile(
          label: t.tileAcceptedThisMonth,
          value: '$acceptedThisMonth',
          style: _TileStyle.onHeader,
          onTap: () => onTab(QuoteBoardTab.accepted),
        ),
      ],
    );
  }
}

enum _TileStyle { highlighted, onHeader, warning }

class _Tile extends StatelessWidget {
  final String label;
  final String value;
  final _TileStyle style;
  final VoidCallback onTap;

  const _Tile({
    required this.label,
    required this.value,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color valueColor;
    final Color labelColor;
    switch (style) {
      case _TileStyle.highlighted:
        background = Colors.white;
        valueColor = AppColours.primaryDark;
        labelColor = AppColours.inkSecondary;
      case _TileStyle.onHeader:
        background = Colors.white.withValues(alpha: 0.16);
        valueColor = Colors.white;
        labelColor = AppColours.onPrimaryMuted;
      case _TileStyle.warning:
        background = Colors.white.withValues(alpha: 0.16);
        valueColor = AppColours.amberOnPrimary;
        labelColor = AppColours.onPrimaryMuted;
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: AppTextStyles.pageTitle.copyWith(fontSize: 22, color: valueColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(color: labelColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
