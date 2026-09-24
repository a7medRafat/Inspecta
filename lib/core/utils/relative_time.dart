import '../../l10n/app_localizations.dart';

/// Short "time ago" labels for list rows (e.g. "2 h ago" on a request
/// card).
class RelativeDuration {
  final int value;
  final RelativeUnit unit;

  const RelativeDuration(this.value, this.unit);

  factory RelativeDuration.since(DateTime time, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(time);
    if (diff.inMinutes < 1) return const RelativeDuration(0, RelativeUnit.justNow);
    if (diff.inHours < 1) return RelativeDuration(diff.inMinutes, RelativeUnit.minutes);
    if (diff.inDays < 1) return RelativeDuration(diff.inHours, RelativeUnit.hours);
    return RelativeDuration(diff.inDays, RelativeUnit.days);
  }

  String label(AppLocalizations t) => switch (unit) {
    RelativeUnit.justNow => t.justNow,
    RelativeUnit.minutes => t.minutesAgo(value),
    RelativeUnit.hours => t.hoursAgo(value),
    RelativeUnit.days => t.daysAgo(value),
  };
}

enum RelativeUnit { justNow, minutes, hours, days }

