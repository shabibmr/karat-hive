import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_media/kh_media.dart';

import '../../../app/di.dart';
import '../../../app/session/session_controller.dart';
import '../model/register_form_state.dart';
import '../repository/auth_repository.dart';

/// Flow-scoped (not screen-scoped) so back-navigation never loses the form
/// (Architecture-Frontend §6.2).
class VendorRegisterController extends Notifier<RegisterFormState> {
  @override
  RegisterFormState build() => const RegisterFormState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// Seeds Google identity from unbound login (`adr/0010`). Idempotent —
  /// re-seeding the same token does not wipe entered fields.
  ///
  /// Google email is locked for the session — editing it would break the
  /// meaning of the OAuth bind.
  void begin({
    required String firebaseIdToken,
    String? suggestedName,
    String? suggestedEmail,
  }) {
    if (state.firebaseIdToken == firebaseIdToken) return;
    final googleEmail = suggestedEmail?.trim() ?? '';
    if (googleEmail.isEmpty) {
      state = state.copyWith(
        firebaseIdToken: firebaseIdToken,
        googleEmailLocked: false,
        failure: const ValidationFailure(
          message:
              'Your Google account has no email. Use a Google account with an email to register.',
        ),
      );
      return;
    }
    state = state.copyWith(
      firebaseIdToken: firebaseIdToken,
      contactPersonName: state.contactPersonName.isEmpty &&
              suggestedName != null &&
              suggestedName.isNotEmpty
          ? suggestedName
          : state.contactPersonName,
      businessEmail: googleEmail,
      googleEmailLocked: true,
      clearFailure: true,
    );
  }

  void patch(RegisterFormState Function(RegisterFormState) update) =>
      state = update(state);

  void nextWizardStep() {
    if (state.wizardStep < 4) {
      state = state.copyWith(wizardStep: state.wizardStep + 1, clearFailure: true);
    }
  }

  void prevWizardStep() {
    if (state.wizardStep > 1) {
      state = state.copyWith(wizardStep: state.wizardStep - 1, clearFailure: true);
    }
  }

  /// Direct registration submission (bypasses OTP verification for current development phase).
  Future<void> submitDirect() async {
    if (!state.detailsComplete) {
      state = state.copyWith(
        failure: const ValidationFailure(
          message: 'Complete all required fields before creating your account.',
        ),
      );
      return;
    }
    state = state.copyWith(busy: true, clearFailure: true);
    final next = await _submit();
    state = next;
  }

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
      ok: (bundle) async {
        await ref.read(sessionProvider.notifier).onAuthenticated(bundle);
        await _uploadLogoAfterRegister();
        return state.copyWith(step: RegisterStep.done, busy: false, clearLogo: true);
      },
      err: (f) async =>
          state.copyWith(step: RegisterStep.details, busy: false, failure: f),
    );
  }

  /// Session is live after register — upload VENDOR_LOGO and attach via PATCH.
  Future<void> _uploadLogoAfterRegister() async {
    final bytes = state.logoBytes;
    if (bytes == null || bytes.isEmpty) return;
    final api = ref.read(khApiProvider);
    final media = MediaPickController(
      uploader: MediaUploader(api),
      purpose: MediaUploadPurpose.vendorLogo,
    );
    final uploaded = await media.convertBytesAndUpload(
      bytes,
      correlationId: 'vendor-logo',
    );
    await uploaded.when(
      ok: (key) async {
        await api.patchVendorProfile(logoMediaKey: key);
      },
      err: (_) async {
        // Registration already succeeded; logo can be set later from profile.
      },
    );
  }
}

final vendorRegisterControllerProvider =
    NotifierProvider<VendorRegisterController, RegisterFormState>(
  VendorRegisterController.new,
);
