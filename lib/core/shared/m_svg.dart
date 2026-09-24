import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../consts/assets_manager.dart';

/// Renders an SVG from `assets/svgs/<name>.svg` (see [Svgs] for the names).
class MSvg extends StatelessWidget {
  final String name;
  final double? width;
  final double? height;
  final Color? color;

  const MSvg({
    super.key,
    required this.name,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AssetsManager.svg(name),
      width: width,
      height: height,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
