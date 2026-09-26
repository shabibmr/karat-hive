import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';

import '../../../app/session/session_controller.dart';
import '../../../core/firebase/firebase.dart';
import '../repository/auth_repository.dart';

sealed class LoginState {
  const LoginState();
}

class LoginIdle extends LoginState {
  const LoginIdle();
}

class LoginBusy extends LoginState {
  const LoginBusy();
}

class LoginError extends LoginState {
  const LoginError(this.failure);
  final Failure failure;
}

class LoginNeedsRegistration extends LoginState {
  const LoginNeedsRegistration();
}

class LoginAuthenticated extends LoginState {
  const LoginAuthenticated();
}

class VendorLoginController extends AutoDisposeNotifier<LoginState> {
  bool _disposed = false;

  @override
  LoginState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    return const LoginIdle();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);
  FirebaseAuthService get _firebase => ref.read(firebaseAuthServiceProvider);

  Future<void> signInWithGoogle() async {
    state = const LoginBusy();

    try {
      await _firebase.signInWithGoogle();
    } catch (_) {
      if (_disposed) return;
      state = const LoginError(
        NetworkFailure(message: 'Google Sign-In was cancelled or unavailable.'),
      );
      return;
    }
    if (_disposed) return;

    final idToken = await _firebase.getIdToken(forceRefresh: true);
    if (_disposed) return;
    if (idToken == null || idToken.isEmpty) {
      state = const LoginIdle();
      return;
    }

    final fbUser = _firebase.currentUser;
    final result = await _repo.googleSession(idToken, expectedRole: 'VENDOR');
    if (_disposed) return;
    await result.when(
      ok: (bundle) async {
        await ref.read(sessionProvider.notifier).onAuthenticated(bundle);
        if (_disposed) return;
        state = const LoginAuthenticated();
      },
      err: (failure) async {
        if (failure is UnauthorisedFailure &&
            (failure.code == null || failure.code == 'UNAUTHENTICATED')) {
          // Keep the Firebase token on session so vendor register can bind
          // Google (`adr/0010`) — mirrors customer onboarding hand-off.
          ref.read(sessionProvider.notifier).markUnboundGoogle(
                firebaseIdToken: idToken,
                suggestedName: fbUser?.displayName,
                suggestedEmail: fbUser?.email,
              );
          state = const LoginNeedsRegistration();
        } else if (failure.code != null &&
            kAuthLockoutCodes.contains(failure.code)) {
          ref.read(sessionProvider.notifier).markAuthBlocked(failure);
          state = LoginError(failure);
        } else {
          state = LoginError(failure);
        }
      },
    );
  }
}

final vendorLoginControllerProvider =
    AutoDisposeNotifierProvider<VendorLoginController, LoginState>(
  VendorLoginController.new,
);
