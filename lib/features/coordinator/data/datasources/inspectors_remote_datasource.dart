import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/data/models/user_model.dart';

class InspectorsRemoteDataSource {
  static const collection = 'users';

  final FirebaseFirestore? _firestoreOverride;

  InspectorsRemoteDataSource({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  /// `firestore.rules` only lets a coordinator read `users` docs whose
  /// `role` is `inspector`, so that's the only filter this query needs.
  Stream<List<UserModel>> watchInspectors() {
    return _firestore
        .collection(collection)
        .where('role', isEqualTo: 'inspector')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserModel.fromJson(doc.id, doc.data())).toList());
  }

  /// Just the `onLeaveUntil` field — `firestore.rules` scopes a
  /// coordinator's write to exactly this key on an inspector's profile.
  Future<void> markOnLeave(String inspectorId, DateTime? until) {
    return _firestore.collection(collection).doc(inspectorId).update({
      'onLeaveUntil': until == null ? null : Timestamp.fromDate(until),
    });
  }
}
