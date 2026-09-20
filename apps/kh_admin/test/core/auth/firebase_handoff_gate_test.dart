import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/auth/auth_models.dart';
import 'package:kh_admin/core/auth/auth_repository.dart';
import 'package:kh_admin/core/auth/session_controller.dart';
import 'package:kh_admin/core/auth/session_state.dart';
import 'package:kh_admin/core/auth/token_storage.dart';
import 'package:kh_admin/core/firebase/firebase_auth_service.dart';

/// On web the admin portal keeps tokens in memory only (TR-S4-01), so a page
/// reload can recover a session from exactly one place: the Firebase auth
/// state, which resolves asynchronously well after `init()` has run out of
/// local evidence. Opening the bootstrap gate on `init()` alone is what made
/// the login screen flash before the dashboard on every reload.
void main() {
  late _EmptyTokenStorage tokenStorage;
  late _StubAuthRepository authRepository;
  late _StubFirebaseAuthService firebaseAuth;
  SessionController? controller;

  setUp(() {
    tokenStorage = _EmptyTokenStorage();
    authRepository = _StubAuthRepository();
    firebaseAuth = _StubFirebaseAuthService();
  });

  tearDown(() {
    controller?.dispose();
    controller = null;
    firebaseAuth.dispose();
  });

  SessionController build({
    bool awaitsFirebaseHandoff = true,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return controller = SessionController(
      tokenStorage: tokenStorage,
      authRepository: authRepository,
      awaitsFirebaseHandoff: awaitsFirebaseHandoff,
      firebaseHandoffTimeout: timeout,
    );
  }

  test('gate stays closed until Firebase reports its restored session',
      () async {
    final c = build();
    await pumpEventQueue();

    // `init()` has already run out of local evidence, but Firebase has not
    // spoken yet — the router must keep showing the splash, not /login.
    expect(c.state.status, SessionStatus.unauthenticated);
    expect(c.state.bootstrapped, isFalse);

    // Firebase finishes initializing. `currentUser` is still null at this
    // point because persistence has not been read back yet; that is not an
    // answer, so the gate stays closed.
    await c.onFirebaseReady(firebaseAuth);
    await pumpEventQueue();
    expect(c.state.bootstrapped, isFalse);

    // The first `authStateChanges` event is the answer.
    firebaseAuth.emit(null);
    await pumpEventQueue();
    expect(c.state.bootstrapped, isTrue);
    expect(c.state.status, SessionStatus.unauthenticated);
  });

  test('a failed Firebase init opens the gate', () async {
    final c = build();
    await pumpEventQueue();
    expect(c.state.bootstrapped, isFalse);

    c.firebaseUnavailable();
    expect(c.state.bootstrapped, isTrue);
  });

  test('the handoff times out rather than stranding the splash', () async {
    final c = build(timeout: const Duration(milliseconds: 20));
    await pumpEventQueue();
    expect(c.state.bootstrapped, isFalse);

    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(c.state.bootstrapped, isTrue);
  });

  test('a session resolved locally does not wait for Firebase', () async {
    tokenStorage.tokens = _tokens;
    final c = build();
    await pumpEventQueue();

    // Nothing Firebase reports can move an already-authenticated admin
    // somewhere else, so there is nothing to wait for.
    expect(c.state.status, SessionStatus.authenticated);
    expect(c.state.bootstrapped, isTrue);
  });

  test('without a handoff expected the gate opens with init', () async {
    final c = build(awaitsFirebaseHandoff: false);
    await pumpEventQueue();

    expect(c.state.status, SessionStatus.unauthenticated);
    expect(c.state.bootstrapped, isTrue);
  });
}

final _tokens = SessionTokens(
  accessToken: 'access-1',
  accessExpiresAt: DateTime.fromMillisecondsSinceEpoch(1798761599000, isUtc: true),
  refreshToken: 'refresh-1',
  refreshExpiresAt: DateTime.fromMillisecondsSinceEpoch(1798761599000, isUtc: true),
);

class _EmptyTokenStorage extends TokenStorage {
  SessionTokens? tokens;

  @override
  Future<SessionTokens?> loadTokens() async => tokens;

  @override
  Future<void> saveTokens(SessionTokens value) async {
    tokens = value;
  }

  @override
  Future<void> clearTokens() async {
    tokens = null;
  }
}

class _StubAuthRepository extends AuthRepository {
  _StubAuthRepository() : super(ApiClient());

  @override
  Future<AdminUser> getMe() async => const AdminUser(
        userId: 'u-1',
        userType: 'ADMIN',
        email: 'admin@kh.ae',
        displayName: 'Platform Admin',
      );
}

class _StubFirebaseAuthService extends FirebaseAuthService {
  final _events = StreamController<User?>.broadcast();

  @override
  User? get currentUser => null;

  @override
  Stream<User?> get authStateChanges => _events.stream;

  void emit(User? user) => _events.add(user);

  void dispose() => _events.close();
}
