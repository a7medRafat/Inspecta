import 'package:flutter/material.dart';

class Gradients {
  static LinearGradient get mainGradient => const LinearGradient(
        colors: [
          Color(0xff92278F),
          Color(0xff802990),
          Color(0xff5C2D91),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static LinearGradient get secondGradient => const LinearGradient(
        colors: [
          Color(0xffFDD001),
          Color(0xffFFF000),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
}
