import 'package:flutter/material.dart';

import '../../../../core/consts/app_colors.dart';

/// Fades the splash animation into the primary colour towards the bottom so
/// the text and button stay legible.
class SplashGradientOverlay extends StatelessWidget {
  const SplashGradientOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.77, 1],
          colors: [
            Colors.transparent,
            AppColours.primaryColor.withValues(alpha: 0.55),
            AppColours.primaryColor.withValues(alpha: 0.92),
          ],
        ),
      ),
    );
  }
}
