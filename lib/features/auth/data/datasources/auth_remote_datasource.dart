import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

/// Firebase Auth for credentials, Firestore `users/{uid}` for the profile
/// (role, qualifications, active flag).
///
/// Firebase instances are resolved lazily so that constructing this class
/// doesn't throw when Firebase failed to initialise.
class AuthRemoteDataSource {
  static const usersCollection = 'users';

  final FirebaseAuth? _authOverride;
  final FirebaseFirestore? _firestoreOverride;

  AuthRemoteDataSource({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _authOverride = auth,
      _firestoreOverride = firestore;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(usersCollection).doc(uid);

  String? get currentUid => _auth.currentUser?.uid;

  /// Emits the signed-in uid, or `null` when signed out.
  Stream<String?> uidChanges() => _auth.authStateChanges().map((u) => u?.uid);

  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!.uid;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset({
    required String email,
    required String languageCode,
  }) async {
    await _auth.setLanguageCode(languageCode);
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserModel?> getUser(String uid) async {
    final snapshot = await _userDoc(uid).get();
    final data = snapshot.data();
    return data == null ? null : UserModel.fromJson(snapshot.id, data);
  }

  Stream<UserModel?> watchUser(String uid) {
    return _userDoc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : UserModel.fromJson(snapshot.id, data);
    });
  }

  Future<void> touchLastLogin(String uid) {
    return _userDoc(uid).update({'lastLogin': FieldValue.serverTimestamp()});
  }
}
