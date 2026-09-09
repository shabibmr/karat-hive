import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';

final profileSettingsRepositoryProvider =
    Provider<ProfileSettingsRepository>((ref) {
  return ProfileSettingsRepository(ref.watch(khApiProvider));
});

/// Domain-shaped access for VEN-S15 / VEN-S16 / VEN-S18 (and shared CUS-S20 / CUS-S21).
class ProfileSettingsRepository {
  const ProfileSettingsRepository(this._api);
  final KhApi _api;

  Future<Result<VendorMe>> vendorMe() => _api.vendorMe();

  Future<Result<VendorMe>> patchVendorProfile({
    String? tradingName,
    String? description,
    String? contactPersonName,
    String? businessEmail,
  }) =>
      _api.patchVendorProfile(
        tradingName: tradingName,
        description: description,
        contactPersonName: contactPersonName,
        businessEmail: businessEmail,
      );

  Future<Result<UserSettings>> settings() => _api.settings();

  Future<Result<UserSettings>> patchSettings({
    String? preferredLanguage,
    String? defaultRegionId,
    QuietHours? quietHours,
    String? defaultFilterPresetId,
    Map<String, NotificationChannelPref>? notifications,
  }) =>
      _api.patchSettings(
        preferredLanguage: preferredLanguage,
        defaultRegionId: defaultRegionId,
        quietHours: quietHours,
        defaultFilterPresetId: defaultFilterPresetId,
        notifications: notifications,
      );

  Future<Result<VendorMe>> setCategories(List<String> ids) =>
      _api.setCategories(ids);

  Future<Result<VendorMe>> setRegions(List<String> ids) =>
      _api.setRegions(ids);

  Future<Result<VendorMe>> setAvailability({
    bool? awayMode,
    Object? businessHours,
  }) =>
      _api.setAvailability(awayMode: awayMode, businessHours: businessHours);

  Future<Result<List<AuthSessionDto>>> listSessions() =>
      _api.auth.listSessions();

  Future<Result<void>> revokeSession(String id) =>
      _api.auth.revokeSession(id);

  Future<Result<void>> setPassword({
    String? currentPassword,
    required String newPassword,
  }) =>
      _api.auth.setPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
}
