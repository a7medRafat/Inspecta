import 'package:flutter/material.dart';

/// White & blue palette from the inspection app mockup.
class AppColours {
  AppColours._();

  // ---- Brand ----
  static const Color primaryColor = Color(0xFF2563EB);

  /// Darker blue for icons and links on light surfaces.
  static const Color primaryDark = Color(0xFF1D4ED8);

  /// Soft blue ring drawn around a focused input.
  static const Color primaryTint = Color(0xFFDBEAFE);

  /// Very light blue behind an icon tile (e.g. the reset-password lock).
  static const Color primarySoft = Color(0xFFEFF4FF);

  /// Muted text on top of a [primaryColor] header.
  static const Color onPrimaryMuted = Color(0xFFDBE6FF);

  /// Soft yellow for an emphasised number/icon on a [primaryColor] header
  /// (e.g. the "Expiring soon" tile's count) — a warning accent that
  /// still reads on a dark background, unlike [chipAmberText].
  static const Color amberOnPrimary = Color(0xFFFDE68A);

  /// Primary buttons and focused inputs on auth screens.
  static const Color authAccent = primaryColor;

  // ---- Text ----
  static const Color ink = Color(0xFF0F172A);
  static const Color inkBody = Color(0xFF334155);
  static const Color inkSecondary = Color(0xFF475569);
  static const Color inkMuted = Color(0xFF64748B);

  // ---- Surfaces ----
  /// Grey-blue background behind cards on the role screens.
  static const Color background = Color(0xFFF6F8FC);

  /// Filled chip / info panel / icon button background.
  static const Color surfaceMuted = Color(0xFFF1F5FB);

  /// Resting border of an input.
  static const Color border = Color(0xFFCBD5E1);

  // ---- Status ----
  static const Color grey = Color(0xff9E9E9E);
  static const Color green = Color(0xff2ECC71);
  static const Color red = Color(0xffE74C3C);

  static const Color successBackground = Color(0xFFDCFCE7);
  static const Color successIcon = Color(0xFF15803D);
  static const Color successText = Color(0xFF14532D);

  static const Color errorBackground = Color(0xFFFEE2E2);
  static const Color errorIcon = Color(0xFFDC2626);
  static const Color errorText = Color(0xFF7F1D1D);

  /// Border for an outlined "positive" button (e.g. "Accept client's
  /// price") — pair with [successIcon] for its text/icon colour.
  static const Color successBorder = Color(0xFF86EFAC);

  /// Border/text for an outlined "danger" button (e.g. "Mark declined") —
  /// distinct from [errorBackground]'s chip colours, which read too dark
  /// on an outlined white button.
  static const Color dangerBorder = Color(0xFFFCA5A5);
  static const Color dangerText = Color(0xFFB91C1C);

  // ---- Status chips (job status badges on request/job cards) ----
  static const Color chipAmberBackground = Color(0xFFFEF3C7);
  static const Color chipAmberText = Color(0xFF92400E);

  /// Deeper amber for the emphasised value under a [chipAmberText] label
  /// (e.g. the client's counter-price figure) — darker than the label so
  /// the number reads as the important part.
  static const Color chipAmberTextStrong = Color(0xFF78350F);
  static const Color chipBlueBackground = primaryTint;
  static const Color chipBlueText = Color(0xFF1E40AF);
  static const Color chipGreenBackground = successBackground;
  static const Color chipGreenText = successText;
  static const Color chipRedBackground = errorBackground;
  static const Color chipRedText = errorText;
  static const Color chipGreyBackground = Color(0xFFE7E3DA);
  static const Color chipGreyText = Color(0xFF6B6B6B);
}
