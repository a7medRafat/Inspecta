import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../consts/fonts.dart';

enum AppThemeMode { light, dark, system }

extension AppThemeModeX on AppThemeMode {
  bool get isDarkTheme {
    switch (this) {
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.light:
        return false;
      case AppThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  /// Builds the app's theme, picking [Fonts.ar]/[Fonts.en] to match the
  /// active locale.
  ThemeData themeData(String languageCode) {
    final brightness = isDarkTheme ? Brightness.dark : Brightness.light;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: languageCode == 'ar' ? Fonts.ar : Fonts.en,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColours.primaryColor,
        brightness: brightness,
      ),
    );
  }
}

AppThemeMode getAppThemeModeFromIndex(int index) {
  if (index < 0 || index >= AppThemeMode.values.length) {
    return AppThemeMode.system;
  }
  return AppThemeMode.values[index];
}
