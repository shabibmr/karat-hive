import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/api_exception.dart';
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
    bool awaitsFirebaseHandoff = false,
    Duration firebaseHandoffTimeout = const Duration(seconds: 5),
  })  : _tokenStorage = tokenStorage,
        _authRepository = authRepository,
        _firebaseAuthService = firebaseAuthService,
        _authBroadcast = authBroadcast,
        _devAuth = devAuth,
        _awaitingFirebaseHandoff = awaitsFirebaseHandoff,
        super(const SessionState(bootstrapped: false)) {
    _initBroadcastListener();
    if (_awaitingFirebaseHandoff) {
      // Backstop: if Firebase never initializes and never reports a failure,
      // the admin still reaches the login screen instead of a stuck splash.
      _firebaseHandoffTimer =
          Timer(firebaseHandoffTimeout, _releaseFirebaseHandoff);
    }
    // Legacy tokens / dev auto-login can proceed before Firebase is ready.
    init();
  }

  final TokenStorage _tokenStorage;
  final AuthRepository _authRepository;
  FirebaseAuthService? _firebaseAuthService;
  final AuthBroadcast? _authBroadcast;
  final DevAuthConfig _devAuth;
  StreamSubscription<User?>? _firebaseAuthSub;
  StreamSubscription<void>? _authBroadcastSub;
  Completer<bool>? _refreshCompleter;
  Completer<void>? _syncCompleter;
  String? _syncingFirebaseUid;

  /// True while a Firebase auth handoff is still expected. Firebase resolves
  /// its persisted session asynchronously, so [init] finishing is not the end
  /// of the story: on web it is the *only* way a reload recovers a session,
  /// because tokens are held in memory only (TR-S4-01).
  bool _awaitingFirebaseHandoff;
  Timer? _firebaseHandoffTimer;

  /// Whether the first [init] pass has finished, win or lose.
  bool _initResolved = false;

  void _initBroadcastListener() {
    _authBroadcastSub = _authBroadcast?.onLogout.listen((_) {
      _handleMultiTabLogout();
    });
  }

  void _bindFirebaseAuthListener() {
    _firebaseAuthSub?.cancel();
    _firebaseAuthSub = _firebaseAuthService?.authStateChanges.listen(
      (fbUser) => unawaited(_handleFirebaseAuthState(fbUser)),
      // `authStateChanges` is `Stream.empty()` when Firebase Auth is absent:
      // it closes without ever emitting, so done is the handoff settling.
      onDone: _releaseFirebaseHandoff,
    );
  }

  Future<void> _handleFirebaseAuthState(User? fbUser) async {
    try {
      if (fbUser != null) {
        await _syncFirebaseUser(fbUser);
      } else if (!state.isAuthenticated) {
        await _checkLegacySession();
      }
    } finally {
      // Firebase has now reported the session it restored — or reported that
      // there is none. Either way the handoff is settled.
      _releaseFirebaseHandoff();
    }
  }

  /// Opens the bootstrap gate once nothing still in flight can change where
  /// the admin lands. Idempotent.
  void _completeBootstrap() {
    if (!mounted || state.bootstrapped || !_initResolved) return;
    // An authenticated session has nowhere else to go, so a pending Firebase
    // handoff can only confirm it — no reason to keep the splash up.
    if (_awaitingFirebaseHandoff && !state.isAuthenticated) return;
    state = state.copyWith(bootstrapped: true);
  }

  void _releaseFirebaseHandoff() {
    _firebaseHandoffTimer?.cancel();
    _firebaseHandoffTimer = null;
    _awaitingFirebaseHandoff = false;
    _completeBootstrap();
  }

  /// Firebase initialization failed: no auth handoff is coming, so stop
  /// holding the bootstrap gate open for one.
  void firebaseUnavailable() => _releaseFirebaseHandoff();

  /// Re-bind Firebase auth after [initializeFirebaseNonBlocking] completes.
  ///
  /// Capturing `authStateChanges` before Firebase.initializeApp yields an empty
  /// stream forever — call this once Firebase is ready so Google restore works.
  Future<void> onFirebaseReady(FirebaseAuthService? authService) async {
    _firebaseAuthService = authService ?? _firebaseAuthService;
    _bindFirebaseAuthListener();
    final fbUser = _firebaseAuthService?.currentUser;
    if (fbUser != null) {
      await _handleFirebaseAuthState(fbUser);
    }
    // A null `currentUser` here is not an answer: on web Firebase restores
    // persisted sessions asynchronously and reports the result through
    // `authStateChanges`. Releasing the gate now is what made the login
    // screen flash before the dashboard on reload, so leave it to the
    // listener (or the timeout).
  }

  @override
  void dispose() {
    _firebaseHandoffTimer?.cancel();
    _firebaseAuthSub?.cancel();
    _authBroadcastSub?.cancel();
    super.dispose();
  }

  /// Initializes session on app start by reading stored tokens and validating with /v1/me.
  Future<void> init() async {
    state = state.copyWith(status: SessionStatus.loading);
    try {
      final fbUser = _firebaseAuthService?.currentUser;
      if (fbUser != null) {
        await _syncFirebaseUser(fbUser);
        return;
      }
      await _checkLegacySession();
    } finally {
      // Whatever the outcome, this pass is done. The gate opens now unless a
      // Firebase handoff is still expected to change the answer.
      _initResolved = true;
      _completeBootstrap();
    }
  }

  static bool _isDefinitiveAuthFailure(Object e) {
    if (e is ApiException) {
      return e.statusCode == 401 || e.statusCode == 403;
    }
    return false;
  }

  static bool _isRetryableTransportFailure(Object e) {
    if (e is ApiException) {
      return e.statusCode == 0 ||
          e.code == 'NETWORK_ERROR' ||
          e.code == 'CONNECTION_TIMEOUT' ||
          e.statusCode >= 500;
    }
    final msg = e.toString();
    return msg.contains('Failed to fetch') ||
        msg.contains('NETWORK_ERROR') ||
        msg.contains('CONNECTION_TIMEOUT');
  }

  /// G2-A14: exchange Google ID token for a KH SessionBundle, then use KH tokens.
  Future<void> _syncFirebaseUser(User fbUser) async {
    // Single-flight: concurrent listener + loginWithGoogle must not race.
    while (_syncCompleter != null) {
      await _syncCompleter!.future;
      if (state.isAuthenticated && _syncingFirebaseUid == fbUser.uid) {
        return;
      }
      if (state.isAuthenticated && fbUser.email != null && state.admin?.email == fbUser.email) {
        return;
      }
    }

    final completer = Completer<void>();
    _syncCompleter = completer;
    _syncingFirebaseUid = fbUser.uid;

    // Captured before the status flips: only a session that was already
    // validated may survive a transport failure below.
    final wasAuthenticated = state.isAuthenticated;

    state = state.copyWith(status: SessionStatus.loading, clearError: true);
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
      if (bundle.user.userType != 'ADMIN') {
        await _tokenStorage.clearTokens();
        await _firebaseAuthService?.signOut();
        state = state.copyWith(
          status: SessionStatus.unauthenticated,
          clearAdmin: true,
          clearTokens: true,
          errorMessage:
              'Google account (${fbUser.email}) is not authorized as an Admin.',
        );
        return;
      }
      await _tokenStorage.saveTokens(bundle.tokens);
      state = state.copyWith(
        status: SessionStatus.authenticated,
        tokens: bundle.tokens,
        admin: bundle.user,
        clearError: true,
      );
    } on Object catch (e) {
      // Unbound Google identity or API error — Admin must already exist; no auto-provision.
      // Transport failures must not clear a good in-memory session mid-race.
      if (_isRetryableTransportFailure(e) && wasAuthenticated) {
        state = state.copyWith(
          status: SessionStatus.authenticated,
          errorMessage:
              'Unable to connect to the backend server. Please verify network/CORS configuration.',
        );
        return;
      }
      await _tokenStorage.clearTokens();
      await _firebaseAuthService?.signOut();
      final emailStr = fbUser.email != null ? ' (${fbUser.email})' : '';
      final errorStr = e.toString();
      final String msg;
      if (e is ApiException) {
        msg = e.statusCode == 401
            ? 'Google account$emailStr is not linked to an Admin user.'
            : (e.message.isNotEmpty ? e.message : 'Authentication failed (${e.code})');
      } else if (_isRetryableTransportFailure(e) ||
          errorStr.contains('Failed to fetch') ||
          errorStr.contains('NETWORK_ERROR')) {
        msg =
            'Unable to connect to the backend server. Please verify network/CORS configuration.';
      } else {
        msg = 'Google account$emailStr is not linked to an Admin user.';
      }
      state = state.copyWith(
        status: SessionStatus.unauthenticated,
        clearAdmin: true,
        clearTokens: true,
        errorMessage: msg,
      );
    } finally {
      _syncCompleter = null;
      completer.complete();
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
          clearError: true,
        );
      } on Object catch (e) {
        if (_isRetryableTransportFailure(e)) {
          // Keep tokens; surface retryable error without logging the admin out.
          state = state.copyWith(
            status: SessionStatus.authenticated,
            errorMessage:
                'Unable to reach the server to validate your session. Retry shortly.',
          );
          return;
        }
        // Access token might be expired, attempt one-shot refresh
        final refreshed = await silentRefresh();
        if (refreshed) {
          try {
            final me = await _authRepository.getMe();
            state = state.copyWith(
              status: SessionStatus.authenticated,
              admin: me,
              clearError: true,
            );
          } on Object catch (e2) {
            if (_isRetryableTransportFailure(e2)) {
              state = state.copyWith(
                status: SessionStatus.authenticated,
                errorMessage:
                    'Unable to reach the server to validate your session. Retry shortly.',
              );
            } else if (_isDefinitiveAuthFailure(e2)) {
              await logout();
            } else {
              state = state.copyWith(
                status: SessionStatus.authenticated,
                errorMessage: e2.toString(),
              );
            }
          }
        } else if (!state.isAuthenticated) {
          // silentRefresh already logged out on definitive auth failure
        } else {
          state = state.copyWith(
            status: SessionStatus.authenticated,
            errorMessage:
                'Unable to refresh your session. Check network and retry.',
          );
        }
      }
    } on Object catch (_) {
      state = state.copyWith(
        status: SessionStatus.unauthenticated,
        clearTokens: true,
        clearAdmin: true,
      );
    }
  }

  /// Development-only shortcut: signs in as the seeded admin so the portal
  /// lands on the dashboard without the login screen.
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

  /// Signs in with Google via popup and exchanges token for Karat Hive session.
  Future<void> loginWithGoogle() async {
    final authService = _firebaseAuthService;
    if (authService == null) {
      throw StateError('Firebase Auth is not initialized.');
    }
    state = state.copyWith(status: SessionStatus.loading, clearError: true);
    final cred = await authService.signInWithGoogle();
    if (cred == null || cred.user == null) {
      // User closed or canceled Google popup
      state = state.copyWith(status: SessionStatus.unauthenticated);
      return;
    }
    await _syncFirebaseUser(cred.user!);
    if (!state.isAuthenticated && state.errorMessage != null) {
      throw Exception(state.errorMessage);
    }
  }

  /// Web GIS path: Google ID token → Firebase credential → KH session.
  Future<void> loginWithGoogleIdToken(String idToken) async {
    final authService = _firebaseAuthService;
    if (authService == null) {
      throw StateError('Firebase Auth is not initialized.');
    }
    state = state.copyWith(status: SessionStatus.loading, clearError: true);
    final cred = await authService.signInWithGoogleIdToken(idToken);
    final user = cred.user;
    if (user == null) {
      state = state.copyWith(
        status: SessionStatus.unauthenticated,
        errorMessage: 'Google Sign-In did not return a Firebase user.',
      );
      throw Exception(state.errorMessage);
    }
    await _syncFirebaseUser(user);
    if (!state.isAuthenticated && state.errorMessage != null) {
      throw Exception(state.errorMessage);
    }
  }

  /// Single-flight silent refresh when a 401 is encountered.
  ///
  /// Logs out only on definitive auth failure (401/403). Transport / 5xx
  /// failures keep tokens so a blip does not kick the admin out.
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
        clearError: true,
      );
      completer.complete(true);
      return true;
    } on Object catch (e) {
      completer.complete(false);
      if (_isDefinitiveAuthFailure(e)) {
        await logout();
      } else {
        state = state.copyWith(
          errorMessage: _isRetryableTransportFailure(e)
              ? 'Unable to refresh session (network). Retry shortly.'
              : e.toString(),
        );
      }
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
  final apiClient = ref.watch(apiClientProvider);
  final firebaseAuth = ref.watch(firebaseAuthServiceProvider);
  final authBroadcast = ref.watch(authBroadcastProvider);
  final devAuth = ref.watch(devAuthConfigProvider);
  final controller = SessionController(
    tokenStorage: tokenStorage,
    authRepository: authRepository,
    firebaseAuthService: firebaseAuth,
    authBroadcast: authBroadcast,
    devAuth: devAuth,
    // Web holds tokens in memory only (TR-S4-01), so a reload can only be
    // restored through Firebase. Hold the splash until it reports.
    awaitsFirebaseHandoff: kIsWeb,
  );
  apiClient.onUnauthorized = controller.silentRefresh;
  return controller;
});
