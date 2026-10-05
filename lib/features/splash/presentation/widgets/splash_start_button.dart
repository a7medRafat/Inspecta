import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

/// Pill "Start" button that fades in once the splash is [ready].
class SplashStartButton extends StatelessWidget {
  final bool ready;
  final VoidCallback? onStart;

  const SplashStartButton({super.key, required this.ready, this.onStart});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AnimatedOpacity(
      opacity: ready ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: IgnorePointer(
        ignoring: !ready,
        child: SizedBox(
          width: double.infinity,
          height: 64,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: ready ? onStart : null,
              child: Padding(
                padding: const EdgeInsets.only(left: 28, right: 8),
                child: Row(
                  children: [
                    Text(
                      t.splashStart,
                      style: AppTextStyles.buttonLabel.copyWith(
                        color: AppColours.primaryDark,
                        fontSize: 17,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColours.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
