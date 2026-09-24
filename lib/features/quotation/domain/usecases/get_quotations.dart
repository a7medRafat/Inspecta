import '../entities/quotation.dart';
import '../repositories/quotation_repository.dart';

class GetQuotations {
  final QuotationRepository _repository;

  const GetQuotations(this._repository);

  Stream<List<Quotation>> call() => _repository.watchAll();
}
