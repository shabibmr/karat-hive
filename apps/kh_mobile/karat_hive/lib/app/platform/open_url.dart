import 'package:url_launcher/url_launcher.dart';

/// Opens an absolute http(s) or `tel:` URL in the external handler.
///
/// Returns `false` when the URL is invalid or no handler is available.
/// Callers must pass a server-supplied URL — do not invent `wa.me` / `tel:`
/// from raw digits (C-03).
Future<bool> openExternalUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'http' && scheme != 'https' && scheme != 'tel') {
    return false;
  }
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
