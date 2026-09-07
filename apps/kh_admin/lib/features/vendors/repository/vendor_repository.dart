import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../model/vendor_detail.dart';
import '../model/vendor_list_filters.dart';
import '../model/vendor_list_item.dart';
import '../model/vendor_list_page.dart';

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
        .map(VendorListItem.fromJson)
        .toList(growable: false);

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();
    final hasMore = meta?['hasMore'] as bool?;

    return VendorListPage(
      items: items,
      nextCursor: nextCursor,
      hasMore: hasMore,
    );
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
