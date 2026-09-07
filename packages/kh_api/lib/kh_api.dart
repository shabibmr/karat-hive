library kh_api;

import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import 'src/clients/auth_client.dart';
import 'src/clients/connections_client.dart';
import 'src/clients/dashboard_client.dart';
import 'src/clients/filter_presets_client.dart';
import 'src/clients/matches_client.dart';
import 'src/clients/me_client.dart';
import 'src/clients/media_client.dart';
import 'src/clients/offers_client.dart';
import 'src/clients/platform_config_client.dart';
import 'src/clients/requests_client.dart';
import 'src/clients/subscriptions_client.dart';
import 'src/clients/taxonomy_client.dart';
import 'src/clients/vendor_client.dart';
import 'src/dtos.dart';

export 'src/clients/auth_client.dart';
export 'src/clients/connections_client.dart';
export 'src/clients/dashboard_client.dart';
export 'src/clients/filter_presets_client.dart';
export 'src/clients/matches_client.dart';
export 'src/clients/me_client.dart';
export 'src/clients/media_client.dart';
export 'src/clients/offers_client.dart';
export 'src/clients/platform_config_client.dart';
export 'src/clients/requests_client.dart';
export 'src/clients/subscriptions_client.dart';
export 'src/clients/taxonomy_client.dart';
export 'src/clients/vendor_client.dart';
export 'src/dtos.dart';

/// Typed facade over [KhApiClient]. DTOs are mapped to `kh_domain` types here so
/// generated shapes never reach controllers/presentation (Architecture-Frontend §9.1).
///
/// Specialized clients are exposed as properties (CP2-F09 / CP2-B01) while legacy
/// direct methods are retained for backward compatibility.
class KhApi {
  KhApi(this._client)
      : auth = AuthClient(_client),
        meClient = MeClient(_client),
        taxonomyClient = TaxonomyClient(_client),
        vendor = VendorClient(_client),
        mediaClient = MediaClient(_client),
        dashboardClient = DashboardClient(_client),
        matches = MatchesClient(_client),
        requests = RequestsClient(_client),
        offers = OffersClient(_client),
        connections = ConnectionsClient(_client),
        filterPresets = FilterPresetsClient(_client),
        subscriptions = SubscriptionsClient(_client),
        platformConfig = PlatformConfigClient(_client);

  final KhApiClient _client;

  KhApiClient get client => _client;

  // --- Sub-clients (CP2-F09 / CP2-B01 / CP3-B01) ---
  final AuthClient auth;
  final MeClient meClient;
  final TaxonomyClient taxonomyClient;
  final VendorClient vendor;
  final MediaClient mediaClient;
  final DashboardClient dashboardClient;
  final MatchesClient matches;
  final RequestsClient requests;
  final OffersClient offers;
  final ConnectionsClient connections;
  final FilterPresetsClient filterPresets;
  final SubscriptionsClient subscriptions;
  final PlatformConfigClient platformConfig;

  // --- auth backwards-compat ---
  Future<Result<OtpChallenge>> otpRequest({
    required String mobileNumber,
    required String purpose,
  }) =>
      auth.otpRequest(mobileNumber: mobileNumber, purpose: purpose);

  Future<Result<OtpVerifyResult>> otpVerify({
    required String challengeId,
    required String code,
  }) =>
      auth.otpVerify(challengeId: challengeId, code: code);

  Future<Result<SessionBundle>> registerVendor(Map<String, dynamic> body) =>
      auth.registerVendor(body);

