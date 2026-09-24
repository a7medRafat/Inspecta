import 'package:flutter/material.dart';

import '../consts/assets_manager.dart';

/// Renders a PNG from `assets/pngs/<name>.png` (see [Pngs] for the names).
class MImage extends StatelessWidget {
  final String name;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;

  const MImage({
    super.key,
    required this.name,
    this.width,
    this.height,
    this.fit,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AssetsManager.png(name),
      width: width,
      height: height,
      fit: fit,
      color: color,
    );
  }
}
