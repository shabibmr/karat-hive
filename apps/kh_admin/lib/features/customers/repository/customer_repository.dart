import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/customers/model/customer_detail.dart';
import 'package:kh_admin/features/customers/model/customer_list_filters.dart';
import 'package:kh_admin/features/customers/model/customer_list_item.dart';
import 'package:kh_admin/features/customers/model/customer_list_page.dart';
import 'package:kh_admin/core/api/json_parse.dart';

/// Repository for customer management endpoints (ADM-S03, ADM-S04).
class CustomerRepository {
  CustomerRepository(this._apiClient);

  final ApiClient _apiClient;

  static const int defaultPageSize = 20;

  /// Fetches a cursor-paginated list of customers matching [filters].
  ///
  /// Calls `GET /v1/admin/customers` with `q`, `state`, `limit`, and `cursor`.
  Future<CustomerListPage> fetchCustomers({
    CustomerListFilters filters = const CustomerListFilters(),
    String? cursor,
    int limit = defaultPageSize,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      if (filters.accountState != null)
        'state': filters.accountState!.apiValue,
      if (filters.query.trim().isNotEmpty) 'q': filters.query.trim(),
    };

    final response = await _apiClient.getCollection(
      '/v1/admin/customers',
      queryParameters: queryParameters,
    );

    final items = response.items
        .whereType<Map<String, dynamic>>()
        .map((raw) => CustomerListItem.fromJson(normalizeListItem(raw)))
        .toList(growable: false);

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();

    // Access to customer personal data in bulk is audit-logged (FR-ADM-010 AC5, ADM-INS-40, TR-S1-30).
    if (cursor == null || cursor.isEmpty) {
      await logCustomerListAccess();
    }

    return CustomerListPage(
      items: items,
      nextCursor: nextCursor,
      totalCount:
          meta?['total'] is num ? (meta!['total'] as num).toInt() : null,
    );
  }

  /// Records an access audit log entry when the customer list is loaded (FR-ADM-010 AC5 / ADM-INS-40).
  Future<void> logCustomerListAccess() async {
    try {
      await _apiClient.post(
        '/v1/admin/audit-log',
        data: <String, dynamic>{
          'action': 'CUSTOMER_LIST_VIEWED',
          'entityType': 'customer_list',
          'occurredAt': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } on Object {
      // Best-effort audit logging; swallow failures so list loading is never blocked.
    }
  }

  /// Normalizes a raw Prisma customer row into the format expected by [CustomerListItem].
  ///
  /// Lifts nested user fields (`user.accountState`, `user.email`, `user.mobileNumber`,
  /// `user.createdAt`) to top level, and extracts request count rollups if present.
  @visibleForTesting
  static Map<String, dynamic> normalizeListItem(Map<String, dynamic> raw) {
    final normalized = Map<String, dynamic>.from(raw);

    final user = raw['user'];
    if (user is Map<String, dynamic>) {
      final accountState = user['accountState']?.toString();
      if (accountState != null) {
        normalized['accountState'] = accountState;
      }
      if (raw['email'] == null && user['email'] != null) {
        normalized['email'] = user['email'];
      }
      if (raw['mobileNumber'] == null && user['mobileNumber'] != null) {
        normalized['mobileNumber'] = user['mobileNumber'];
      }
      if (raw['createdAt'] == null && user['createdAt'] != null) {
        normalized['createdAt'] = user['createdAt'];
      }
      if (raw['userId'] == null && user['id'] != null) {
        normalized['userId'] = user['id'];
      }
    }
    normalized['accountState'] ??= 'ACTIVE';

    if (raw['requestCount'] == null) {
      final countObj = raw['_count'];
      if (countObj is Map<String, dynamic> && countObj['requests'] is num) {
        normalized['requestCount'] = (countObj['requests'] as num).toInt();
      } else if (raw['requests'] is List) {
        normalized['requestCount'] = (raw['requests'] as List).length;
      }
    }

    return normalized;
  }

  /// Fetches the full customer detail by ID or User ID (ADM-S04).
  ///
  /// Calls `GET /v1/admin/customers/$customerId` and joins with admin notes.
  Future<CustomerDetail> fetchCustomerDetail(String customerId) async {
    final response = await _apiClient.get('/v1/admin/customers/$customerId');
    final map = unwrapEntity(response);

    List<CustomerAdminNote> notes = const [];
    try {
      notes = await listAdminNotes(customerId);
    } on Object catch (_) {
      // Best-effort: if note list fails, use whatever notes were embedded in customer response
    }

    return CustomerDetail.fromJson(map, notes: notes.isNotEmpty ? notes : null);
  }

  /// Suspends a customer account with a reason code and text explanation.
  ///
  /// Calls `POST /v1/admin/customers/$customerId/suspend`.
  Future<void> suspendCustomer(
    String customerId, {
    required String reasonCode,
    required String reasonText,
  }) async {
    await _apiClient.post(
      '/v1/admin/customers/$customerId/suspend',
      data: {
        'reasonCode': reasonCode,
        'reasonText': reasonText,
      },
    );
  }

  /// Reactivates a suspended customer account with a justification.
  ///
  /// Calls `POST /v1/admin/customers/$customerId/reactivate`.
  Future<void> reactivateCustomer(
    String customerId, {
    required String reasonText,
  }) async {
    await _apiClient.post(
      '/v1/admin/customers/$customerId/reactivate',
      data: {
        'reasonText': reasonText,
      },
    );
  }

  /// Requests permanent erasure / anonymization of customer PII (FR-CUS-004).
  ///
  /// Calls `POST /v1/admin/customers/$customerId/erasure`.
  Future<void> erasureCustomer(
    String customerId, {
    required String reasonText,
  }) async {
    await _apiClient.post(
      '/v1/admin/customers/$customerId/erasure',
      data: {'reasonText': reasonText},
    );
  }

  /// Adds an internal admin note to this customer.
  ///
  /// Calls `POST /v1/admin/customers/$customerId/notes`.
  Future<CustomerAdminNote> createAdminNote(
    String customerId,
    String text,
  ) async {
    final response = await _apiClient.post(
      '/v1/admin/customers/$customerId/notes',
      data: {'text': text},
    );
    final map = unwrapEntity(response);
    return CustomerAdminNote.fromJson(map);
  }

  /// Lists all admin notes recorded for this customer.
  ///
  /// Calls `GET /v1/admin/customers/$customerId/notes`.
  Future<List<CustomerAdminNote>> listAdminNotes(String customerId) async {
    final response =
        await _apiClient.get('/v1/admin/customers/$customerId/notes');
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map(CustomerAdminNote.fromJson)
          .toList();
    }
    return const [];
  }
}

/// Provider for [CustomerRepository].
final Provider<CustomerRepository> customerRepositoryProvider =
    Provider<CustomerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CustomerRepository(apiClient);
});
