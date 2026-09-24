import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/enums/job_status.dart';
import '../models/inspection_request_model.dart';

class RequestsRemoteDataSource {
  static const collection = 'requests';

  /// Subcollection of `JobEvent`s per request (00-overview.md §7/§8: every
  /// status change is logged and can't be edited).
  static const eventsSubcollection = 'events';

  final FirebaseFirestore? _firestoreOverride;
  final FirebaseAuth? _authOverride;

  RequestsRemoteDataSource({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestoreOverride = firestore,
      _authOverride = auth;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> _doc(String id) =>
      _firestore.collection(collection).doc(id);

  /// Newest first (BR-02.7's inbox sort).
  Stream<List<InspectionRequestModel>> watchRequests() {
    return _firestore
        .collection(collection)
        .orderBy('receivedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InspectionRequestModel.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<InspectionRequestModel?> getById(String id) async {
    final snapshot = await _doc(id).get();
    final data = snapshot.data();
    return data == null ? null : InspectionRequestModel.fromJson(snapshot.id, data);
  }

  Future<void> updateStatus(
    String requestId,
    JobStatus status, {
    String? note,
    Map<String, dynamic>? extra,
  }) async {
    final batch = _firestore.batch();
    batch.update(_doc(requestId), {'status': status.value, ...?extra});
    batch.set(_doc(requestId).collection(eventsSubcollection).doc(), {
      'toStatus': status.value,
      'actorId': _auth.currentUser?.uid,
      'note': note,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  /// Just the `clientId` field — matching a sender to a client doesn't
  /// change the job's status, so it doesn't log a status-change event.
  Future<void> assignClient(String requestId, String clientId) =>
      _doc(requestId).update({'clientId': clientId});
}
