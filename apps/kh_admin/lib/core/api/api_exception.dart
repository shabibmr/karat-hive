import 'package:flutter/foundation.dart';

/// Typed API exception representing backend error envelopes:
/// `{ error: { code: string, message: string, details: [...] }, meta: { requestId, serverTime } }`
@immutable
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details = const [],
    this.requestId,
  });

  final int statusCode;
  final String code;
  final String message;
  final List<dynamic> details;
  final String? requestId;

  @override
  String toString() =>
      'ApiException(status: $statusCode, code: "$code", message: "$message", requestId: $requestId)';
}
