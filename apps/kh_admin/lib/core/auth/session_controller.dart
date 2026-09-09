import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/auth/auth_broadcast.dart';
import 'package:kh_admin/core/auth/auth_repository.dart';
import 'package:kh_admin/core/auth/dev_auth.dart';
import 'package:kh_admin/core/auth/session_state.dart';
import 'package:kh_admin/core/auth/token_storage.dart';
import 'package:kh_admin/core/firebase/firebase_auth_service.dart';

/// Riverpod StateNotifier managing the admin user session, token persistence,
/// and silent 401 token refresh.
class SessionController extends StateNotifier<SessionState> {
  SessionController({
    required TokenStorage tokenStorage,
    required AuthRepository authRepository,
    FirebaseAuthService? firebaseAuthService,
    AuthBroadcast? authBroadcast,
    DevAuthConfig devAuth = DevAuthConfig.disabled,
  })  : _tokenStorage = tokenStorage,
        _authRepository = authRepository,
        _firebaseAuthService = firebaseAuthService,
        _authBroadcast = authBroadcast,
        _devAuth = devAuth,
        super(const SessionState()) {
    _initAuthListener();
    _initBroadcastListener();
    init();
  }

  final TokenStorage _tokenStorage;
  final AuthRepository _authRepository;
  final FirebaseAuthService? _firebaseAuthService;
  final AuthBroadcast? _authBroadcast;
  final DevAuthConfig _devAuth;
  StreamSubscription<User?>? _firebaseAuthSub;
  StreamSubscription<void>? _authBroadcastSub;
  Completer<bool>? _refreshCompleter;

  void _initAuthListener() {
    _firebaseAuthSub = _firebaseAuthService?.authStateChanges.listen((fbUser) {
      if (fbUser != null) {
        _syncFirebaseUser(fbUser);
      } else {
        _checkLegacySession();
      }
    });
  }

  void _initBroadcastListener() {
    _authBroadcastSub = _authBroadcast?.onLogout.listen((_) {
      _handleMultiTabLogout();
    });
  }

  @override
  void dispose() {
    _firebaseAuthSub?.cancel();
    _authBroadcastSub?.cancel();
    super.dispose();
  }

  /// Initializes session on app start by reading stored tokens and validating with /v1/me.
  Future<void> init() async {
    state = state.copyWith(status: SessionStatus.loading);
    final fbUser = _firebaseAuthService?.currentUser;
    if (fbUser != null) {
      await _syncFirebaseUser(fbUser);
      return;
    }
    await _checkLegacySession();
  }

