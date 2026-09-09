import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/profile_settings_repository.dart';

/// Server-cached `GET /v1/me/settings` for VEN-S18 / CUS-S21.
final userSettingsProvider =
    FutureProvider.autoDispose<UserSettings>((ref) async {
  final r = await ref.watch(profileSettingsRepositoryProvider).settings();
  return r.when(ok: (v) => v, err: (f) => throw f);
});

/// App-level locale notifier driven by user settings and manual changes (VEN-S18).
class AppLocaleNotifier extends Notifier<Locale> {
  Locale? _manualLocale;

  @override
  Locale build() {
    final settingsAsync = ref.watch(userSettingsProvider);
    final serverLang = settingsAsync.valueOrNull?.preferredLanguage;
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
class SettingsController extends AutoDisposeNotifier<AsyncValue<UserSettings?>> {
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
}

final settingsControllerProvider = AutoDisposeNotifierProvider<
    SettingsController, AsyncValue<UserSettings?>>(
  SettingsController.new,
);

final activeSessionsProvider =
    FutureProvider.autoDispose<List<AuthSessionDto>>((ref) async {
  final repo = ref.watch(profileSettingsRepositoryProvider);
  final res = await repo.listSessions();
  return res.when(ok: (sessions) => sessions, err: (f) => throw f);
});

