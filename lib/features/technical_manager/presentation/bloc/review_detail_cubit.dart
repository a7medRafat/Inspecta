import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validators.dart';
import '../../../certificate/domain/entities/certificate.dart';
import '../../../certificate/domain/entities/certificate_failure.dart';
import '../../../certificate/domain/usecases/approve_certificate.dart';
import '../../../certificate/domain/usecases/return_certificate.dart';
import '../../../certificate/domain/usecases/watch_certificate.dart';
import '../../../clients/domain/usecases/get_client_detail.dart';
import '../../../requests/domain/entities/inspection_request.dart';

part 'review_detail_state.dart';

/// Backs one certificate's review screen (Feature 06): the inspector's
/// submitted certificate, plus the reviewer's own comments, signature and
/// recipient — approved with all of them, or returned with a reason.
class ReviewDetailCubit extends Cubit<ReviewDetailState> {
  final InspectionRequest request;
  final WatchCertificate _watchCertificate;
  final GetClientDetail _getClientDetail;
  final ApproveCertificate _approve;
  final ReturnCertificate _return;

  StreamSubscription<Certificate?>? _subscription;

  ReviewDetailCubit({
    required this.request,
    required String reviewerName,
    required WatchCertificate watchCertificate,
    required GetClientDetail getClientDetail,
    required ApproveCertificate approveCertificate,
    required ReturnCertificate returnCertificate,
  }) : _watchCertificate = watchCertificate,
       _getClientDetail = getClientDetail,
       _approve = approveCertificate,
       _return = returnCertificate,
       super(ReviewDetailState(reviewerName: reviewerName));

  void start() {
    if (_subscription != null) return;
    _subscription = _watchCertificate(request.id).listen(
      (certificate) => emit(
        state.copyWith(
          status: certificate == null ? ReviewDetailStatus.notFound : ReviewDetailStatus.ready,
          certificate: certificate,
        ),
      ),
      onError: (Object error) => emit(state.copyWith(status: ReviewDetailStatus.error)),
    );
    _loadClientEmail();
  }

  /// Pre-fills "Send signed PDF to" with the client's certificates inbox —
  /// the reviewer can still change it.
  Future<void> _loadClientEmail() async {
    final clientId = request.clientId;
    if (clientId == null) return;
    try {
      final client = await _getClientDetail(clientId);
      if (isClosed) return;
      final email = client?.certificatesEmail ?? client?.mainContact?.email;
      if (email != null && email.isNotEmpty && state.email.isEmpty) {
        emit(state.copyWith(email: email, suggestedEmail: email));
      }
    } catch (_) {
      // No suggestion — the field just starts empty.
    }
  }

  void setComments(String value) => emit(state.copyWith(comments: value));

  void setReviewerName(String value) => emit(state.copyWith(reviewerName: value));

  void setLicense(String value) => emit(state.copyWith(license: value));

  void setEmail(String value) => emit(state.copyWith(email: value));

  void setStrokes(List<List<double>> strokes) => emit(state.copyWith(strokes: strokes));

  void clearSignature() => emit(state.copyWith(strokes: const []));

  Future<void> approve() async {
    final certificate = state.certificate;
    if (certificate == null || !state.canApprove || state.isBusy) return;
    emit(state.copyWith(isApproving: true));
    final comments = state.comments.trim();
    try {
      await _approve(
        certificate.withReview(
          reviewerComments: comments.isEmpty ? null : comments,
          reviewerName: state.reviewerName.trim(),
          reviewerLicense: state.license.trim(),
          sentTo: state.email.trim(),
          signatureStrokes: state.strokes,
        ),
      );
      _finish(approved: true);
    } catch (e) {
      _fail(e);
    }
  }

  Future<void> sendBack(String note) async {
    final certificate = state.certificate;
    if (certificate == null || state.isBusy) return;
    emit(state.copyWith(isReturning: true));
    try {
      await _return(certificate, note: note.trim());
      _finish(approved: false);
    } catch (e) {
      _fail(e);
    }
  }

  void _finish({required bool approved}) {
    if (isClosed) return;
    emit(
      state.copyWith(
        isApproving: false,
        isReturning: false,
        actionSeq: state.actionSeq + 1,
        lastActionSuccess: true,
        lastActionApproved: approved,
      ),
    );
  }

  void _fail(Object error) {
    if (isClosed) return;
    emit(
      state.copyWith(
        isApproving: false,
        isReturning: false,
        actionSeq: state.actionSeq + 1,
        lastActionSuccess: false,
        lastActionFailure: error is CertificateFailure ? error.code : CertificateFailureCode.unknown,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
