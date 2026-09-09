import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/auth/auth_models.dart';
import 'package:kh_admin/core/auth/token_storage.dart';
import 'package:kh_core/kh_core.dart' as core;

class _FakeCoreTokenStorage extends core.TokenStorage {
  _FakeCoreTokenStorage() : super(null);

  core.SessionTokens? savedTokens;
  bool saveCalled = false;
  bool readCalled = false;
  bool clearCalled = false;

  @override
  Future<void> save(core.SessionTokens tokens) async {
    saveCalled = true;
    savedTokens = tokens;
  }

  @override
  Future<core.SessionTokens?> read() async {
    readCalled = true;
    return savedTokens;
  }

  @override
  Future<void> clear() async {
    clearCalled = true;
    savedTokens = null;
  }
}

void main() {
  group('TokenStorage (TR-S4-01, TR-S4-02)', () {
    final testTokens = SessionTokens(
      accessToken: 'access_abc_123',
      accessExpiresAt: DateTime.utc(2026, 9, 10),
      refreshToken: 'refresh_xyz_789',
      refreshExpiresAt: DateTime.utc(2026, 9, 17),
    );

    test('on web (isWeb: true), tokens are held in-memory and bypass coreStorage/localStorage', () async {
      final fakeCoreStorage = _FakeCoreTokenStorage();
      final webStorage = TokenStorage(
        coreStorage: fakeCoreStorage,
        isWeb: true,
      );

      // Save tokens
      await webStorage.saveTokens(testTokens);

      // Core storage (FlutterSecureStorage/web localStorage) is never touched
      expect(fakeCoreStorage.saveCalled, isFalse);
      expect(fakeCoreStorage.savedTokens, isNull);

      // In-memory access works
      expect(await webStorage.getAccessToken(), 'access_abc_123');
      expect(await webStorage.getRefreshToken(), 'refresh_xyz_789');
      final loaded = await webStorage.loadTokens();
      expect(loaded?.accessToken, 'access_abc_123');
      expect(loaded?.refreshToken, 'refresh_xyz_789');

      // Clear tokens
      await webStorage.clearTokens();
      expect(fakeCoreStorage.clearCalled, isFalse);
      expect(await webStorage.loadTokens(), isNull);
      expect(await webStorage.getAccessToken(), isNull);
    });

    test('on native (isWeb: false), tokens delegate to core secure storage', () async {
      final fakeCoreStorage = _FakeCoreTokenStorage();
      final nativeStorage = TokenStorage(
        coreStorage: fakeCoreStorage,
        isWeb: false,
      );

      await nativeStorage.saveTokens(testTokens);
      expect(fakeCoreStorage.saveCalled, isTrue);
      expect(fakeCoreStorage.savedTokens?.accessToken, 'access_abc_123');

      final loaded = await nativeStorage.loadTokens();
      expect(fakeCoreStorage.readCalled, isTrue);
      expect(loaded?.accessToken, 'access_abc_123');

      await nativeStorage.clearTokens();
      expect(fakeCoreStorage.clearCalled, isTrue);
    });
  });
}
