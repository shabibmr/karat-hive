/// Build flavour + configuration, supplied via --dart-define-from-file.
enum Flavor { dev, staging, prod }

class Env {
  const Env({required this.flavor, required this.apiBaseUrl});

  final Flavor flavor;
  final String apiBaseUrl;

  Env copyWith({
    Flavor? flavor,
    String? apiBaseUrl,
  }) {
    return Env(
      flavor: flavor ?? this.flavor,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
    );
  }

  /// Resolves a server-relative path (e.g. `/v1/media/<key>`) against
  /// [apiBaseUrl]. Already-absolute URLs pass through unchanged.
  String? resolveUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return Uri.parse(apiBaseUrl).resolve(path).toString();
  }

  static Env fromDefines() {
    const flavorName = String.fromEnvironment('KH_FLAVOR', defaultValue: 'dev');
    const baseUrl = String.fromEnvironment(
      'KH_API_BASE_URL',
      defaultValue: 'http://10.0.2.2:3000',
    );
    return Env(
      flavor: Flavor.values.firstWhere(
        (f) => f.name == flavorName,
        orElse: () => Flavor.dev,
      ),
      apiBaseUrl: baseUrl,
    );
  }
}
