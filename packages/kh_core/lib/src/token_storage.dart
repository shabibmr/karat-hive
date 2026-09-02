import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionTokens {
  const SessionTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;
  final DateTime refreshExpiresAt;
}

/// Persists the refresh/access tokens in the platform keystore.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kAccess = 'kh.access';
  static const _kRefresh = 'kh.refresh';
  static const _kAccessExp = 'kh.access_exp';
  static const _kRefreshExp = 'kh.refresh_exp';

  Future<void> save(SessionTokens tokens) async {
    await _storage.write(key: _kAccess, value: tokens.accessToken);
    await _storage.write(key: _kRefresh, value: tokens.refreshToken);
    await _storage.write(
      key: _kAccessExp,
      value: tokens.accessExpiresAt.toIso8601String(),
    );
    await _storage.write(
      key: _kRefreshExp,
      value: tokens.refreshExpiresAt.toIso8601String(),
    );
  }

  Future<SessionTokens?> read() async {
    final access = await _storage.read(key: _kAccess);
    final refresh = await _storage.read(key: _kRefresh);
    if (access == null || refresh == null) return null;
    return SessionTokens(
      accessToken: access,
      refreshToken: refresh,
      accessExpiresAt:
          DateTime.tryParse(await _storage.read(key: _kAccessExp) ?? '') ??
              DateTime.now().toUtc(),
      refreshExpiresAt:
          DateTime.tryParse(await _storage.read(key: _kRefreshExp) ?? '') ??
              DateTime.now().toUtc(),
    );
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kAccessExp);
    await _storage.delete(key: _kRefreshExp);
  }
}
