import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../core/consts/app_text_styles.dart';
import '../../../../core/consts/jsons.dart';
import '../../../../core/shared/m_lottie.dart';
import '../../../../l10n/app_localizations.dart';

/// Shown while the saved session is being restored. Once [ready], the
/// "Start" button fades in so the user decides when to move on to
/// sign-in/home rather than being carried there automatically.
class SplashScreen extends StatelessWidget {
  final bool ready;
  final VoidCallback? onStart;

  const SplashScreen({super.key, this.ready = false, this.onStart});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColours.primaryColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: MLottie(name: Jsons.splash, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.55, 1],
                    colors: [
                      Colors.transparent,
                      AppColours.primaryColor.withValues(alpha: 0.55),
                      AppColours.primaryColor.withValues(alpha: 0.92),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 32,
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: '${t.splashWelcome} '),
                          const TextSpan(
                            text: 'Inspecta',
                            style: TextStyle(color: AppColours.amberOnPrimary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t.splashHint,
                      style: AppTextStyles.body.copyWith(
                        color: AppColours.onPrimaryMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedOpacity(
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
                                padding: const EdgeInsets.only(
                                  left: 28,
                                  right: 8,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      t.splashStart,
                                      style: AppTextStyles.buttonLabel
                                          .copyWith(
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
