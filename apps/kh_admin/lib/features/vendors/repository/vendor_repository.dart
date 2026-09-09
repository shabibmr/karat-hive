import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/vendors/model/vendor_detail.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_filters.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_item.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_page.dart';
import 'package:kh_admin/core/api/json_parse.dart';

/// Typed repository for `GET /v1/admin/vendors` (ADM-S05, API-Route-Inventory §21.3).
class VendorRepository {
  VendorRepository(this._apiClient);

  final ApiClient _apiClient;

  static const int defaultPageSize = 20;

  Future<VendorListPage> fetchVendors({
    VendorListFilters filters = const VendorListFilters(),
    String? cursor,
    int limit = defaultPageSize,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      if (filters.verificationState != null)
        'verificationState': filters.verificationState!.apiValue,
      if (filters.accountState != null)
        'accountState': filters.accountState!.apiValue,
      if (filters.query.trim().isNotEmpty) 'q': filters.query.trim(),
    };

    final response = await _apiClient.getCollection(
      '/v1/admin/vendors',
      queryParameters: queryParameters,
    );

    final items = response.items
        .whereType<Map<String, dynamic>>()
        .map((raw) => VendorListItem.fromJson(normalizeListItem(raw)))
        .toList(growable: false);

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();

    // origin/main's admin list route never sends `hasMore`/`totalCount` — the
    // only pagination signal is the presence of a cursor for the next page.
    return VendorListPage(
      items: items,
      nextCursor: nextCursor,
      hasMore: hasMoreFromCursor(nextCursor),
    );
  }

  /// Reshapes an origin/main raw `VendorProfile` row from `GET /v1/admin/vendors`
  /// into the flat shape [VendorListItem.fromJson] expects. Main has no DTO
  /// layer, so `accountState` arrives nested under `user`, `aggregateRating` is a
  /// `Decimal` serialised as a JSON string, and the offer/rating rollups use
  /// different field names. `region` and `oldestWaitingHours` are not included on
  /// the list route.
  @visibleForTesting
  static Map<String, dynamic> normalizeListItem(Map<String, dynamic> raw) {
    final normalized = Map<String, dynamic>.from(raw);

    final user = raw['user'];
    final accountState = user is Map<String, dynamic>
        ? user['accountState']?.toString()
        : raw['accountState']?.toString();
    normalized['accountState'] = accountState ?? 'ACTIVE';

    normalized['rating'] =
        toDoubleOrNull(raw['aggregateRating'] ?? raw['rating']);

    final submitted = (raw['offersSubmittedCount'] as num?)?.toInt();
    final accepted = (raw['offersAcceptedCount'] as num?)?.toInt();
    normalized['offerCount'] = submitted;
    normalized['acceptanceRate'] = (submitted != null && submitted > 0)
        ? (accepted ?? 0) / submitted
        : null;

    normalized['region'] = raw['region'];
    normalized.remove('oldestWaitingHours');

    return normalized;
  }

  Future<VendorDetail> fetchVendorDetail(String vendorId) async {
    final response = await _apiClient.get('/v1/admin/vendors/$vendorId');
    final map = Map<String, dynamic>.from(response as Map<String, dynamic>);
    return VendorDetail.fromJson(map);
  }

  Future<void> suspendVendor(
    String vendorId, {
    required String reasonCode,
    required String reasonText,
  }) async {
    await _apiClient.post(
      '/v1/admin/vendors/$vendorId/suspend',
      data: {
        'reasonCode': reasonCode,
        'reasonText': reasonText,
      },
    );
  }

  Future<void> reactivateVendor(
    String vendorId, {
    String reasonCode = 'ADMIN_REACTIVATED',
    String reasonText = 'KYC verified',
  }) async {
    await _apiClient.post(
      '/v1/admin/vendors/$vendorId/reactivate',
      data: {
        'reasonCode': reasonCode,
        'reasonText': reasonText,
      },
    );
  }

  Future<void> deactivateVendor(
    String vendorId, {
    required String reasonCode,
    required String reasonText,
  }) async {
    await _apiClient.post(
      '/v1/admin/vendors/$vendorId/deactivate',
      data: {
        'reasonCode': reasonCode,
        'reasonText': reasonText,
      },
    );
  }
}

final Provider<VendorRepository> vendorRepositoryProvider =
    Provider<VendorRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VendorRepository(apiClient);
});
