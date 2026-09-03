import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/auth/auth_models.dart';
import 'package:kh_admin/core/auth/auth_repository.dart';
import 'package:kh_admin/core/auth/session_controller.dart';
import 'package:kh_admin/core/auth/session_state.dart';
import 'package:kh_admin/core/auth/token_storage.dart';

class _MockTokenStorage extends TokenStorage {
  SessionTokens? _tokens;

  @override
  Future<SessionTokens?> loadTokens() async => _tokens;

  @override
  Future<void> saveTokens(SessionTokens tokens) async {
    _tokens = tokens;
  }

  @override
  Future<void> clearTokens() async {
    _tokens = null;
  }
}

class _MockAuthRepository extends AuthRepository {
  _MockAuthRepository() : super(ApiClient());

  bool loginCalled = false;
  bool refreshCalled = false;
  bool logoutCalled = false;

  @override
  Future<SessionBundle> login(String email, String password) async {
    loginCalled = true;
    return const SessionBundle(
      tokens: SessionTokens(
        accessToken: 'access-1',
        accessExpiresAt: '2026-12-31T23:59:59Z',
        refreshToken: 'refresh-1',
        refreshExpiresAt: '2026-12-31T23:59:59Z',
      ),
      user: AdminUser(
        userId: 'u-1',
        userType: 'ADMIN',
        email: 'admin@kh.ae',
        displayName: 'Platform Admin',
      ),
    );
  }

  @override
  Future<SessionBundle> refresh(String refreshToken) async {
    refreshCalled = true;
    return const SessionBundle(
      tokens: SessionTokens(
        accessToken: 'access-2',
        accessExpiresAt: '2026-12-31T23:59:59Z',
        refreshToken: 'refresh-2',
        refreshExpiresAt: '2026-12-31T23:59:59Z',
      ),
      user: AdminUser(
        userId: 'u-1',
        userType: 'ADMIN',
        email: 'admin@kh.ae',
        displayName: 'Platform Admin',
      ),
    );
  }

  @override
  Future<void> logout(String? refreshToken) async {
    logoutCalled = true;
  }

  @override
  Future<AdminUser> getMe() async {
    return const AdminUser(
      userId: 'u-1',
      userType: 'ADMIN',
      email: 'admin@kh.ae',
      displayName: 'Platform Admin',
    );
  }
}

void main() {
  late _MockTokenStorage tokenStorage;
  late _MockAuthRepository authRepository;
  late SessionController controller;

  setUp(() {
    tokenStorage = _MockTokenStorage();
    authRepository = _MockAuthRepository();
    controller = SessionController(
      tokenStorage: tokenStorage,
      authRepository: authRepository,
    );
  });

  test('SessionController starts unauthenticated when storage is empty', () async {
    await controller.init();
    expect(controller.state.status, SessionStatus.unauthenticated);
    expect(controller.state.isAuthenticated, isFalse);
  });

  test('SessionController logs in and updates state to authenticated', () async {
    await controller.login('admin@kh.ae', 'secret123');
    expect(authRepository.loginCalled, isTrue);
    expect(controller.state.status, SessionStatus.authenticated);
    expect(controller.state.isAuthenticated, isTrue);
    expect(controller.state.admin?.displayName, 'Platform Admin');
    expect(controller.state.tokens?.accessToken, 'access-1');

    final stored = await tokenStorage.loadTokens();
    expect(stored?.accessToken, 'access-1');
  });

  test('SessionController silently refreshes and updates tokens', () async {
    await controller.login('admin@kh.ae', 'secret123');
    final success = await controller.silentRefresh();
    expect(success, isTrue);
    expect(authRepository.refreshCalled, isTrue);
    expect(controller.state.tokens?.accessToken, 'access-2');
  });

  test('SessionController logout clears state and token storage', () async {
    await controller.login('admin@kh.ae', 'secret123');
    await controller.logout();
    expect(authRepository.logoutCalled, isTrue);
    expect(controller.state.status, SessionStatus.unauthenticated);
    expect(controller.state.isAuthenticated, isFalse);
    expect(await tokenStorage.loadTokens(), isNull);
  });
}
