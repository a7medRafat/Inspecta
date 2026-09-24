import 'package:flutter/material.dart';

import '../../../../core/consts/app_text_styles.dart';

/// A company's rounded-square initials badge, coloured by a hash of its
/// name so the same client always lands on the same colour and the list
/// doesn't read as one flat blue wall.
class ClientAvatar extends StatelessWidget {
  final String companyName;
  final double size;

  const ClientAvatar({super.key, required this.companyName, this.size = 46});

  static const _palettes = [
    (background: Color(0xFFDBEAFE), foreground: Color(0xFF1D4ED8)),
    (background: Color(0xFFDCFCE7), foreground: Color(0xFF15803D)),
    (background: Color(0xFFEDE9FE), foreground: Color(0xFF6D28D9)),
    (background: Color(0xFFFEF3C7), foreground: Color(0xFF92400E)),
    (background: Color(0xFFFCE7F3), foreground: Color(0xFFBE185D)),
  ];

  String get _initials {
    final words = companyName.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[companyName.hashCode.abs() % _palettes.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: AppTextStyles.cardTitle.copyWith(fontSize: size * 0.33, color: palette.foreground),
      ),
    );
  }
}
