class Jsons {
  static const logo = 'app_logo_animation';
  static const success = 'success';
  static const loading = 'loading';
  static const error = 'error';
  static const empty = 'empty';
  static const connectivityDot = 'dot';

  /// Onboarding hero illustrations. Each has a locale-specific asset —
  /// build the file name with [hero] (e.g. `${Jsons.hero(1, 'ar')}`).
  static String hero(int page, String languageCode) =>
      'hero-0$page-$languageCode';
}
