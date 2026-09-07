import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/firebase_auth_service.dart';
import 'auth_models.dart';
import 'auth_repository.dart';
import 'session_state.dart';
import 'token_storage.dart';

/// Riverpod StateNotifier managing the admin user session, token persistence,
/// and silent 401 token refresh.
class SessionController extends StateNotifier<SessionState> {
  SessionController({
    required TokenStorage tokenStorage,
    required AuthRepository authRepository,
    FirebaseAuthService? firebaseAuthService,
  })  : _tokenStorage = tokenStorage,
        _authRepository = authRepository,
        _firebaseAuthService = firebaseAuthService,
        super(const SessionState()) {
    _initAuthListener();
    init();
  }

  final TokenStorage _tokenStorage;
  final AuthRepository _authRepository;
  final FirebaseAuthService? _firebaseAuthService;
  StreamSubscription<User?>? _firebaseAuthSub;
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

  @override
  void dispose() {
    _firebaseAuthSub?.cancel();
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
    } catch (_) {
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
      } catch (_) {
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
    } catch (_) {
      state = state.copyWith(status: SessionStatus.unauthenticated);
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
    } catch (e) {
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
    } catch (_) {
      completer.complete(false);
      await logout();
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Logs out the user, notifies backend, and deletes persisted tokens.
  Future<void> logout() async {
    final currentTokens = state.tokens;
    state = state.copyWith(
      status: SessionStatus.unauthenticated,
      clearTokens: true,
      clearAdmin: true,
      clearError: true,
    );
    try {
      await _authRepository.logout(currentTokens?.refreshToken);
    } catch (_) {
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
  return SessionController(
    tokenStorage: tokenStorage,
    authRepository: authRepository,
    firebaseAuthService: firebaseAuth,
  );
});
