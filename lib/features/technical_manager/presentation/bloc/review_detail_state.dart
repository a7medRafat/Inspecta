part of 'review_detail_cubit.dart';

enum ReviewDetailStatus { loading, ready, notFound, error }

class ReviewDetailState extends Equatable {
  final ReviewDetailStatus status;
  final Certificate? certificate;

  final String comments;
  final String reviewerName;
  final String license;
  final String email;

  /// The address [ReviewDetailCubit] looked up from the client, so the
  /// screen can drop it into the email field once.
  final String? suggestedEmail;
  final List<List<double>> strokes;

  final bool isApproving;
  final bool isReturning;
  final int actionSeq;
  final bool lastActionSuccess;
  final bool lastActionApproved;
  final CertificateFailureCode? lastActionFailure;

  const ReviewDetailState({
    this.status = ReviewDetailStatus.loading,
    this.certificate,
    this.comments = '',
    this.reviewerName = '',
    this.license = '',
    this.email = '',
    this.suggestedEmail,
    this.strokes = const [],
    this.isApproving = false,
    this.isReturning = false,
    this.actionSeq = 0,
    this.lastActionSuccess = false,
    this.lastActionApproved = false,
    this.lastActionFailure,
  });

  bool get isBusy => isApproving || isReturning;

  bool get isSigned => strokes.any((stroke) => stroke.length >= 4);

  /// Signed, named, licensed and addressed — the certificate can't go out
  /// unsigned or to a nonsense address.
  bool get canApprove =>
      certificate != null &&
      isSigned &&
      reviewerName.trim().isNotEmpty &&
      license.trim().isNotEmpty &&
      Validators.isEmail(email);

  ReviewDetailState copyWith({
    ReviewDetailStatus? status,
    Certificate? certificate,
    String? comments,
    String? reviewerName,
    String? license,
    String? email,
    String? suggestedEmail,
    List<List<double>>? strokes,
    bool? isApproving,
    bool? isReturning,
    int? actionSeq,
    bool? lastActionSuccess,
    bool? lastActionApproved,
    CertificateFailureCode? lastActionFailure,
  }) {
    return ReviewDetailState(
      status: status ?? this.status,
      certificate: certificate ?? this.certificate,
      comments: comments ?? this.comments,
      reviewerName: reviewerName ?? this.reviewerName,
      license: license ?? this.license,
      email: email ?? this.email,
      suggestedEmail: suggestedEmail ?? this.suggestedEmail,
      strokes: strokes ?? this.strokes,
      isApproving: isApproving ?? this.isApproving,
      isReturning: isReturning ?? this.isReturning,
      actionSeq: actionSeq ?? this.actionSeq,
      lastActionSuccess: lastActionSuccess ?? this.lastActionSuccess,
      lastActionApproved: lastActionApproved ?? this.lastActionApproved,
      lastActionFailure: lastActionFailure ?? this.lastActionFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    certificate,
    comments,
    reviewerName,
    license,
    email,
    suggestedEmail,
    strokes,
    isApproving,
    isReturning,
    actionSeq,
    lastActionSuccess,
    lastActionApproved,
    lastActionFailure,
  ];
}