  /// `POST /v1/auth/register/customer` — SessionBundle 201 (`FR-CUS-001`).
  Future<Result<SessionBundle>> registerCustomer({
    String? challengeId,
    String? firebaseToken,
    required String displayName,
    String? email,
    required String preferredLanguage,
    String? defaultRegionId,
    required String termsVersion,
    required String privacyVersion,
  }) async {
    final r = await _client.send('POST', '/v1/auth/register/customer', body: {
      if (challengeId != null) 'challengeId': challengeId,
      if (firebaseToken != null) 'firebaseToken': firebaseToken,
      'displayName': displayName,
      if (email != null) 'email': email,
      'preferredLanguage': preferredLanguage,
      if (defaultRegionId != null) 'defaultRegionId': defaultRegionId,
      'termsVersion': termsVersion,
      'privacyVersion': privacyVersion,
    });
    return r.when(
      ok: (d) => Ok(SessionBundle.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<SessionBundle>> loginPassword({
    required String email,
    required String password,
  }) =>
      auth.loginPassword(email: email, password: password);

  /// Exchanges a Google / Firebase ID token for a Karat Hive [SessionBundle]
  /// (`AD-API-13`, G2-A14). Does not create a User; unbound → 401.
  Future<Result<SessionBundle>> googleSession({required String idToken}) async {
    final r = await _client.send('POST', '/v1/auth/google/session', body: {
      'idToken': idToken,
    });
    return r.when(
      ok: (d) => Ok(SessionBundle.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  static Future<SessionTokens?> refresh(
    KhApiClient client,
    String refreshToken,
  ) =>
      AuthClient.refresh(client, refreshToken);

  Future<void> logout(String? refreshToken) => auth.logout(refreshToken);

  // --- me backwards-compat ---
  Future<Result<MeUser>> me() => meClient.me();

  /// Customer fields: `displayName`, `email`, `preferredLanguage`,
  /// `defaultRegionId`, `photoMediaKey` (inventory §9). Vendor may send
  /// `preferredLanguage` on this same route.
  Future<Result<MeUser>> patchMe({
    String? displayName,
    String? email,
    String? preferredLanguage,
    String? defaultRegionId,
    String? photoMediaKey,
  }) async {
    final r = await _client.send('PATCH', '/v1/me', body: {
      if (displayName != null) 'displayName': displayName,
      if (email != null) 'email': email,
      if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
      if (defaultRegionId != null) 'defaultRegionId': defaultRegionId,
      if (photoMediaKey != null) 'photoMediaKey': photoMediaKey,
    });
    return r.when(
      ok: (d) => Ok(MeUser.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<GoldRateSnapshot>> goldRates() async {
    final r = await _client.send('GET', '/v1/gold-rates');
    return r.when(
      ok: (d) => Ok(GoldRateSnapshot.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<UserSettings>> settings() async {
    final r = await _client.send('GET', '/v1/me/settings');
    return r.when(
      ok: (d) => Ok(UserSettings.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<UserSettings>> patchSettings({
    String? preferredLanguage,
    String? defaultRegionId,
    QuietHours? quietHours,
    String? defaultFilterPresetId,
    Map<String, NotificationChannelPref>? notifications,
  }) async {
    final r = await _client.send('PATCH', '/v1/me/settings', body: {
      if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
      if (defaultRegionId != null) 'defaultRegionId': defaultRegionId,
      if (quietHours != null) 'quietHours': quietHours.toJson(),
      if (defaultFilterPresetId != null)
        'defaultFilterPresetId': defaultFilterPresetId,
      if (notifications != null)
        'notifications':
            notifications.map((k, v) => MapEntry(k, v.toJson())),
    });
    return r.when(
      ok: (d) => Ok(UserSettings.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  // --- taxonomy backwards-compat ---
  Future<Result<List<TaxonomyNode>>> categories() =>
      taxonomyClient.categories();
  Future<Result<List<TaxonomyNode>>> regions() => taxonomyClient.regions();

  // --- vendor onboarding backwards-compat ---
  Future<Result<VendorMe>> vendorMe() => vendor.vendorMe();

  Future<Result<List<VendorDocument>>> documents() => vendor.documents();

  Future<Result<List<VendorDocument>>> attachDocument({
    required String documentType,
    required String mediaKey,
    String? expiryDate,
  }) =>
      vendor.attachDocument(
        documentType: documentType,
        mediaKey: mediaKey,
        expiryDate: expiryDate,
      );

  Future<Result<VendorMe>> setCategories(List<String> ids) =>
      vendor.setCategories(ids);

  Future<Result<VendorMe>> setRegions(List<String> ids) =>
      vendor.setRegions(ids);

  Future<Result<VendorMe>> setAvailability({
    bool? awayMode,
    Object? businessHours,
  }) =>
      vendor.setAvailability(
        awayMode: awayMode,
        businessHours: businessHours,
      );

  Future<Result<VendorMe>> resubmit() => vendor.resubmit();

  // --- dashboard backwards-compat ---
  Future<Result<VendorDashboard>> dashboard() =>
      dashboardClient.getDashboard();

  // --- media backwards-compat ---
  Future<Result<UploadIntent>> uploadIntent({
    required String purpose,
    required String contentType,
    required int byteSize,
  }) =>
      mediaClient.uploadIntent(
        purpose: purpose,
        contentType: contentType,
        byteSize: byteSize,
      );

  Future<Result<String>> completeUpload(String key) =>
      mediaClient.completeUpload(key);
}
