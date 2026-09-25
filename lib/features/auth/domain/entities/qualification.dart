import 'package:equatable/equatable.dart';

/// One equipment category an inspector is certified for (e.g. "Lifts"),
/// with the certificate's expiry — Feature 04's inspector roster shows
/// this alongside qualification-based matching in the assign flow.
class Qualification extends Equatable {
  final String name;

  /// Null when there's no expiry on file (legacy data, or a qualification
  /// that never expires).
  final DateTime? validUntil;

  const Qualification({required this.name, this.validUntil});

  /// Feature 04 §5's "expiring soon" warning threshold.
  bool isExpiringWithin(Duration window, {DateTime? now}) {
    final until = validUntil;
    if (until == null) return false;
    return until.isAfter(now ?? DateTime.now()) &&
        until.isBefore((now ?? DateTime.now()).add(window));
  }

  bool isExpired({DateTime? now}) => validUntil != null && validUntil!.isBefore(now ?? DateTime.now());

  @override
  List<Object?> get props => [name, validUntil];
}
