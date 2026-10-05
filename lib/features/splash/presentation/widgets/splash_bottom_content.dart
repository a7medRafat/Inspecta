import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import 'splash_start_button.dart';
import 'splash_welcome_title.dart';

/// Welcome title, hint text and Start button pinned to the bottom of the splash.
class SplashBottomContent extends StatelessWidget {
  final bool ready;
  final VoidCallback? onStart;

  const SplashBottomContent({super.key, required this.ready, this.onStart});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SplashWelcomeTitle(),
          const SizedBox(height: 10),
          Text(
            t.splashHint,
            style: AppTextStyles.body.copyWith(
              color: AppColours.onPrimaryMuted,
            ),
          ),
          const SizedBox(height: 24),
          SplashStartButton(ready: ready, onStart: onStart),
        ],
      ),
    );
  }
}
