import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';

import '../../../app/session/session_controller.dart';
import '../../../core/firebase/firebase.dart';
import '../repository/customer_auth_repository.dart';

/// Account-status error codes that mean "signed in with Google is fine, but this
/// Karat Hive account may not proceed" — surfaced as a lockout message
/// (`SH-AUTH-07`), never the completion step.
const _lockoutCodes = {
  'ACCOUNT_SUSPENDED',
  'ACCOUNT_DEACTIVATED',
  'ACCOUNT_LOCKED',
};

sealed class CustomerOnboardingState {
  const CustomerOnboardingState();
}

class OnboardingIdle extends CustomerOnboardingState {
  const OnboardingIdle();
}

class OnboardingBusy extends CustomerOnboardingState {
  const OnboardingBusy();
}

/// The Google token authenticated but there is no Karat Hive account yet
/// (`401 UNAUTHENTICATED`, `adr/0010`). Drives the CFE-10 completion step — this
/// is the normal new-user path, not an error.
class OnboardingNeedsCompletion extends CustomerOnboardingState {
  const OnboardingNeedsCompletion({
    required this.firebaseIdToken,
    this.suggestedName,
    this.suggestedEmail,
  });

  final String firebaseIdToken;
  final String? suggestedName;
  final String? suggestedEmail;
}

/// `SH-AUTH-07` — the account cannot sign in. [message] is the server's
/// localised string (`NFR-024`).
class OnboardingLockedOut extends CustomerOnboardingState {
  const OnboardingLockedOut(this.message);
  final String message;
}

class OnboardingFailure extends CustomerOnboardingState {
  const OnboardingFailure(this.failure);
  final Failure failure;
}

/// A Karat Hive session now exists; the role gate routes into the Customer shell.
class OnboardingAuthenticated extends CustomerOnboardingState {
  const OnboardingAuthenticated();
}

/// Drives Google Sign-In on `CUS-S01` (CFE-09). The existing
/// [SessionController] Firebase listener also exchanges the token, but it cannot
/// tell an unbound identity from a plain sign-out, so this controller does its
/// own `google/session` call to branch to the completion step.
class CustomerOnboardingController
    extends AutoDisposeNotifier<CustomerOnboardingState> {
  @override
  CustomerOnboardingState build() => const OnboardingIdle();

  CustomerAuthRepository get _repo => ref.read(customerAuthRepositoryProvider);
  FirebaseAuthService get _firebase => ref.read(firebaseAuthServiceProvider);

  Future<void> signInWithGoogle() async {
    state = const OnboardingBusy();

    try {
      await _firebase.signInWithGoogle();
    } catch (_) {
      state = const OnboardingFailure(NetworkFailure());
      return;
    }

    final idToken = await _firebase.getIdToken(forceRefresh: true);
    if (idToken == null || idToken.isEmpty) {
      // Cancelled picker, or no Firebase user — return to the button.
      state = const OnboardingIdle();
      return;
    }

    final result = await _repo.googleSession(idToken);
    await result.when(
      ok: (bundle) async {
        await ref.read(sessionProvider.notifier).onAuthenticated(bundle);
        state = const OnboardingAuthenticated();
      },
      err: (failure) async {
        state = _mapSignInFailure(failure, idToken);
      },
    );
  }

  CustomerOnboardingState _mapSignInFailure(Failure failure, String idToken) {
    if (_lockoutCodes.contains(failure.code)) {
      return OnboardingLockedOut(failure.message ?? '');
    }
    // Unbound Google identity: backend does not auto-provision (adr/0010).
    if (failure is UnauthorisedFailure &&
        (failure.code == null || failure.code == 'UNAUTHENTICATED')) {
      return OnboardingNeedsCompletion(firebaseIdToken: idToken);
    }
    return OnboardingFailure(failure);
  }
}

final customerOnboardingControllerProvider = AutoDisposeNotifierProvider<
    CustomerOnboardingController, CustomerOnboardingState>(
  CustomerOnboardingController.new,
);

/// `SH-AUTH-06` — biometric-unlock preference. A per-device convenience toggle;
/// the actual biometric prompt / secure-storage persistence is a later slice
/// (nothing personal is written to disk here).
final customerBiometricUnlockProvider = StateProvider<bool>((_) => false);
