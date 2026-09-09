import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/session/session_controller.dart';
import '../../onboarding/controller/vendor_me_controller.dart';
import '../repository/profile_settings_repository.dart';

/// Server-cached `GET /v1/me/vendor` for VEN-S15 (CP6-B02).
final vendorProfileProvider =
    FutureProvider.autoDispose<VendorMe>((ref) async {
  final r = await ref.watch(profileSettingsRepositoryProvider).vendorMe();
  return r.when(ok: (v) => v, err: (f) => throw f);
});

class BusinessProfileSaveState {
  const BusinessProfileSaveState({
    this.busy = false,
    this.failure,
  });

  final bool busy;
  final Failure? failure;

  BusinessProfileSaveState copyWith({
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      BusinessProfileSaveState(
        busy: busy ?? this.busy,
        failure: clearFailure ? null : (failure ?? this.failure),
      );
}

/// VEN-S15 safe edits (CP6-B02.2). Never sends BR-004 legal-identity keys.
class BusinessProfileSaveController
    extends AutoDisposeNotifier<BusinessProfileSaveState> {
  @override
  BusinessProfileSaveState build() => const BusinessProfileSaveState();

  ProfileSettingsRepository get _repo =>
      ref.read(profileSettingsRepositoryProvider);

  Future<bool> saveSafeEdits({
    required String tradingName,
    required String contactPersonName,
    required String businessEmail,
    String? description,
    Map<String, BusinessDayHours>? businessHours,
  }) async {
    final name = tradingName.trim();
    final contact = contactPersonName.trim();
    final email = businessEmail.trim();
    final desc = description?.trim();

    if (name.isEmpty || contact.isEmpty || email.isEmpty) {
      state = state.copyWith(
        failure: const ValidationFailure(
          code: 'VALIDATION_FAILED',
          message: 'Trading name, contact person and business email are required.',
        ),
      );
      return false;
    }
    if (!_looksLikeEmail(email)) {
      state = state.copyWith(
        failure: const ValidationFailure(
          code: 'VALIDATION_FAILED',
          message: 'Enter a valid business email.',
          fieldErrors: {'businessEmail': 'Invalid email'},
        ),
      );
      return false;
    }

    state = state.copyWith(busy: true, clearFailure: true);

    final profile = await _repo.patchVendorProfile(
      tradingName: name,
      description: desc ?? '',
      contactPersonName: contact,
      businessEmail: email,
    );
    final profileFail = profile.failureOrNull;
    if (profileFail != null) {
      state = state.copyWith(busy: false, failure: profileFail);
      return false;
    }

    if (businessHours != null) {
      final hoursBody = {
        for (final e in businessHours.entries) e.key: e.value.toJson(),
      };
      final avail = await _repo.setAvailability(businessHours: hoursBody);
      final availFail = avail.failureOrNull;
      if (availFail != null) {
        state = state.copyWith(busy: false, failure: availFail);
        return false;
      }
    }

    ref.invalidate(vendorProfileProvider);
    ref.invalidate(vendorMeProvider);
    await ref.read(sessionProvider.notifier).refreshUser();
    state = state.copyWith(busy: false);
    return true;
  }

  static bool _looksLikeEmail(String value) {
    final at = value.indexOf('@');
    if (at <= 0 || at == value.length - 1) return false;
    return value.contains('.', at + 1);
  }
}

final businessProfileSaveProvider = AutoDisposeNotifierProvider<
    BusinessProfileSaveController, BusinessProfileSaveState>(
  BusinessProfileSaveController.new,
);
