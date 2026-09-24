import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../consts/assets_manager.dart';

/// Renders a Lottie animation from `assets/jsons/<name>.json` (see [Jsons] for the names).
class MLottie extends StatelessWidget {
  final String name;
  final double? width;
  final double? height;
  final bool repeat;
  final BoxFit fit;
  final Alignment alignment;

  const MLottie({
    super.key,
    required this.name,
    this.width,
    this.height,
    this.repeat = true,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      AssetsManager.json(name),
      width: width,
      height: height,
      repeat: repeat,
      fit: fit,
      alignment: alignment,
    );
  }
}
