import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';

import '../../../app/session/session_controller.dart';
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

class LoginOtpSent extends LoginState {
  const LoginOtpSent(this.challengeId);
  final String challengeId;
}

class LoginError extends LoginState {
  const LoginError(this.failure);
  final Failure failure;
}

class LoginAuthenticated extends LoginState {
  const LoginAuthenticated();
}

class VendorLoginController extends AutoDisposeNotifier<LoginState> {
  @override
  LoginState build() => const LoginIdle();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> sendOtp(String mobileNumber) async {
    state = const LoginBusy();
    final r = await _repo.requestOtp(mobileNumber, 'LOGIN');
    state = r.when(
      ok: (c) => LoginOtpSent(c.challengeId),
      err: LoginError.new,
    );
  }

  Future<void> verifyOtp(String challengeId, String code) async {
    state = const LoginBusy();
    final r = await _repo.verifyOtp(challengeId, code);
    await r.when(
      ok: (res) async {
        if (res.session == null) {
          state = const LoginError(ValidationFailure(message: 'That code is incorrect.'));
          return;
        }
        await ref.read(sessionProvider.notifier).onAuthenticated(res.session!);
        state = const LoginAuthenticated();
      },
      err: (f) async => state = LoginError(f),
    );
  }

  Future<void> loginPassword(String email, String password) async {
    state = const LoginBusy();
    final r = await _repo.loginPassword(email, password);
    await r.when(
      ok: (bundle) async {
        await ref.read(sessionProvider.notifier).onAuthenticated(bundle);
        state = const LoginAuthenticated();
      },
      err: (f) async => state = LoginError(f),
    );
  }
}

final vendorLoginControllerProvider =
    AutoDisposeNotifierProvider<VendorLoginController, LoginState>(
  VendorLoginController.new,
);
