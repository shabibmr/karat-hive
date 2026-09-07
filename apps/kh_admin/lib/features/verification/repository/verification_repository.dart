import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../model/document_url_response.dart';
import '../model/verification_decision_dto.dart';
import '../model/verification_queue_item.dart';
import '../model/vendor_verification_detail.dart';

/// Typed repository for ADM-S07 verification queue endpoints (API §21.3).
class VerificationRepository {
  VerificationRepository(this._apiClient);

  final ApiClient _apiClient;

  /// `GET /v1/admin/verification-queue` — oldest-first pending vendors.
  Future<List<VerificationQueueItem>> fetchQueue() async {
    final response = await _apiClient.get('/v1/admin/verification-queue');

    if (response is List) {
      return response
          .map(
            (item) =>
                VerificationQueueItem.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    return const [];
  }

  /// `GET /v1/admin/vendors/{id}` — unmasked vendor profile with documents.
  Future<VendorVerificationDetail> fetchVendorDetail(String vendorId) async {
    final response = await _apiClient.get('/v1/admin/vendors/$vendorId');
    final map = Map<String, dynamic>.from(response as Map<String, dynamic>);
    return VendorVerificationDetail.fromJson(_normalizeVendorDetail(map));
  }

  static Map<String, dynamic> _normalizeVendorDetail(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['categories'] = _extractTaxonomyNames(json['categories']);
    normalized['regions'] = _extractTaxonomyNames(json['regions']);
    normalized['documents'] = _normalizeDocuments(json['documents']);
    if (json['user'] is Map<String, dynamic>) {
      final user = json['user'] as Map<String, dynamic>;
      normalized['mobileNumber'] = user['mobileNumber']?.toString();
    }
    return normalized;
  }

  static List<String> _extractTaxonomyNames(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((item) {
          if (item is String) return item;
          if (item is Map<String, dynamic>) {
            return item['nameEn']?.toString() ?? item['name']?.toString() ?? '';
          }
          return '';
        })
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
  }

  static List<Map<String, dynamic>> _normalizeDocuments(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((item) {
      final map = Map<String, dynamic>.from(item as Map<String, dynamic>);
      final media = map['media'];
      if (media is Map<String, dynamic>) {
        map['fileName'] = media['fileName'] ?? media['originalFileName'];
        map['mimeType'] = media['mimeType'] ?? media['contentType'];
        map['sizeBytes'] = media['sizeBytes'] ?? media['byteSize'];
      }
      return map;
    }).toList(growable: false);
  }

  /// `GET /v1/admin/vendors/{id}/documents/{docId}/url` — audited signed URL.
  Future<DocumentUrlResponse> fetchDocumentUrl({
    required String vendorId,
    required String documentId,
  }) async {
    final response = await _apiClient.get(
      '/v1/admin/vendors/$vendorId/documents/$documentId/url',
    );
    return DocumentUrlResponse.fromJson(response as Map<String, dynamic>);
  }

  /// `POST /v1/admin/vendors/{id}/verify`
  Future<void> verifyVendor(String vendorId, VerifyDecisionDto dto) async {
    await _apiClient.post(
      '/v1/admin/vendors/$vendorId/verify',
      data: dto.toJson(),
    );
  }

  /// `POST /v1/admin/vendors/{id}/reject`
  Future<void> rejectVendor(String vendorId, RejectDecisionDto dto) async {
    await _apiClient.post(
      '/v1/admin/vendors/$vendorId/reject',
      data: dto.toJson(),
    );
  }

  /// `POST /v1/admin/vendors/{id}/request-info`
  Future<void> requestInfo(String vendorId, RequestInfoDto dto) async {
    await _apiClient.post(
      '/v1/admin/vendors/$vendorId/request-info',
      data: dto.toJson(),
    );
  }
}

final Provider<VerificationRepository> verificationRepositoryProvider =
    Provider<VerificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VerificationRepository(apiClient);
});
