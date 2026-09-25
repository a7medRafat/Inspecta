part of 'certificate_cubit.dart';

enum CertificateStatus { loading, ready, error }

enum CertificateSaveStatus { idle, saving, saved, error }

class CertificateState extends Equatable {
  final CertificateStatus status;
  final Certificate? certificate;
  final CertificateFailureCode? failure;
  final CertificateSaveStatus saveStatus;

  final bool isSubmitting;
  final int actionSeq;
  final bool lastActionSuccess;
  final CertificateFailureCode? lastActionFailure;

  const CertificateState({
    this.status = CertificateStatus.loading,
    this.certificate,
    this.failure,
    this.saveStatus = CertificateSaveStatus.idle,
    this.isSubmitting = false,
    this.actionSeq = 0,
    this.lastActionSuccess = false,
    this.lastActionFailure,
  });

  CertificateStep get currentStep => certificate.currentStep;

  int get currentStepNumber => certificate.currentStepNumber;

  int get totalSteps => certificate.totalSteps;

  CertificateState copyWith({
    CertificateStatus? status,
    Certificate? certificate,
    CertificateFailureCode? failure,
    bool clearFailure = false,
    CertificateSaveStatus? saveStatus,
    bool? isSubmitting,
    int? actionSeq,
    bool? lastActionSuccess,
    CertificateFailureCode? lastActionFailure,
  }) {
    return CertificateState(
      status: status ?? this.status,
      certificate: certificate ?? this.certificate,
      failure: clearFailure ? null : (failure ?? this.failure),
      saveStatus: saveStatus ?? this.saveStatus,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionSeq: actionSeq ?? this.actionSeq,
      lastActionSuccess: lastActionSuccess ?? this.lastActionSuccess,
      lastActionFailure: lastActionFailure ?? this.lastActionFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    certificate,
    failure,
    saveStatus,
    isSubmitting,
    actionSeq,
    lastActionSuccess,
    lastActionFailure,
  ];
}