  /// G2-A14: exchange Google ID token for a KH SessionBundle, then use KH tokens.
  Future<void> _syncFirebaseUser(User fbUser) async {
    try {
      final idToken = await fbUser.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        state = state.copyWith(
          status: SessionStatus.unauthenticated,
          clearAdmin: true,
          clearTokens: true,
        );
        return;
      }
      final bundle = await _authRepository.googleSession(idToken);
      await _tokenStorage.saveTokens(bundle.tokens);
      state = state.copyWith(
        status: SessionStatus.authenticated,
        tokens: bundle.tokens,
        admin: bundle.user,
        clearError: true,
      );
    } on Object catch (_) {
      // Unbound Google identity — Admin must already exist; no auto-provision.
      await _tokenStorage.clearTokens();
      state = state.copyWith(
        status: SessionStatus.unauthenticated,
        clearAdmin: true,
        clearTokens: true,
        errorMessage: 'Google account is not linked to an Admin user.',
      );
    }
  }

  Future<void> _checkLegacySession() async {
    try {
      final tokens = await _tokenStorage.loadTokens();
      if (tokens == null) {
        if (await _tryDevAutoLogin()) return;
        state = state.copyWith(
          status: SessionStatus.unauthenticated,
          clearAdmin: true,
          clearTokens: true,
        );
        return;
      }

      state = state.copyWith(tokens: tokens);
      try {
        final me = await _authRepository.getMe();
        state = state.copyWith(
          status: SessionStatus.authenticated,
          admin: me,
        );
      } on Object catch (_) {
        // Access token might be expired, attempt one-shot refresh
        final refreshed = await silentRefresh();
        if (refreshed) {
          final me = await _authRepository.getMe();
          state = state.copyWith(
            status: SessionStatus.authenticated,
            admin: me,
          );
        } else {
          await logout();
        }
      }
    } on Object catch (_) {
      state = state.copyWith(status: SessionStatus.unauthenticated);
    }
  }

  /// Development-only shortcut: signs in as the seeded admin so the portal
  /// lands on the dashboard without the login screen.
  ///
  /// This performs a *real* password login, so the session carries genuine
  /// backend tokens and every `/v1/admin/*` call keeps working. Any failure
  /// (backend down, admin not seeded) is swallowed so the caller falls through
  /// to `unauthenticated` and the normal login screen is shown.
  Future<bool> _tryDevAutoLogin() async {
    if (!_devAuth.autoLogin) return false;
    try {
      await login(_devAuth.email, _devAuth.password);
      return state.isAuthenticated;
    } on Object catch (_) {
      return false;
    }
  }

  /// Logs in with email and password, persists tokens, and loads admin profile.
  Future<void> login(String email, String password) async {
    state = state.copyWith(status: SessionStatus.loading, clearError: true);
    try {
      final bundle = await _authRepository.login(email, password);
      await _tokenStorage.saveTokens(bundle.tokens);
      state = state.copyWith(
        status: SessionStatus.authenticated,
        tokens: bundle.tokens,
        admin: bundle.user,
        clearError: true,
      );
    } on Object catch (e) {
      state = state.copyWith(
        status: SessionStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Form submission alias for [login] with email and password.
  Future<void> loginWithPassword(String email, String password) =>
      login(email, password);

  /// Single-flight silent refresh when a 401 is encountered.
  Future<bool> silentRefresh() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final currentTokens = state.tokens ?? await _tokenStorage.loadTokens();
      if (currentTokens == null || currentTokens.refreshToken.isEmpty) {
        completer.complete(false);
        return false;
      }

      final bundle = await _authRepository.refresh(currentTokens.refreshToken);
      await _tokenStorage.saveTokens(bundle.tokens);
      state = state.copyWith(
        status: SessionStatus.authenticated,
        tokens: bundle.tokens,
        admin: bundle.user,
      );
      completer.complete(true);
      return true;
    } on Object catch (_) {
      completer.complete(false);
      await logout();
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Handles multi-tab logout notification from another browser tab (TR-S4-05).
  Future<void> _handleMultiTabLogout() async {
    if (state.isAuthenticated) {
      state = state.copyWith(
        status: SessionStatus.unauthenticated,
        clearTokens: true,
        clearAdmin: true,
        clearError: true,
      );
      await _tokenStorage.clearTokens();
      await _firebaseAuthService?.signOut();
    }
  }

  /// Logs out the user, notifies backend, broadcasts to other tabs, and deletes persisted tokens.
  Future<void> logout({bool broadcast = true}) async {
    if (broadcast) {
      _authBroadcast?.broadcastLogout();
    }
    final currentTokens = state.tokens;
    state = state.copyWith(
      status: SessionStatus.unauthenticated,
      clearTokens: true,
      clearAdmin: true,
      clearError: true,
    );
    try {
      await _authRepository.logout(currentTokens?.refreshToken);
    } on Object catch (_) {
      // Ignore API logout errors on teardown
    } finally {
      await _tokenStorage.clearTokens();
      await _firebaseAuthService?.signOut();
    }
  }
}

final StateNotifierProvider<SessionController, SessionState>
    sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final firebaseAuth = ref.watch(firebaseAuthServiceProvider);
  final authBroadcast = ref.watch(authBroadcastProvider);
  final devAuth = ref.watch(devAuthConfigProvider);
  return SessionController(
    tokenStorage: tokenStorage,
    authRepository: authRepository,
    firebaseAuthService: firebaseAuth,
    authBroadcast: authBroadcast,
    devAuth: devAuth,
  );
});

