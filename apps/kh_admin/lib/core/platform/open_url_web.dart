import 'package:web/web.dart' as web;

/// Opens [url] in a new browser tab on Flutter Web.
void openUrlInNewTab(String url) {
  web.window.open(url, '_blank');
}
