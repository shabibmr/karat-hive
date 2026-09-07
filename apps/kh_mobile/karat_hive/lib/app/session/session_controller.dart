import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../core/firebase/firebase_auth_service.dart';
import '../di.dart';

sealed class SessionState {
  const SessionState();
}

class SessionLoading extends SessionState {
  const SessionLoading();
}

class SignedOut extends SessionState {
  const SignedOut();
}

/// Google identity is signed in, but no Karat Hive user exists yet (401 UNAUTHENTICATED).
class UnboundGoogle extends SessionState {
  const UnboundGoogle();
}

/// Google/session refused with an account-state error and no usable MeUser.
class AuthBlocked extends SessionState {
  const AuthBlocked(this.failure);
  final Failure failure;
}

class SignedIn extends SessionState {
  const SignedIn(this.user);
  final MeUser user;

  UserRole get role => UserRole.parse(user.userType);

  bool get isCustomer => role == UserRole.customer;

  bool get isVendor => role == UserRole.vendor;

  bool get isCustomerBlocked =>
      isCustomer &&
      (user.accountState == AccountState.suspended ||
          user.accountState == AccountState.deactivated);

  /// Vendor routing only. Customer sessions must not fall through to this.
  VendorLifecycle get vendorLifecycle =>
      user.vendor?.lifecycle ?? VendorLifecycle.unknown;
}

/// Keep-alive session provider: tokens, current user, vendor lifecycle
/// (Architecture-Frontend §6.2, §7.2).
class SessionController extends Notifier<SessionState> {
  KhApi get _api => ref.read(khApiProvider);
  TokenStorage get _storage => ref.read(tokenStorageProvider);
  FirebaseAuthService get _authService => ref.read(firebaseAuthServiceProvider);
  StreamSubscription<User?>? _authSub;

  @override
  SessionState build() {
    _authSub?.cancel();
    _authSub = _authService.authStateChanges.listen((fbUser) {
      if (fbUser == null) {
        _checkLegacySession();
      } else {
        _exchangeGoogleSession(fbUser);
      }
    });
    ref.onDispose(() => _authSub?.cancel());

    _restore();
    return const SessionLoading();
  }

  Future<void> _restore() async {
    final fbUser = _authService.currentUser;
    if (fbUser != null) {
      await _exchangeGoogleSession(fbUser);
      return;
    }
    await _checkLegacySession();
  }

  Future<void> _checkLegacySession() async {
    final tokens = await _storage.read();
    if (tokens == null) {
      state = const SignedOut();
      return;
    }
    await refreshUser();
  }

  /// G2-A14: after Google Sign-In, exchange the ID token for a KH SessionBundle,
  /// then call domain routes with the KH access token only.
  Future<void> _exchangeGoogleSession(User fbUser) async {
    try {
      final idToken = await fbUser.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        state = const SignedOut();
        return;
      }
      final result = await _api.googleSession(idToken: idToken);
      await result.when(
        ok: (bundle) async {
          await _storage.save(bundle.tokens);
          state = SignedIn(bundle.user);
        },
        err: (failure) async {
          await _storage.clear();
          final code = failure.code;
          if (code == 'ACCOUNT_SUSPENDED' || code == 'ACCOUNT_DEACTIVATED') {
            state = AuthBlocked(failure);
            return;
          }
          // Unbound Google identity — no KH account yet (401 UNAUTHENTICATED).
          if (failure is UnauthorisedFailure) {
            state = const UnboundGoogle();
            return;
          }
          state = const SignedOut();
        },
      );
    } catch (_) {
      await _storage.clear();
      state = const SignedOut();
    }
  }

  Future<void> refreshUser() async {
    final result = await _api.me();
    state = result.when(
      ok: (user) => SignedIn(user),
      err: (_) => const SignedOut(),
    );
  }

  Future<void> onAuthenticated(SessionBundle bundle) async {
    await _storage.save(bundle.tokens);
    state = SignedIn(bundle.user);
  }

  Future<void> signOut() async {
    final tokens = await _storage.read();
    if (tokens != null) {
      await _api.logout(tokens.refreshToken);
      await _storage.clear();
    }
    await _authService.signOut();
    state = const SignedOut();
  }
}

final sessionProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);
