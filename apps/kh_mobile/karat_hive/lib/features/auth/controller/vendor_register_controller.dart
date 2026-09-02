import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/session/session_controller.dart';
import '../model/register_form_state.dart';
import '../repository/auth_repository.dart';

/// Flow-scoped (not screen-scoped) so back-navigation never loses the form
/// (Architecture-Frontend §6.2).
class VendorRegisterController extends Notifier<RegisterFormState> {
  @override
  RegisterFormState build() => const RegisterFormState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  void patch(RegisterFormState Function(RegisterFormState) update) =>
      state = update(state);

  Future<void> sendOtp() async {
    state = state.copyWith(busy: true, clearFailure: true);
    final r = await _repo.requestOtp(state.mobileNumber, 'REGISTER_VENDOR');
    state = r.when(
      ok: (c) => state.copyWith(
        busy: false,
        step: RegisterStep.otp,
        challengeId: c.challengeId,
      ),
      err: (f) => state.copyWith(busy: false, failure: f),
    );
  }

  Future<void> verifyOtp(String code) async {
    final cid = state.challengeId;
    if (cid == null) return;
    state = state.copyWith(busy: true, clearFailure: true);
    final r = await _repo.verifyOtp(cid, code);
    state = await r.when(
      ok: (res) async {
        if (!res.mobileVerified) {
          return state.copyWith(busy: false);
        }
        return _submit();
      },
      err: (f) async => state.copyWith(busy: false, failure: f),
    );
  }

  Future<RegisterFormState> _submit() async {
    state = state.copyWith(step: RegisterStep.submitting, busy: true);
    final r = await _repo.registerVendor(state.toRegisterBody());
    return r.when(
      ok: (bundle) {
        ref.read(sessionProvider.notifier).onAuthenticated(bundle);
        return state.copyWith(step: RegisterStep.done, busy: false);
      },
      err: (f) => state.copyWith(step: RegisterStep.details, busy: false, failure: f),
    );
  }
}

final vendorRegisterControllerProvider =
    NotifierProvider<VendorRegisterController, RegisterFormState>(
  VendorRegisterController.new,
);
