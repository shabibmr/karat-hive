import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

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

  VendorLifecycle get vendorLifecycle =>
      user.vendor?.lifecycle ?? VendorLifecycle.unknown;
}

/// Keep-alive session provider: tokens, current user, vendor lifecycle
/// (Architecture-Frontend §6.2, §7.2).
class SessionController extends Notifier<SessionState> {
  KhApi get _api => ref.read(khApiProvider);
  TokenStorage get _storage => ref.read(tokenStorageProvider);

  @override
  SessionState build() {
    _restore();
    return const SessionLoading();
  }

  Future<void> _restore() async {
    final tokens = await _storage.read();
    if (tokens == null) {
      state = const SignedOut();
      return;
    }
    await refreshUser();
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
    await _api.logout(tokens?.refreshToken);
    await _storage.clear();
    state = const SignedOut();
  }
}

final sessionProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);
