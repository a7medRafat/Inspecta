import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/certificate_model.dart';

class CertificateRemoteDataSource {
  static const collection = 'certificates';

  final FirebaseFirestore? _firestoreOverride;

  CertificateRemoteDataSource({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String requestId) =>
      _firestore.collection(collection).doc(requestId);

  /// `null` until the inspector's first save creates the document — the
  /// doc id is always the job's request id (one certificate per job).
  Stream<CertificateModel?> watchCertificate(String requestId) {
    return _doc(requestId).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : CertificateModel.fromJson(requestId, data);
    });
  }

  Future<void> save(CertificateModel model) =>
      _doc(model.requestId).set(model.toJson(), SetOptions(merge: true));

  /// Same fields as [save], plus a server-stamped `submittedAt` — used
  /// only when the inspector actually submits (or resubmits), never on a
  /// regular autosave.
  Future<void> submit(CertificateModel model) => _doc(model.requestId).set({
    ...model.toJson(),
    'submittedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}
