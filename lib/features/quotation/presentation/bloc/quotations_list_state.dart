part of 'quotations_list_cubit.dart';

enum QuotationsListStatus { loading, ready, error }

class QuotationsListState extends Equatable {
  final QuotationsListStatus status;

  /// One entry per request: its current (latest, non-superseded, sent)
  /// quotation. Drafts don't appear here at all — see the cubit's doc.
  final List<Quotation> board;

  final QuoteBoardTab tab;
  final String query;

  /// Set by tapping the "Expiring soon" summary tile — a cross-cutting
  /// filter, not one of the four tabs.
  final bool onlyExpiringSoon;
  final QuotationFailureCode? failure;

  const QuotationsListState({
    this.status = QuotationsListStatus.loading,
    this.board = const [],
    this.tab = QuoteBoardTab.open,
    this.query = '',
    this.onlyExpiringSoon = false,
    this.failure,
  });

  List<Quotation> _forTab(QuoteBoardTab tab, {DateTime? now}) =>
      board.where((q) => QuoteBoardTabX.of(q, now: now) == tab).toList();

  int countOf(QuoteBoardTab tab) => _forTab(tab).length;

  int get expiringSoonCount => board.where((q) => q.isExpiringSoon()).length;

  int get acceptedThisMonthCount => _acceptedThisMonth().length;

  List<Quotation> _acceptedThisMonth({DateTime? now}) {
    final effectiveNow = now ?? DateTime.now();
    return _forTab(QuoteBoardTab.accepted, now: effectiveNow).where((q) {
      final at = q.clientRespondedAt;
      return at != null && at.year == effectiveNow.year && at.month == effectiveNow.month;
    }).toList();
  }

  int get openTotalPiastres => _forTab(QuoteBoardTab.open)
      .fold(0, (sum, q) => sum + (q.totalPiastres ?? 0));

  int get acceptedThisMonthTotalPiastres =>
      _acceptedThisMonth().fold(0, (sum, q) => sum + (q.totalPiastres ?? 0));

  /// The current tab (or the expiring-soon cross-filter), then the
  /// search text (client, request id, or quote number).
  List<Quotation> get visible {
    final base = onlyExpiringSoon
        ? board.where((q) => q.isExpiringSoon()).toList()
        : _forTab(tab);
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return base;
    return base
        .where(
          (q) =>
              q.clientName.toLowerCase().contains(needle) ||
              q.requestNumber.toLowerCase().contains(needle) ||
              q.id.toLowerCase().contains(needle),
        )
        .toList();
  }

  QuotationsListState copyWith({
    QuotationsListStatus? status,
    List<Quotation>? board,
    QuoteBoardTab? tab,
    String? query,
    bool? onlyExpiringSoon,
    QuotationFailureCode? failure,
  }) {
    return QuotationsListState(
      status: status ?? this.status,
      board: board ?? this.board,
      tab: tab ?? this.tab,
      query: query ?? this.query,
      onlyExpiringSoon: onlyExpiringSoon ?? this.onlyExpiringSoon,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, board, tab, query, onlyExpiringSoon, failure];
}
