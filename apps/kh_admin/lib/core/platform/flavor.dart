import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/core/api/api_client.dart';

/// Supported application flavors (TR-S4-15 / E26 / ADM-INS-81).
enum AppFlavor {
  dev,
  staging,
  prod;

  static AppFlavor fromString(String? value) {
    if (value == null) return AppFlavor.dev;
    switch (value.toLowerCase().trim()) {
      case 'prod':
      case 'production':
        return AppFlavor.prod;
      case 'staging':
      case 'stage':
        return AppFlavor.staging;
      case 'dev':
      case 'development':
      default:
        return AppFlavor.dev;
    }
  }
}

/// Flavor runtime configuration.
class FlavorConfig {
  const FlavorConfig({
    required this.flavor,
    required this.apiBaseUrl,
  });

  final AppFlavor flavor;
  final String apiBaseUrl;

  bool get isDev => flavor == AppFlavor.dev;
  bool get isStaging => flavor == AppFlavor.staging;
  bool get isProd => flavor == AppFlavor.prod;

  /// TR-S4-16 (ADM-INS-82): Prod flavor refuses a non-HTTPS base.
  void validate() {
    if (isProd) {
      final uri = Uri.tryParse(apiBaseUrl);
      if (uri == null || uri.scheme.toLowerCase() != 'https') {
        throw StateError(
          'Production environment requires a secure HTTPS apiBaseUrl (KH_API_BASE). '
          'Received: "$apiBaseUrl"',
        );
      }
    }
  }
}

const String _kFlavorString = String.fromEnvironment('KH_FLAVOR', defaultValue: 'dev');

/// Global flavor config provider overridable per build or test.
final flavorConfigProvider = Provider<FlavorConfig>((ref) {
  final flavor = AppFlavor.fromString(_kFlavorString);
  final config = FlavorConfig(
    flavor: flavor,
    apiBaseUrl: khApiBase,
  );
  config.validate();
  return config;
});
