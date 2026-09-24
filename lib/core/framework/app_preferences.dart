import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app_theme_mode.dart';

/// Persists user preferences (language, theme, first-launch flag) in secure
/// storage. Call [init] once, before reading any getter.
class AppPreferences {
  AppPreferences(this._storage);

  final FlutterSecureStorage _storage;

  static const _languageKey = 'language';
  static const _themeModeKey = 'theme_mode';
  static const _firstStartUpKey = 'first_start_up';

  String _language = 'en';
  AppThemeMode _appThemeMode = AppThemeMode.system;
  bool _isFirstStartUp = true;

  Future<void> init() async {
    _language = await _storage.read(key: _languageKey) ?? 'en';

    final themeIndex = int.tryParse(
      await _storage.read(key: _themeModeKey) ?? '',
    );
    _appThemeMode = themeIndex != null
        ? getAppThemeModeFromIndex(themeIndex)
        : AppThemeMode.system;

    _isFirstStartUp = await _storage.read(key: _firstStartUpKey) == null;
    if (_isFirstStartUp) {
      await _storage.write(key: _firstStartUpKey, value: 'false');
    }
  }

  String get language => _language;
  set language(String value) {
    _language = value;
    _storage.write(key: _languageKey, value: value);
  }

  AppThemeMode get appThemeMode => _appThemeMode;
  set appThemeMode(AppThemeMode value) {
    _appThemeMode = value;
    _storage.write(key: _themeModeKey, value: '${value.index}');
  }

  bool get isFirstStartUp => _isFirstStartUp;
}
