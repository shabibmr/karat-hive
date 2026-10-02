import 'package:kh_core/kh_core.dart';

/// Parses a single JSON object resource from an API body into [T].
Result<T> parseResource<T>(
  dynamic raw,
  T Function(Map<String, dynamic>) fromJson, {
  required String notObjectMessage,
  required String parseFailedMessage,
}) {
  try {
    if (raw is! Map) {
      return Err(ServerFailure(
        code: 'BAD_RESPONSE',
        message: notObjectMessage,
      ));
    }
    return Ok(fromJson(Map<String, dynamic>.from(raw)));
  } catch (_) {
    return Err(ServerFailure(
      code: 'BAD_RESPONSE',
      message: parseFailedMessage,
    ));
  }
}
