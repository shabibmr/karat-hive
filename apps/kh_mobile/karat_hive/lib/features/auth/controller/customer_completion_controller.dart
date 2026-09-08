import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/session/session_controller.dart';
import '../model/customer_completion_form.dart';
import '../repository/customer_auth_repository.dart';

/// CFE-10 — terms acceptance + real mobile via OTP, then
/// `POST /v1/auth/register/customer` to complete a new Google user (`adr/0010`).
///
/// Every server error is surfaced through [CustomerCompletionForm.failure] as
/// the server's localised `error.message` string (`NFR-024`) — the controller
/// never composes prose and never shows a raw code.
class CustomerCompletionController
    extends AutoDisposeNotifier<CustomerCompletionForm> {
  @override
  CustomerCompletionForm build() => const CustomerCompletionForm();

  CustomerAuthRepository get _repo => ref.read(customerAuthRepositoryProvider);

  /// Seeds the flow with the Firebase token from the sign-in step. Idempotent —
  /// re-seeding an in-progress flow is ignored so a widget rebuild cannot wipe
  /// entered input.
  void begin({
    required String firebaseIdToken,
    String? suggestedName,
    String? suggestedEmail,
  }) {
    if (state.firebaseIdToken == firebaseIdToken) return;
    state = CustomerCompletionForm(
      firebaseIdToken: firebaseIdToken,
      displayName: suggestedName ?? '',
      email: suggestedEmail,
    );
  }

  void setName(String v) =>
      state = state.copyWith(displayName: v, clearFailure: true);

  void setMobile(String v) =>
      state = state.copyWith(mobileNumber: v, clearFailure: true);

  void setTermsAccepted(bool v) =>
      state = state.copyWith(termsAccepted: v, clearFailure: true);

  void backToDetails() =>
      state = state.copyWith(step: CompletionStep.details, clearFailure: true);

  Future<void> sendCode() async {
    if (!state.detailsComplete || state.busy) return;
    state = state.copyWith(busy: true, clearFailure: true);
    final r = await _repo.requestOtp(state.mobileNumber.trim());
    state = r.when(
      ok: (challenge) => state.copyWith(
        busy: false,
        step: CompletionStep.code,
        challengeId: challenge.challengeId,
      ),
      err: (f) => state.copyWith(busy: false, failure: f),
    );
  }

  Future<void> verifyAndRegister(String code) async {
    final challengeId = state.challengeId;
    if (challengeId == null || !state.termsAccepted || state.busy) return;

    state = state.copyWith(busy: true, clearFailure: true);

    final verify = await _repo.verifyOtp(challengeId, code.trim());
    final verified = verify.when(
      ok: (res) => res.challengeId ?? challengeId,
      err: (_) => null,
    );
    if (verified == null) {
      state = state.copyWith(
        busy: false,
        failure: verify.failureOrNull,
      );
      return;
    }

    state = state.copyWith(step: CompletionStep.submitting);

    final register = await _repo.registerCustomer(
      firebaseToken: state.firebaseIdToken,
      challengeId: verified,
      displayName: state.displayName.trim(),
      email: state.email,
    );

    await register.when(
      ok: (bundle) async {
        await ref.read(sessionProvider.notifier).onAuthenticated(bundle);
        state = state.copyWith(busy: false, step: CompletionStep.done);
      },
      err: (f) async {
        // A duplicate number is a details-level fix; other codes leave the user
        // on the code step to retry.
        final backTo = f.code == 'MOBILE_ALREADY_REGISTERED'
            ? CompletionStep.details
            : CompletionStep.code;
        state = state.copyWith(busy: false, step: backTo, failure: f);
      },
    );
  }
}

final customerCompletionControllerProvider = AutoDisposeNotifierProvider<
    CustomerCompletionController, CustomerCompletionForm>(
  CustomerCompletionController.new,
);
