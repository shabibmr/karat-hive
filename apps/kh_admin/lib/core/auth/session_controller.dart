import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'session_state.dart';
import 'token_storage.dart';

/// Riverpod StateNotifier managing the admin user session, token persistence,
/// and silent 401 token refresh.
class SessionController extends StateNotifier<SessionState> {
  SessionController({
    required TokenStorage tokenStorage,
    required AuthRepository authRepository,
  })  : _tokenStorage = tokenStorage,
        _authRepository = authRepository,
        super(const SessionState()) {
    init();
  }

  final TokenStorage _tokenStorage;
  final AuthRepository _authRepository;
  Completer<bool>? _refreshCompleter;

  /// Initializes session on app start by reading stored tokens and validating with /v1/me.
  Future<void> init() async {
    state = state.copyWith(status: SessionStatus.loading);
    try {
      final tokens = await _tokenStorage.loadTokens();
      if (tokens == null) {
        state = state.copyWith(status: SessionStatus.unauthenticated);
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
    } finally {
      await _tokenStorage.clearTokens();
    }
  }
}

final StateNotifierProvider<SessionController, SessionState>
    sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return SessionController(
    tokenStorage: tokenStorage,
    authRepository: authRepository,
  );
});
