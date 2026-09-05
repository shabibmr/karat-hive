import 'dart:developer' as developer;

/// Thin logger with light PII masking for mobile numbers / emails / tokens.
class AppLogger {
  const AppLogger(this.scope);
  final String scope;

  void info(String message) => developer.log(_mask(message), name: scope);
  void warn(String message) =>
      developer.log(_mask(message), name: scope, level: 900);
  void error(String message, [Object? err, StackTrace? st]) =>
      developer.log(_mask(message), name: scope, level: 1000, error: err, stackTrace: st);

  static String _mask(String s) => s
      .replaceAll(RegExp(r'\+\d{6,15}'), '+***')
      .replaceAll(RegExp(r'[\w.\-]+@[\w.\-]+'), '***@***')
      .replaceAll(RegExp(r'(eyJ[\w\-]+\.[\w\-]+)\.[\w\-]+'), r'$1.***');
}
