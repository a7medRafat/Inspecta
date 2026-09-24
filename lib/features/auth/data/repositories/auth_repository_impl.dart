import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._remote, this._local);

  @override
  Future<void> applySessionPolicy() async {
    try {
      if (_remote.currentUid != null && !await _local.keepSignedIn()) {
        await _remote.signOut();
      }
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Stream<AppUser?> watch() {
    StreamSubscription<String?>? uidSub;
    StreamSubscription<UserModel?>? profileSub;
    late final StreamController<AppUser?> controller;

    Future<void> rejectSession(String uid, AuthFailure failure) async {
      // Ignore late events from a session that has already ended.
      if (_remote.currentUid != uid) return;
      controller.addError(failure);
      await _remote.signOut();
    }

    void onUid(String? uid) {
      profileSub?.cancel();
      profileSub = null;
      if (uid == null) {
        controller.add(null);
        return;
      }
      profileSub = _remote.watchUser(uid).listen(
        (model) {
          final failure = _validate(model);
          if (failure != null) {
            rejectSession(uid, failure);
          } else {
            controller.add(model!.toEntity());
          }
        },
        onError: (Object e) => rejectSession(uid, _mapError(e)),
      );
    }

    controller = StreamController<AppUser?>(
      onListen: () {
        try {
          uidSub = _remote.uidChanges().listen(
            onUid,
            onError: (Object e) => controller.addError(_mapError(e)),
          );
        } catch (e) {
          controller.addError(_mapError(e));
          controller.add(null);
        }
      },
      onCancel: () async {
        await profileSub?.cancel();
        await uidSub?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final uid = _remote.currentUid;
      if (uid == null) return null;
      final model = await _remote.getUser(uid);
      return _validate(model) == null ? model!.toEntity() : null;
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
    required bool keepSignedIn,
  }) async {
    try {
      final uid = await _remote.signIn(email: email, password: password);
      final model = await _remote.getUser(uid);
      final failure = _validate(model);
      if (failure != null) {
        await _remote.signOut();
        throw failure;
      }
      await _local.setKeepSignedIn(keepSignedIn);
      unawaited(
        _remote.touchLastLogin(uid).catchError((Object e) {
          debugPrint('Could not update lastLogin: $e');
        }),
      );
      return model!.toEntity()!;
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remote.signOut();
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> sendPasswordReset({
    required String email,
    required String languageCode,
  }) async {
    try {
      await _remote.sendPasswordReset(email: email, languageCode: languageCode);
    } on FirebaseAuthException catch (e) {
      // Don't reveal whether an account exists for this email.
      if (e.code == 'user-not-found') return;
      throw _mapError(e);
    } catch (e) {
      throw _mapError(e);
    }
  }

  /// Returns why [model] can't be signed in, or `null` if it can.
  AuthFailure? _validate(UserModel? model) {
    if (model == null || model.toEntity() == null) {
      return const AuthFailure(AuthFailureCode.noProfile);
    }
    if (!model.active) {
      return const AuthFailure(AuthFailureCode.accountDisabled);
    }
    return null;
  }

  AuthFailure _mapError(Object error) {
    if (error is AuthFailure) return error;
    if (error is FirebaseAuthException) {
      return AuthFailure(switch (error.code) {
        'invalid-email' => AuthFailureCode.invalidEmail,
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' ||
        'INVALID_LOGIN_CREDENTIALS' => AuthFailureCode.invalidCredentials,
        'user-disabled' => AuthFailureCode.accountDisabled,
        'too-many-requests' => AuthFailureCode.tooManyAttempts,
        'network-request-failed' => AuthFailureCode.network,
        _ => AuthFailureCode.unknown,
      });
    }
    if (error is FirebaseException) {
      return AuthFailure(switch ((error.plugin, error.code)) {
        ('core', _) => AuthFailureCode.unavailable,
        (_, 'permission-denied') => AuthFailureCode.noProfile,
        (_, 'unavailable') => AuthFailureCode.network,
        _ => AuthFailureCode.unknown,
      });
    }
    debugPrint('Unexpected auth error: $error');
    // FirebaseAuth.instance throws a non-Firebase error when no app exists.
    if (Firebase.apps.isEmpty) {
      return const AuthFailure(AuthFailureCode.unavailable);
    }
    return const AuthFailure(AuthFailureCode.unknown);
  }
}
