import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../clients/domain/entities/client.dart';
import '../../../clients/domain/usecases/get_clients.dart';
import '../../../quotation/domain/entities/quotation.dart';
import '../../../quotation/domain/entities/quotation_status.dart';
import '../../../quotation/domain/usecases/get_quotations.dart';

part 'profile_stats_state.dart';

/// Backs the supervisor's "This month" stat tiles on the Profile screen.
/// Coordinator/inspector/technical manager have no data source for their
/// tiles yet (their features aren't built), so their counts simply stay
/// null forever — the Profile screen renders a placeholder for those.
class ProfileStatsCubit extends Cubit<ProfileStatsState> {
  final GetQuotations _getQuotations;
  final GetClients _getClients;

  StreamSubscription<List<Quotation>>? _quotationsSubscription;
  StreamSubscription<List<Client>>? _clientsSubscription;

  ProfileStatsCubit(this._getQuotations, this._getClients) : super(const ProfileStatsState());

  void start() {
    if (_quotationsSubscription != null) return;
    _quotationsSubscription = _getQuotations().listen((quotations) {
      final now = DateTime.now();
      bool inThisMonth(DateTime? at) => at != null && at.year == now.year && at.month == now.month;
      emit(
        state.copyWith(
          quotesSentThisMonth: quotations.where((q) => inThisMonth(q.sentAt)).length,
          acceptedThisMonth: quotations
              .where((q) => q.status == QuotationStatus.accepted && inThisMonth(q.clientRespondedAt))
              .length,
        ),
      );
    }, onError: (_) {});

    _clientsSubscription = _getClients().listen(
      (clients) => emit(state.copyWith(clientsCount: clients.length)),
      onError: (_) {},
    );
  }

  @override
  Future<void> close() async {
    await _quotationsSubscription?.cancel();
    await _clientsSubscription?.cancel();
    return super.close();
  }
}
