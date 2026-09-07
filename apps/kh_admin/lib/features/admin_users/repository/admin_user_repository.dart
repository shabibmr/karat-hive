import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../model/admin_user_filters.dart';
import '../model/admin_user_item.dart';

/// Typed repository for ADM-S23 Admin User Provisioning & Management.
///
/// Communicates with:
/// - `GET /v1/admin/admins`: list existing admin accounts
/// - `POST /v1/admin/admins`: provision a new admin account (coarse RBAC, no role field)
/// - `POST /v1/admin/admins/:id/suspend`: suspend admin account
/// - `POST /v1/admin/admins/:id/revoke`: revoke admin account (backend protects last active admin)
class AdminUserRepository {
  AdminUserRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Fetches admin users matching the given [filters].
  Future<List<AdminUserItem>> fetchAdmins({
    AdminUserFilters filters = const AdminUserFilters(),
  }) async {
    final response = await _apiClient.getCollection(
      '/v1/admin/admins',
      queryParameters:
          filters.toQueryParameters().isEmpty ? null : filters.toQueryParameters(),
    );

    return response.items
        .whereType<Map<String, dynamic>>()
        .map(AdminUserItem.fromJson)
        .where(filters.matches)
        .toList(growable: false);
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

    return AdminUserItem.fromJson(_unwrapEntity(response));
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

/// Unwraps a nested `{ data: { ...entity } }` envelope left after [ApiClient.get].
Map<String, dynamic> _unwrapEntity(dynamic response) {
  if (response is! Map<String, dynamic>) {
    throw StateError('Unexpected response format when creating admin');
  }
  if (response['data'] is Map<String, dynamic> &&
      response['id'] == null &&
      response['profile'] == null &&
      response['user'] == null) {
    return Map<String, dynamic>.from(response['data'] as Map);
  }
  return response;
}

/// Provider for [AdminUserRepository].
final adminUserRepositoryProvider = Provider<AdminUserRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminUserRepository(apiClient);
});
