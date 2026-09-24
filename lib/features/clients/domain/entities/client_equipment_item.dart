import 'package:equatable/equatable.dart';

/// One item on a client's equipment register — entered once and reused
/// across repeat inspections, independent of any single request.
class ClientEquipmentItem extends Equatable {
  final String id;
  final String type;
  final String? serialNumber;
  final String? location;
  final String? lastInspectionResult;
  final DateTime? nextDueDate;

  const ClientEquipmentItem({
    required this.id,
    required this.type,
    this.serialNumber,
    this.location,
    this.lastInspectionResult,
    this.nextDueDate,
  });

  /// Due within 30 days and not already overdue (an overdue item needs a
  /// different, more urgent treatment than this app builds yet).
  bool isDueSoon({DateTime? now}) {
    final due = nextDueDate;
    if (due == null) return false;
    final days = due.difference(now ?? DateTime.now()).inDays;
    return days >= 0 && days <= 30;
  }

  @override
  List<Object?> get props => [
    id,
    type,
    serialNumber,
    location,
    lastInspectionResult,
    nextDueDate,
  ];
}
