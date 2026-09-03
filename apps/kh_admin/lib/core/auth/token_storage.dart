import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_models.dart';

/// Secure token persistence wrapping [FlutterSecureStorage].
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _kAccessToken = 'kh_admin_access_token';
  static const String _kAccessExpiresAt = 'kh_admin_access_expires_at';
  static const String _kRefreshToken = 'kh_admin_refresh_token';
  static const String _kRefreshExpiresAt = 'kh_admin_refresh_expires_at';

  /// Saves the full set of session tokens.
  Future<void> saveTokens(SessionTokens tokens) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: tokens.accessToken),
      _storage.write(key: _kAccessExpiresAt, value: tokens.accessExpiresAt),
      _storage.write(key: _kRefreshToken, value: tokens.refreshToken),
      _storage.write(key: _kRefreshExpiresAt, value: tokens.refreshExpiresAt),
    ]);
  }

  /// Loads saved tokens, returning null if any essential token is missing.
  Future<SessionTokens?> loadTokens() async {
    final access = await _storage.read(key: _kAccessToken);
    final refresh = await _storage.read(key: _kRefreshToken);

    if (access == null || refresh == null || access.isEmpty || refresh.isEmpty) {
      return null;
    }

    final accessExp = await _storage.read(key: _kAccessExpiresAt) ?? '';
    final refreshExp = await _storage.read(key: _kRefreshExpiresAt) ?? '';

    return SessionTokens(
      accessToken: access,
      accessExpiresAt: accessExp,
      refreshToken: refresh,
      refreshExpiresAt: refreshExp,
    );
  }

  /// Clears all stored tokens.
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kAccessExpiresAt),
      _storage.delete(key: _kRefreshToken),
      _storage.delete(key: _kRefreshExpiresAt),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);

  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});
