library kh_api;

import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import 'src/clients/auth_client.dart';
import 'src/clients/dashboard_client.dart';
import 'src/clients/filter_presets_client.dart';
import 'src/clients/matches_client.dart';
import 'src/clients/me_client.dart';
import 'src/clients/media_client.dart';
import 'src/clients/platform_config_client.dart';
import 'src/clients/requests_client.dart';
import 'src/clients/subscriptions_client.dart';
import 'src/clients/taxonomy_client.dart';
import 'src/clients/vendor_client.dart';
import 'src/dtos.dart';

export 'src/clients/auth_client.dart';
export 'src/clients/dashboard_client.dart';
export 'src/clients/filter_presets_client.dart';
export 'src/clients/matches_client.dart';
export 'src/clients/me_client.dart';
export 'src/clients/media_client.dart';
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
        filterPresets = FilterPresetsClient(_client),
        subscriptions = SubscriptionsClient(_client),
        platformConfig = PlatformConfigClient(_client);

  final KhApiClient _client;

  KhApiClient get client => _client;

  // --- Sub-clients (CP2-F09 / CP2-B01) ---
  final AuthClient auth;
  final MeClient meClient;
  final TaxonomyClient taxonomyClient;
  final VendorClient vendor;
  final MediaClient mediaClient;
  final DashboardClient dashboardClient;
  final MatchesClient matches;
  final RequestsClient requests;
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

  Future<Result<SessionBundle>> loginPassword({
    required String email,
    required String password,
  }) =>
      auth.loginPassword(email: email, password: password);

  static Future<SessionTokens?> refresh(
    KhApiClient client,
    String refreshToken,
  ) =>
      AuthClient.refresh(client, refreshToken);

  Future<void> logout(String? refreshToken) => auth.logout(refreshToken);

  // --- me backwards-compat ---
  Future<Result<MeUser>> me() => meClient.me();

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
