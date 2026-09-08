import 'package:kh_core/kh_core.dart';

String khFailureMessage(Object error, String fallback) {
  if (error is Failure) {
    final message = error.message;
    if (message != null && message.isNotEmpty) return message;
  }
  return fallback;
}
