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
  @override
  LoginState build() => const LoginIdle();

  AuthRepository get _repo => ref.read(authRepositoryProvider);
  FirebaseAuthService get _firebase => ref.read(firebaseAuthServiceProvider);

  Future<void> signInWithGoogle() async {
    state = const LoginBusy();

    try {
      await _firebase.signInWithGoogle();
    } catch (_) {
      state = const LoginError(
        NetworkFailure(message: 'Google Sign-In was cancelled or unavailable.'),
      );
      return;
    }

    final idToken = await _firebase.getIdToken(forceRefresh: true);
    if (idToken == null || idToken.isEmpty) {
      state = const LoginIdle();
      return;
    }

    final result = await _repo.googleSession(idToken);
    await result.when(
      ok: (bundle) async {
        await ref.read(sessionProvider.notifier).onAuthenticated(bundle);
        state = const LoginAuthenticated();
      },
      err: (failure) async {
        if (failure is UnauthorisedFailure &&
            (failure.code == null || failure.code == 'UNAUTHENTICATED')) {
          state = const LoginNeedsRegistration();
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
