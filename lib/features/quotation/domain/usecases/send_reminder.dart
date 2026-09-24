import '../repositories/quotation_repository.dart';

/// Stamps that a reminder was prompted (see the repository doc for why
/// that's all this does).
class SendReminder {
  final QuotationRepository _repository;

  const SendReminder(this._repository);

  Future<void> call(String quotationId) => _repository.sendReminder(quotationId);
}
