import '../../../../core/error/failure.dart';

enum QuotationFailureCode { permissionDenied, network, unknown }

class QuotationFailure extends Failure {
  final QuotationFailureCode code;

  const QuotationFailure(this.code);

  @override
  String toString() => 'QuotationFailure(${code.name})';
}
