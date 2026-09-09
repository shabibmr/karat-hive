library kh_api;

import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import 'src/clients/abuse_client.dart';
import 'src/clients/auth_client.dart';
import 'src/clients/connections_client.dart';
import 'src/clients/dashboard_client.dart';
import 'src/clients/filter_presets_client.dart';
import 'src/clients/matches_client.dart';
import 'src/clients/me_client.dart';
import 'src/clients/media_client.dart';
import 'src/clients/notifications_client.dart';
import 'src/clients/offers_client.dart';
import 'src/clients/performance_client.dart';
import 'src/clients/platform_config_client.dart';
import 'src/clients/requests_client.dart';
import 'src/clients/reviews_client.dart';
import 'src/clients/subscriptions_client.dart';
import 'src/clients/taxonomy_client.dart';
import 'src/clients/vendor_client.dart';
import 'src/dtos.dart';

export 'src/clients/abuse_client.dart';
export 'src/clients/auth_client.dart';
export 'src/clients/connections_client.dart';
export 'src/clients/dashboard_client.dart';
export 'src/clients/filter_presets_client.dart';
export 'src/clients/matches_client.dart';
export 'src/clients/me_client.dart';
export 'src/clients/media_client.dart';
export 'src/clients/notifications_client.dart';
export 'src/clients/offers_client.dart';
export 'src/clients/performance_client.dart';
export 'src/clients/platform_config_client.dart';
export 'src/clients/requests_client.dart';
export 'src/clients/reviews_client.dart';
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
        performance = PerformanceClient(_client),
        matches = MatchesClient(_client),
        requests = RequestsClient(_client),
        offers = OffersClient(_client),
        filterPresets = FilterPresetsClient(_client),
        subscriptions = SubscriptionsClient(_client),
        platformConfig = PlatformConfigClient(_client),
        connections = ConnectionsClient(_client),
        reviews = ReviewsClient(_client),
        notifications = NotificationsClient(_client),
        abuse = AbuseClient(_client);

  final KhApiClient _client;

  KhApiClient get client => _client;

  // --- Sub-clients (CP2-F09 / CP2-B01 / CP3-B01) ---
  final AuthClient auth;
  final MeClient meClient;
  final TaxonomyClient taxonomyClient;
  final VendorClient vendor;
  final MediaClient mediaClient;
  final DashboardClient dashboardClient;
  final PerformanceClient performance;
  final MatchesClient matches;
  final RequestsClient requests;
  final OffersClient offers;
  final ConnectionsClient connections;
  final FilterPresetsClient filterPresets;
  final SubscriptionsClient subscriptions;
  final PlatformConfigClient platformConfig;
  final ReviewsClient reviews;
  final NotificationsClient notifications;
  final AbuseClient abuse;

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

  Future<Result<VendorMe>> patchVendorProfile({
    String? tradingName,
    String? description,
    String? contactPersonName,
    String? businessEmail,
    String? legalBusinessName,
    String? tradeLicenceNumber,
    String? businessAddress,
  }) =>
      vendor.patchProfile(
        tradingName: tradingName,
        description: description,
        contactPersonName: contactPersonName,
        businessEmail: businessEmail,
        legalBusinessName: legalBusinessName,
        tradeLicenceNumber: tradeLicenceNumber,
        businessAddress: businessAddress,
      );

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

  Future<Result<void>> deleteMedia(String key) async {
    final r = await _client.send('DELETE', '/v1/media/$key');
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }

  Future<Result<MeUser>> changeMobile(String challengeId) =>
      meClient.changeMobile(challengeId);

  Future<Result<MeUser>> deactivate() => meClient.deactivate();

  Future<Result<AccountDeletionRequest>> createDeletionRequest() =>
      meClient.createDeletionRequest();

  Future<Result<AccountDeletionRequest>> confirmDeletionRequest(
    String id, {
    required String challengeId,
  }) =>
      meClient.confirmDeletionRequest(id, challengeId: challengeId);

  // ===========================================================================
  // Customer surface (Screen-API-Map §3). Hand-written to the same Result /
  // envelope conventions as the auth/vendor methods above; masked fields are
  // absent from the DTOs by shape, not nulled (BR-006, NFR-013, AD-FE-07).
  // ===========================================================================

  T _obj<T>(dynamic d, T Function(Map<String, dynamic>) f) =>
      f(d as Map<String, dynamic>);

  // --- requests (CUS-S02..S10, S17) ---
  Future<Result<CustomerRequestDto>> createRequest(RequestDraftInput input) async {
    final r =
        await _client.send('POST', '/v1/requests', body: input.toJson());
    return r.when(
      ok: (d) => Ok(_obj(d, CustomerRequestDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<Paged<CustomerRequestDto>>> listMyRequests({
    List<String>? states,
    String? requestType,
    String? direction,
    String? q,
    int? limit,
    String? cursor,
  }) async {
    final r = await _client.sendList('GET', '/v1/me/requests', query: {
      if (states != null && states.isNotEmpty) 'state': states.join(','),
      if (requestType != null) 'requestType': requestType,
      if (direction != null) 'direction': direction,
      if (q != null) 'q': q,
      if (limit != null) 'limit': limit,
      if (cursor != null) 'cursor': cursor,
    });
    return r.when(
      ok: (p) => Ok(Paged.from(p, CustomerRequestDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<CustomerRequestDto>> getRequest(String id) async {
    final r = await _client.send('GET', '/v1/requests/$id');
    return r.when(
      ok: (d) => Ok(_obj(d, CustomerRequestDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<CustomerRequestDto>> updateRequest(
    String id,
    RequestDraftInput input,
  ) async {
    final r = await _client.send('PATCH', '/v1/requests/$id',
        body: input.toJson());
    return r.when(
      ok: (d) => Ok(_obj(d, CustomerRequestDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<CustomerRequestDto>> publishRequest(String id) async {
    final r = await _client.send('POST', '/v1/requests/$id/publish');
    return r.when(
      ok: (d) => Ok(_obj(d, CustomerRequestDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<CustomerRequestDto>> cancelRequest(String id, {String? reason}) async {
    final r = await _client.send('POST', '/v1/requests/$id/cancel',
        body: {if (reason != null) 'reason': reason});
    return r.when(
      ok: (d) => Ok(_obj(d, CustomerRequestDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<CustomerRequestDto>> duplicateRequest(String id) async {
    final r = await _client.send('POST', '/v1/requests/$id/duplicate');
    return r.when(
      ok: (d) => Ok(_obj(d, CustomerRequestDto.fromJson)),
      err: Err.new,
    );
  }

  // --- offers (CUS-S11..S14) ---
  Future<Result<Paged<CustomerOfferDto>>> offersForRequest(
    String requestId, {
    String? sort,
    double? minRating,
    double? priceMin,
    double? priceMax,
    int? limit,
    String? cursor,
  }) async {
    final r = await _client
        .sendList('GET', '/v1/requests/$requestId/offers', query: {
      if (sort != null) 'sort': sort,
      if (minRating != null) 'minRating': minRating,
      if (priceMin != null) 'priceMin': priceMin,
      if (priceMax != null) 'priceMax': priceMax,
      if (limit != null) 'limit': limit,
      if (cursor != null) 'cursor': cursor,
    });
    return r.when(
      ok: (p) => Ok(Paged.from(p, CustomerOfferDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<Paged<CustomerOfferDto>>> myOffers({
    String? tab,
    int? limit,
    String? cursor,
  }) async {
    final r = await _client.sendList('GET', '/v1/me/offers', query: {
      if (tab != null) 'tab': tab,
      if (limit != null) 'limit': limit,
      if (cursor != null) 'cursor': cursor,
    });
    return r.when(
      ok: (p) => Ok(Paged.from(p, CustomerOfferDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<CustomerOfferDto>> getOffer(String id) async {
    final r = await _client.send('GET', '/v1/offers/$id');
    return r.when(
      ok: (d) => Ok(_obj(d, CustomerOfferDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<VendorRatingSummaryDto>> offerVendorRating(String id) async {
    final r = await _client.send('GET', '/v1/offers/$id/vendor-rating');
    return r.when(
      ok: (d) => Ok(_obj(d, VendorRatingSummaryDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<void>> markOfferViewed(String id) async {
    final r = await _client.send('POST', '/v1/offers/$id/viewed');
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }

  Future<Result<CustomerConnectionDto>> acceptOffer(String id) async {
    final r = await _client.send('POST', '/v1/offers/$id/accept',
        body: {'confirmation': 'REVEAL_AND_CONNECT'});
    return r.when(
      ok: (d) => Ok(_obj(d, CustomerConnectionDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<void>> declineOffer(String id, {String? reason}) async {
    final r = await _client.send('POST', '/v1/offers/$id/decline',
        body: {if (reason != null) 'reason': reason});
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }

  // --- connections (CUS-S15, S16) ---
  Future<Result<Paged<CustomerConnectionDto>>> listMyConnections({
    String? state,
    int? limit,
    String? cursor,
  }) async {
    final r = await _client.sendList('GET', '/v1/me/connections', query: {
      if (state != null) 'state': state,
      if (limit != null) 'limit': limit,
      if (cursor != null) 'cursor': cursor,
    });
    return r.when(
      ok: (p) => Ok(Paged.from(p, CustomerConnectionDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<CustomerConnectionDto>> getConnection(String id) async {
    final r = await _client.send('GET', '/v1/connections/$id');
    return r.when(
      ok: (d) => Ok(_obj(d, CustomerConnectionDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<CustomerConnectionDto>> closeConnection(String id, {String? reason}) async {
    final r = await _client.send('POST', '/v1/connections/$id/close',
        body: {if (reason != null) 'reason': reason});
    return r.when(
      ok: (d) => Ok(_obj(d, CustomerConnectionDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<void>> recordContactEvent(
    String connectionId, {
    required String channel, // WHATSAPP | PHONE
  }) async {
    final r = await _client.send(
        'POST', '/v1/connections/$connectionId/contact-events',
        body: {'channel': channel});
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }

  // --- reviews (CUS-S18) ---
  Future<Result<ReviewDto>> createReview(
    String connectionId, {
    required int rating,
    String? comment,
  }) async {
    final r = await _client.send(
        'POST', '/v1/connections/$connectionId/reviews',
        body: {'rating': rating, if (comment != null) 'comment': comment});
    return r.when(
      ok: (d) => Ok(_obj(d, ReviewDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<Paged<ReviewDto>>> listMyReviews({
    String? role, // AUTHOR | SUBJECT
    int? limit,
    String? cursor,
  }) async {
    final r = await _client.sendList('GET', '/v1/me/reviews', query: {
      if (role != null) 'role': role,
      if (limit != null) 'limit': limit,
      if (cursor != null) 'cursor': cursor,
    });
    return r.when(
      ok: (p) => Ok(Paged.from(p, ReviewDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<ReviewDto>> updateReview(
    String id, {
    int? rating,
    String? comment,
  }) async {
    final r = await _client.send('PATCH', '/v1/reviews/$id', body: {
      if (rating != null) 'rating': rating,
      if (comment != null) 'comment': comment,
    });
    return r.when(
      ok: (d) => Ok(_obj(d, ReviewDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<void>> withdrawReview(String id) async {
    final r = await _client.send('POST', '/v1/reviews/$id/withdraw');
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }

  Future<Result<ReviewDto>> respondToReview(String id, String response) async {
    final r = await _client.send('POST', '/v1/reviews/$id/response',
        body: {'response': response});
    return r.when(
      ok: (d) => Ok(_obj(d, ReviewDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<void>> flagReview(String id) async {
    final r = await _client.send('POST', '/v1/reviews/$id/flag');
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }

  // --- notifications (CUS-S19) ---
  Future<Result<Paged<NotificationDto>>> listNotifications({
    bool? unread,
    int? limit,
    String? cursor,
  }) async {
    final r = await _client.sendList('GET', '/v1/notifications', query: {
      if (unread != null) 'unread': unread,
      if (limit != null) 'limit': limit,
      if (cursor != null) 'cursor': cursor,
    });
    return r.when(
      ok: (p) => Ok(Paged.from(p, NotificationDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<int>> unreadNotificationCount() async {
    final r = await _client.send('GET', '/v1/notifications/unread-count');
    return r.when(
      ok: (d) => Ok(d is Map ? (d['count'] as int? ?? 0) : (d as int? ?? 0)),
      err: Err.new,
    );
  }

  Future<Result<void>> markNotificationRead(String id) async {
    final r = await _client.send('POST', '/v1/notifications/$id/read');
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }

  Future<Result<void>> markAllNotificationsRead() async {
    final r = await _client.send('POST', '/v1/notifications/read-all');
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }

  // --- settings (CUS-S21) ---
  Future<Result<UserSettingsDto>> getSettings() async {
    final r = await _client.send('GET', '/v1/me/settings');
    return r.when(
      ok: (d) => Ok(_obj(d, UserSettingsDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<UserSettingsDto>> patchSettingsDto(UserSettingsPatch patch) async {
    final r = await _client.send('PATCH', '/v1/me/settings', body: patch.toJson());
    return r.when(
      ok: (d) => Ok(_obj(d, UserSettingsDto.fromJson)),
      err: Err.new,
    );
  }

  // --- abuse (CUS-S22) ---
  Future<Result<void>> reportAbuse({
    required String entityType, // REQUEST|OFFER|CONNECTION|REVIEW|VENDOR|CUSTOMER
    required String entityId,
    required String category,
    required String description,
  }) async {
    final r = await _client.send('POST', '/v1/abuse-reports', body: {
      'entityType': entityType,
      'entityId': entityId,
      'category': category,
      'description': description,
    });
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }
}
