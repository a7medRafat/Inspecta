import 'package:equatable/equatable.dart';

/// One request item priced on a quotation (BR-03.2: price is per unit,
/// total = unit price × quantity).
class QuoteLineItem extends Equatable {
  final String requestItemId;
  final String type;
  final int quantity;
  final int unitPricePiastres;

  const QuoteLineItem({
    required this.requestItemId,
    required this.type,
    required this.quantity,
    required this.unitPricePiastres,
  });

  int get lineTotalPiastres => unitPricePiastres * quantity;

  @override
  List<Object?> get props => [requestItemId, type, quantity, unitPricePiastres];
}
