import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../requests/domain/entities/inspection_request.dart';
import '../../domain/certificate_progress.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/entities/certificate_failure.dart';
import '../../domain/entities/certificate_result.dart';
import '../../domain/entities/checklist_answer.dart';
import '../../domain/usecases/save_certificate_draft.dart';
import '../../domain/usecases/submit_certificate.dart';
import '../../domain/usecases/watch_certificate.dart';

part 'certificate_state.dart';

/// Backs Feature 05's inspection certificate screen: one job's checklist,
/// load test, photos (stubbed) and final result — autosaved on every
/// discrete change, submitted once everything but photos is filled in.
class CertificateCubit extends Cubit<CertificateState> {
  final InspectionRequest request;
  final WatchCertificate _watchCertificate;
  final SaveCertificateDraft _saveDraft;
  final SubmitCertificate _submitCertificate;

  StreamSubscription<Certificate?>? _subscription;

  CertificateCubit({
    required this.request,
    required WatchCertificate watchCertificate,
    required SaveCertificateDraft saveDraft,
    required SubmitCertificate submitCertificate,
  }) : _watchCertificate = watchCertificate,
       _saveDraft = saveDraft,
       _submitCertificate = submitCertificate,
       super(const CertificateState());

  void start() {
    if (_subscription != null) return;
    _subscription = _watchCertificate(request.id).listen(
      (certificate) {
        final resolved =
            certificate ?? Certificate(requestId: request.id, inspectorId: request.inspectorId ?? '');
        emit(state.copyWith(status: CertificateStatus.ready, certificate: resolved, clearFailure: true));
        // First time this job is opened, there's no document yet — create it
        // so the rest of the app (and this inspector, reopening later) has
        // something to read.
        if (certificate == null) _saveDraft(resolved);
      },
      onError: (Object error) => emit(
        state.copyWith(
          status: CertificateStatus.error,
          failure: error is CertificateFailure ? error.code : CertificateFailureCode.unknown,
        ),
      ),
    );
  }

  Future<void> retry() async {
    await _subscription?.cancel();
    _subscription = null;
    emit(state.copyWith(status: CertificateStatus.loading, clearFailure: true));
    start();
  }

  /// Pass/Fail/N/A is a discrete choice — persist right away.
  void setAnswer(String itemId, ChecklistAnswer answer) {
    final current = state.certificate;
    if (current == null) return;
    _persist(current.copyWith(checklistAnswers: {...current.checklistAnswers, itemId: answer}));
  }

  /// Text fields update local state on every keystroke (so completeness
  /// and the step indicator react live) but only autosave on blur, via
  /// [persist] — otherwise every keystroke would be its own write.
  void updateDefectNoteLocal(String itemId, String note) {
    final current = state.certificate;
    if (current == null) return;
    emit(state.copyWith(certificate: current.copyWith(defectNotes: {...current.defectNotes, itemId: note})));
  }

  void updateTestLoadLocal(double? kg) {
    final current = state.certificate;
    if (current == null) return;
    emit(
      state.copyWith(certificate: current.copyWith(testLoadKg: kg, clearTestLoadKg: kg == null)),
    );
  }

  void updateDurationLocal(int? minutes) {
    final current = state.certificate;
    if (current == null) return;
    emit(
      state.copyWith(
        certificate: current.copyWith(durationMinutes: minutes, clearDurationMinutes: minutes == null),
      ),
    );
  }

  void setFinalResult(CertificateResult result) {
    final current = state.certificate;
    if (current == null) return;
    _persist(current.copyWith(finalResult: result));
  }

  /// Writes whatever's currently in [CertificateState.certificate] — call
  /// after a batch of [updateDefectNoteLocal]/[updateLoadTestLocal] calls
  /// (i.e. on blur).
  Future<void> persist() async {
    final current = state.certificate;
    if (current == null) return;
    await _persist(current);
  }

  Future<void> _persist(Certificate updated) async {
    emit(state.copyWith(certificate: updated, saveStatus: CertificateSaveStatus.saving));
    try {
      await _saveDraft(updated);
      if (isClosed) return;
      emit(state.copyWith(saveStatus: CertificateSaveStatus.saved));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(saveStatus: CertificateSaveStatus.error));
    }
  }

  Future<void> submit() async {
    final certificate = state.certificate;
    if (certificate == null || !certificate.isReadyToSubmit || state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true));
    try {
      await _submitCertificate(certificate);
      if (isClosed) return;
      emit(state.copyWith(isSubmitting: false, actionSeq: state.actionSeq + 1, lastActionSuccess: true));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isSubmitting: false,
          actionSeq: state.actionSeq + 1,
          lastActionSuccess: false,
          lastActionFailure: e is CertificateFailure ? e.code : CertificateFailureCode.unknown,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
