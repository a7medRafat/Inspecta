/// Single source of truth for asset paths. Given a bare name (see [Svgs],
/// [Pngs], [Jsons]), builds the full `assets/...` path with the right
/// folder and extension, so widgets never hardcode either.
class AssetsManager {
  AssetsManager._();

  static String svg(String name) => 'assets/svgs/$name.svg';
  static String png(String name) => 'assets/pngs/$name.png';
  static String json(String name) => 'assets/jsons/$name.json';
}
