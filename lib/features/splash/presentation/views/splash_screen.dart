import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/jsons.dart';
import '../../../../core/shared/m_lottie.dart';
import '../widgets/splash_bottom_content.dart';
import '../widgets/splash_gradient_overlay.dart';

/// Shown while the saved session is being restored. Once [ready], the
/// "Start" button fades in so the user decides when to move on to
/// sign-in/home rather than being carried there automatically.
class SplashScreen extends StatelessWidget {
  final bool ready;
  final VoidCallback? onStart;

  const SplashScreen({super.key, this.ready = false, this.onStart});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColours.primaryColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: MLottie(name: Jsons.splash, fit: BoxFit.cover),
            ),
            const Positioned.fill(child: SplashGradientOverlay()),
            Positioned(
              left: 24,
              right: 24,
              bottom: 32,
              child: SplashBottomContent(ready: ready, onStart: onStart),
            ),
          ],
        ),
      ),
    );
  }
}
