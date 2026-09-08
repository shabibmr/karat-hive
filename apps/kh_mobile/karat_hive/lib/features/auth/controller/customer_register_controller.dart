import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';

import '../../../app/session/session_controller.dart';
import '../../../core/firebase/firebase_auth_service.dart';
import '../model/customer_register_form_state.dart';
import '../repository/auth_repository.dart';

class CustomerRegisterController extends AutoDisposeNotifier<CustomerRegisterFormState> {
  @override
  CustomerRegisterFormState build() => const CustomerRegisterFormState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  void patch(CustomerRegisterFormState Function(CustomerRegisterFormState) update) =>
      state = update(state);

  Future<void> sendOtp() async {
    state = state.copyWith(busy: true, clearFailure: true);
    final r = await _repo.requestOtp(state.mobileNumber.trim(), 'REGISTER_CUSTOMER');
    state = r.when(
      ok: (c) => state.copyWith(
        busy: false,
        step: CustomerRegisterStep.otp,
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
    await r.when(
      ok: (res) async {
        if (!res.mobileVerified) {
          state = state.copyWith(
            busy: false,
            failure: const ValidationFailure(message: 'That code is incorrect.'),
          );
          return;
        }
        state = state.copyWith(mobileVerified: true);
        await _submit();
      },
      err: (f) async => state = state.copyWith(busy: false, failure: f),
    );
  }

  Future<void> _submit() async {
    state = state.copyWith(step: CustomerRegisterStep.submitting, busy: true);
    final trimmedEmail = state.email.trim();
    final r = await _repo.registerCustomer(
      challengeId: state.challengeId,
      displayName: state.displayName.trim(),
      email: trimmedEmail.isEmpty ? null : trimmedEmail,
      preferredLanguage: state.preferredLanguage,
      termsVersion: '1.0',
      privacyVersion: '1.0',
    );
    await r.when(
      ok: (bundle) async {
        await ref.read(sessionProvider.notifier).onAuthenticated(bundle);
        await _bindGoogleIfPresent();
        state = state.copyWith(step: CustomerRegisterStep.done, busy: false);
      },
      err: (f) async => state = state.copyWith(
        step: CustomerRegisterStep.details,
        busy: false,
        failure: f,
      ),
    );
  }

  Future<void> _bindGoogleIfPresent() async {
    final token = await ref.read(firebaseAuthServiceProvider).getIdToken();
    if (token == null || token.isEmpty) return;
    await _repo.bindGoogle(token);
    await ref.read(sessionProvider.notifier).refreshUser();
  }
}

final customerRegisterControllerProvider = AutoDisposeNotifierProvider<
    CustomerRegisterController, CustomerRegisterFormState>(
  CustomerRegisterController.new,
);
