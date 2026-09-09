import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/json_parse.dart';
import 'package:kh_admin/features/verification/model/document_url_response.dart';
import 'package:kh_admin/features/verification/model/verification_decision_dto.dart';
import 'package:kh_admin/features/verification/model/verification_queue_item.dart';
import 'package:kh_admin/features/verification/model/vendor_verification_detail.dart';

/// Typed repository for ADM-S07 verification queue endpoints (API §21.3).
class VerificationRepository {
  VerificationRepository(this._apiClient);

  final ApiClient _apiClient;

  /// `GET /v1/admin/verification-queue` — oldest-first pending vendors.
  ///
  /// origin/main returns a bare array of raw `VendorProfile` rows (no
  /// `oldestWaitingHours`, no `submittedAt`). We derive the wait figure from
  /// `createdAt` here so the queue can show how long each vendor has waited.
  Future<List<VerificationQueueItem>> fetchQueue() async {
    final response = await _apiClient.getCollection('/v1/admin/verification-queue');
    return response.items
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => VerificationQueueItem.fromJson(
            _normalizeQueueItem(item),
          ),
        )
        .toList();
  }

  static Map<String, dynamic> _normalizeQueueItem(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    final createdAtRaw = json['createdAt'] ?? json['submittedAt'];
    final createdAt = createdAtRaw is String
        ? DateTime.tryParse(createdAtRaw)
        : null;
    if (createdAt != null) {
      final elapsed = DateTime.now().toUtc().difference(createdAt.toUtc());
      final hours = elapsed.inMinutes / 60.0;
      normalized['oldestWaitingHours'] = hours < 0 ? 0.0 : hours;
      normalized['submittedAt'] ??= createdAtRaw;
    }
    return normalized;
  }

  /// `GET /v1/admin/vendors/{id}` — unmasked vendor profile with documents.
  Future<VendorVerificationDetail> fetchVendorDetail(String vendorId) async {
    final response = await _apiClient.get('/v1/admin/vendors/$vendorId');
    final map = unwrapEntity(response);
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
            // origin/main shape: join rows carrying a nested taxonomy object,
            // e.g. `{categoryId, category: {nameEn, nameAr}}` /
            // `{regionId, region: {nameEn, nameAr}}`.
            final nested = item['category'] ?? item['region'];
            if (nested is Map<String, dynamic>) {
              return nested['nameEn']?.toString() ??
                  nested['nameAr']?.toString() ??
                  '';
            }
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
        // origin/main `Media` has no filename — `fileName` stays null.
        // It carries `contentType` / `byteSize`, so those fallbacks fire.
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
