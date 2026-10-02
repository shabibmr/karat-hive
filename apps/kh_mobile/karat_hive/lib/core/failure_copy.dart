import 'package:kh_core/kh_core.dart';

String khFailureMessage(Object error, String fallback) {
  if (error is Failure) {
    final message = error.message;
    if (message != null && message.isNotEmpty) return message;
    final code = error.code;
    if (code != null && code.isNotEmpty) return '$fallback ($code)';
  }
  return '$fallback (${error.runtimeType})';
}
