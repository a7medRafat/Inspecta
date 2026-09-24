import 'package:flutter/services.dart';

class OrientationHelper {
  static const List<DeviceOrientation> _portraitOnly = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];

  static const List<DeviceOrientation> _landscapeOnly = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  static const List<DeviceOrientation> _allOrientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  /// Lock to portrait mode only
  static Future<void> lockToPortrait() async {
    await SystemChrome.setPreferredOrientations(_portraitOnly);
  }

  /// Lock to landscape mode only
  static Future<void> lockToLandscape() async {
    await SystemChrome.setPreferredOrientations(_landscapeOnly);
  }

  /// Allow all orientations
  static Future<void> allowAllOrientations() async {
    await SystemChrome.setPreferredOrientations(_allOrientations);
  }

  /// Reset to default (portrait only)
  static Future<void> resetToDefault() async {
    await lockToPortrait();
  }
}
