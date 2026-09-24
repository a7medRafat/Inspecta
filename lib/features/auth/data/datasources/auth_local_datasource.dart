import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Device-local auth settings. Firebase Auth persists the session itself;
/// this only remembers whether the user asked to stay signed in.
class AuthLocalDataSource {
  static const _keepSignedInKey = 'keep_signed_in';

  final FlutterSecureStorage _storage;

  const AuthLocalDataSource(this._storage);

  Future<bool> keepSignedIn() async {
    return await _storage.read(key: _keepSignedInKey) != 'false';
  }

  Future<void> setKeepSignedIn(bool value) {
    return _storage.write(key: _keepSignedInKey, value: value.toString());
  }
}
