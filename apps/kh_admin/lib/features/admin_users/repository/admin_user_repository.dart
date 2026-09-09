import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/json_parse.dart';
import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_filters.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_item.dart';

/// Typed repository for ADM-S23 Admin User Provisioning & Management.
///
/// Communicates with:
/// - `GET /v1/admin/admins`: list existing admin accounts with cursor pagination (TR-S1-28)
/// - `POST /v1/admin/admins`: provision a new admin account (coarse RBAC, no role field)
/// - `POST /v1/admin/admins/:id/suspend`: suspend admin account
/// - `POST /v1/admin/admins/:id/revoke`: revoke admin account (backend protects last active admin)
class AdminUserRepository {
  AdminUserRepository(this._apiClient);

  final ApiClient _apiClient;

  static const int defaultLimit = 20;

  /// Fetches admin users matching the given [filters] with cursor pagination (TR-S1-28).
  Future<Paginated<AdminUserItem>> fetchAdmins({
    AdminUserFilters filters = const AdminUserFilters(),
    String? cursor,
    int limit = defaultLimit,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      ...filters.toQueryParameters(),
    };

    final response = await _apiClient.getCollection(
      '/v1/admin/admins',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    final items = response.items
        .whereType<Map<String, dynamic>>()
        .map(AdminUserItem.fromJson)
        .toList(growable: false);

    final meta = response.meta;
    final nextCursor = meta?['nextCursor']?.toString();

    return Paginated<AdminUserItem>(
      items: items,
      nextCursor: nextCursor,
      totalCount:
          meta?['total'] is num ? (meta!['total'] as num).toInt() : null,
    );
  }

  /// Provisions a new administrator account with [email] and [displayName].
  ///
  /// Per SAM-GAP-13 and AD-API-03, roles are coarse/fixed for system admins;
  /// no `role` parameter is sent in the payload.
  Future<AdminUserItem> createAdmin({
    required String email,
    required String displayName,
  }) async {
    final response = await _apiClient.post(
      '/v1/admin/admins',
      data: <String, dynamic>{
        'email': email.trim(),
        'displayName': displayName.trim(),
      },
    );

    return AdminUserItem.fromJson(unwrapEntity(response));
  }

  /// Suspends the administrator account with identifier [id].
  Future<void> suspendAdmin(String id) async {
    await _apiClient.post('/v1/admin/admins/$id/suspend');
  }

  /// Revokes the administrator account with identifier [id].
  ///
  /// Note: The backend enforces activeCount > 1 to protect the last remaining
  /// active administrator and returns 409 Conflict if violated.
  Future<void> revokeAdmin(String id) async {
    await _apiClient.post('/v1/admin/admins/$id/revoke');
  }
}

/// Provider for [AdminUserRepository].
final adminUserRepositoryProvider = Provider<AdminUserRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminUserRepository(apiClient);
});
