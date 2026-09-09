import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kh_core/kh_core.dart' as core;

import 'package:kh_admin/core/auth/auth_models.dart';

/// Secure token persistence adapting [core.TokenStorage] with typed [DateTime] expiries (ADM-SMP-01).
///
/// On [kIsWeb] (Architecture-Frontend §18.1, TR-S4-01, TR-S4-02), tokens are held in-memory only:
/// access token is never persisted to localStorage/indexedDB, and refresh token is not persisted across reloads.
class TokenStorage {
  TokenStorage({
    FlutterSecureStorage? storage,
    core.TokenStorage? coreStorage,
    bool isWeb = kIsWeb,
  })  : _coreStorage = coreStorage ?? core.TokenStorage(storage),
        _isWeb = isWeb;

  final core.TokenStorage _coreStorage;
  final bool _isWeb;
  SessionTokens? _memoryTokens;

  /// Saves the full set of session tokens.
  Future<void> saveTokens(SessionTokens tokens) async {
    if (_isWeb) {
      _memoryTokens = tokens;
      return;
    }
    await _coreStorage.save(
      core.SessionTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        accessExpiresAt: tokens.accessExpiresAt,
        refreshExpiresAt: tokens.refreshExpiresAt,
      ),
    );
  }

  /// Loads saved tokens, returning null if any essential token is missing.
  Future<SessionTokens?> loadTokens() async {
    if (_isWeb) {
      return _memoryTokens;
    }
    final coreTokens = await _coreStorage.read();
    if (coreTokens == null) return null;
    return SessionTokens(
      accessToken: coreTokens.accessToken,
      accessExpiresAt: coreTokens.accessExpiresAt,
      refreshToken: coreTokens.refreshToken,
      refreshExpiresAt: coreTokens.refreshExpiresAt,
    );
  }

  /// Clears all stored tokens.
  Future<void> clearTokens() async {
    if (_isWeb) {
      _memoryTokens = null;
      return;
    }
    await _coreStorage.clear();
  }

  Future<String?> getAccessToken() async {
    if (_isWeb) {
      return _memoryTokens?.accessToken;
    }
    final tokens = await _coreStorage.read();
    return tokens?.accessToken;
  }

  Future<String?> getRefreshToken() async {
    if (_isWeb) {
      return _memoryTokens?.refreshToken;
    }
    final tokens = await _coreStorage.read();
    return tokens?.refreshToken;
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});
