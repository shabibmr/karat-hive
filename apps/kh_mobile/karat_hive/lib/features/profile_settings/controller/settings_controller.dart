import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/session/session_controller.dart';
import '../repository/profile_settings_repository.dart';

/// Server-cached `GET /v1/me/settings` for VEN-S18 / CUS-S21.
///
/// `null` until a session exists: Guests (`adr/0011`) have no token, so the
/// request would only 401. Re-fetches when the signed-in account changes, not
/// on every `refreshUser()` (which swaps in a new `SignedIn` instance).
final userSettingsProvider =
    FutureProvider.autoDispose<UserSettings?>((ref) async {
  final userId = ref.watch(_signedInUserIdProvider);
  if (userId == null) return null;
  final r = await ref.watch(profileSettingsRepositoryProvider).settings();
  return r.when(ok: (v) => v, err: (f) => throw f);
});

/// Id of the signed-in account, `null` for every other session state.
final _signedInUserIdProvider = Provider<String?>((ref) {
  final s = ref.watch(sessionProvider);
  return s is SignedIn ? s.user.userId : null;
});

/// App-level locale notifier driven by user settings and manual changes (VEN-S18).
class AppLocaleNotifier extends Notifier<Locale> {
  Locale? _manualLocale;
  String? _userId;

  @override
  Locale build() {
    // A language chosen under one account must not leak to the next Guest or
    // account after sign-out / account switch.
    final userId = ref.watch(_signedInUserIdProvider);
    if (userId != _userId) {
      if (_userId != null) _manualLocale = null;
      _userId = userId;
    }
    final settingsAsync = ref.watch(userSettingsProvider);
    final serverLang = settingsAsync.value?.preferredLanguage;
    if (serverLang != null) {
      _manualLocale =
          serverLang == 'ar' ? const Locale('ar') : const Locale('en');
      return _manualLocale!;
    }
    return _manualLocale ?? const Locale('en');
  }

  void setLocale(Locale locale) {
    _manualLocale = locale;
    state = locale;
  }

  void setLanguageCode(String code) {
    setLocale(Locale(code));
  }
}

final appLocaleProvider =
    NotifierProvider<AppLocaleNotifier, Locale>(AppLocaleNotifier.new);

/// Settings / sessions / password mutations (VEN-S18). UI lands in CP6-B03.
class SettingsController extends Notifier<AsyncValue<UserSettings?>> {
  @override
  AsyncValue<UserSettings?> build() => const AsyncData(null);

  Future<Result<UserSettings>> patch({
    String? preferredLanguage,
    String? defaultRegionId,
    QuietHours? quietHours,
    String? defaultFilterPresetId,
    Map<String, NotificationChannelPref>? notifications,
  }) async {
    state = const AsyncLoading();
    final res = await ref.read(profileSettingsRepositoryProvider).patchSettings(
          preferredLanguage: preferredLanguage,
          defaultRegionId: defaultRegionId,
          quietHours: quietHours,
          defaultFilterPresetId: defaultFilterPresetId,
          notifications: notifications,
        );
    res.when(
      ok: (settings) {
        state = AsyncData(settings);
        ref.invalidate(userSettingsProvider);
      },
      err: (failure) => state = AsyncError(failure, StackTrace.current),
    );
    return res;
  }

  Future<Result<List<AuthSessionDto>>> listSessions() =>
      ref.read(profileSettingsRepositoryProvider).listSessions();

  Future<Result<void>> revokeSession(String id) =>
      ref.read(profileSettingsRepositoryProvider).revokeSession(id);

  Future<Result<void>> setPassword({
    String? currentPassword,
    required String newPassword,
  }) =>
      ref.read(profileSettingsRepositoryProvider).setPassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );

  // --- Customer account lifecycle (CUS-S21) ---

  Future<Result<MeUser>> deactivateAccount() =>
      ref.read(profileSettingsRepositoryProvider).deactivateAccount();

  Future<Result<AccountDeletionRequest>> createDeletionRequest() =>
      ref.read(profileSettingsRepositoryProvider).createDeletionRequest();

  Future<Result<OtpVerifyResult>> verifyDeletionOtp({
    required String challengeId,
    required String code,
  }) =>
      ref.read(profileSettingsRepositoryProvider).verifyDeletionOtp(
            challengeId: challengeId,
            code: code,
          );

  Future<Result<AccountDeletionRequest>> confirmDeletionRequest(
    String id, {
    required String challengeId,
  }) =>
      ref.read(profileSettingsRepositoryProvider).confirmDeletionRequest(
            id,
            challengeId: challengeId,
          );
}

final settingsControllerProvider = NotifierProvider.autoDispose<
    SettingsController, AsyncValue<UserSettings?>>(
  SettingsController.new,
);

final activeSessionsProvider =
    FutureProvider.autoDispose<List<AuthSessionDto>>((ref) async {
  final repo = ref.watch(profileSettingsRepositoryProvider);
  final res = await repo.listSessions();
  return res.when(ok: (sessions) => sessions, err: (f) => throw f);
});

