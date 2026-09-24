/// Shared layout measurements used across features.
class AppLayout {
  AppLayout._();

  /// Space a scrollable tab should reserve at its bottom so its content
  /// doesn't end up hidden behind the floating root bottom nav (excludes
  /// the device safe area, which the scroll view handles separately).
  static const double bottomNavClearance = 90;
}
