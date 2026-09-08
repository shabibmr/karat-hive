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

class SignedIn extends SessionState {
  const SignedIn(this.user);
  final MeUser user;

  /// Authenticated account role — drives the role gate (`SH-SHELL-04`,
  /// Architecture-Frontend §7.2). `null` for a discriminator with no mobile
  /// shell (e.g. `ADMIN`); the gate treats that as a session to reject.
  UserRole? get role => user.role;

  bool get isCustomer => role == UserRole.customer;
  bool get isVendor => role == UserRole.vendor;

  VendorLifecycle get vendorLifecycle =>
      user.vendor?.lifecycle ?? VendorLifecycle.unknown;

  /// Customer profile block, present only on a Customer session.
  CustomerMe? get customerProfile => user.customer;
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
        err: (_) async {
          // Unbound Google identity — no KH account yet. Clear any stale tokens.
          await _storage.clear();
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
