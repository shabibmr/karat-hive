import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import 'auth_models.dart';

/// Authentication repository talking to backend identity endpoints.
class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Logs in an admin using email and password.
  Future<SessionBundle> login(String email, String password) async {
    final res = await _apiClient.post(
      '/v1/auth/login/password',
      data: {
        'email': email,
        'password': password,
      },
    );
    return SessionBundle.fromJson(res as Map<String, dynamic>);
  }

  /// Exchanges a Google / Firebase ID token for a Karat Hive session (`AD-API-13`).
  Future<SessionBundle> googleSession(String idToken) async {
    final res = await _apiClient.post(
      '/v1/auth/google/session',
      data: {'idToken': idToken},
    );
    return SessionBundle.fromJson(res as Map<String, dynamic>);
  }

  /// Rotates refresh token and returns a new session bundle.
  Future<SessionBundle> refresh(String refreshToken) async {
    final res = await _apiClient.post(
      '/v1/auth/refresh',
      data: {
        'refreshToken': refreshToken,
      },
    );
    return SessionBundle.fromJson(res as Map<String, dynamic>);
  }

  /// Revokes refresh token and logs out the admin.
  Future<void> logout(String? refreshToken) async {
    try {
      await _apiClient.post(
        '/v1/auth/logout',
        data: {
          'refreshToken': refreshToken,
        },
      );
    } catch (_) {
      // Best-effort logout: ignore server errors and proceed with local cleanup
    }
  }

  /// Fetches current authenticated admin profile.
  Future<AdminUser> getMe() async {
    final res = await _apiClient.get('/v1/me');
    return AdminUser.fromJson(res as Map<String, dynamic>);
  }
}

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});
