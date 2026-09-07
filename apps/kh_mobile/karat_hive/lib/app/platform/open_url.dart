import 'package:url_launcher/url_launcher.dart';

/// Opens an absolute http(s) URL in the external browser / app handler.
///
/// Returns `false` when the URL is invalid or no handler is available.
Future<bool> openExternalUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
    return false;
  }
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
