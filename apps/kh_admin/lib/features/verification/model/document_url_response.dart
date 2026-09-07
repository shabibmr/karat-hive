import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_url_response.freezed.dart';
part 'document_url_response.g.dart';

/// Signed URL payload from `GET /v1/admin/vendors/{id}/documents/{docId}/url`.
@freezed
class DocumentUrlResponse with _$DocumentUrlResponse {
  const factory DocumentUrlResponse({
    required String url,
    required DateTime expiresAt,
  }) = _DocumentUrlResponse;

  factory DocumentUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$DocumentUrlResponseFromJson(json);
}
