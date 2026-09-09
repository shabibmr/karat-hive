import 'package:kh_core/kh_core.dart';
export 'package:kh_core/kh_core.dart' show Failure;

/// Thin adapter mapping [ApiException] to sealed [Failure] (ADM-SMP-01).
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details = const [],
    this.requestId,
    this.failure,
  });
  final int statusCode;
  final String code;
  final String message;
  final List<dynamic> details;
  final String? requestId;
  final Failure? failure;

  Failure toFailure() => failure ?? ServerFailure(code: code, message: message);

  @override
  String toString() =>
      'ApiException(status: $statusCode, code: "$code", message: "$message", requestId: $requestId)';
}
