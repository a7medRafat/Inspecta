import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/consts/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../certificate/domain/entities/certificate_result.dart';

/// How a certificate's final verdict reads on the reviewer's cards and
/// summary (Feature 06).
extension ReviewResultStyle on CertificateResult? {
  String badgeLabel(AppLocalizations t) => switch (this) {
    CertificateResult.safeToOperate => t.reviewBadgeSafe,
    CertificateResult.safeWithConditions => t.reviewBadgeConditions,
    CertificateResult.notSafe => t.reviewBadgeNotSafe,
    null => '',
  };

  String title(AppLocalizations t) => switch (this) {
    CertificateResult.safeToOperate => t.reviewResultSafe,
    CertificateResult.safeWithConditions => t.reviewResultConditions,
    CertificateResult.notSafe => t.reviewResultNotSafe,
    null => '',
  };

  Color get badgeBackground => switch (this) {
    CertificateResult.safeToOperate => AppColours.chipGreenBackground,
    CertificateResult.safeWithConditions => AppColours.chipAmberBackground,
    CertificateResult.notSafe => AppColours.chipRedBackground,
    null => AppColours.chipGreyBackground,
  };

  Color get badgeText => switch (this) {
    CertificateResult.safeToOperate => AppColours.chipGreenText,
    CertificateResult.safeWithConditions => AppColours.chipAmberText,
    CertificateResult.notSafe => AppColours.chipRedText,
    null => AppColours.chipGreyText,
  };

  /// "Safe" jobs get the quieter outlined action; anything with a finding
  /// gets the filled one, so the ones needing attention stand out.
  bool get needsAttention => this != CertificateResult.safeToOperate;
}

/// "today 11:40", "yesterday", or "27 Sep" — how recently a certificate
/// was submitted, in the card's own words.
String reviewWhenLabel(AppLocalizations t, DateTime time, String locale, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final today = DateTime(current.year, current.month, current.day);
  final day = DateTime(time.year, time.month, time.day);
  final days = today.difference(day).inDays;
  if (days <= 0) return t.todayAtTime(DateFormat.Hm(locale).format(time));
  if (days == 1) return t.yesterdayLabel;
  return DateFormat('d MMM', locale).format(time);
}
