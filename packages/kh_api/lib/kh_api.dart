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
import 'src/request_draft_save.dart';

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
export 'src/request_draft_save.dart';

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
    String? mobileNumber,
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
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
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

  // --- requests (CUS-S02..S10, S17) — domain-mapped (CM-S07) ---
  Future<Result<RequestDraftSave>> createRequest(RequestDraftInput input) async {
    final r = await requests.create(input.toJson(), unwrapData: false);
    return r.when(
      ok: (raw) => Ok(RequestDraftSave.fromEnvelope(raw)),
      err: Err.new,
    );
  }

  Future<Result<PagedResult<RequestForCustomer>>> listMyRequests({
    List<String>? states,
    String? requestType,
    String? direction,
    String? q,
    int? limit,
    String? cursor,
    String? from,
    String? to,
  }) =>
      requests.listMine(
        state: states,
        requestType: requestType,
        direction: direction,
        q: q,
        limit: limit ?? 20,
        cursor: cursor,
        from: from,
        to: to,
      );

  /// Owner presenter for the signed-in Customer.
  Future<Result<RequestForCustomer>> getMyRequest(String id) =>
      requests.getMine(id);

  Future<Result<RequestDraftSave>> updateRequest(
    String id,
    RequestDraftInput input,
  ) async {
    final r = await requests.patch(id, input.toJson(), unwrapData: false);
    return r.when(
      ok: (raw) => Ok(RequestDraftSave.fromEnvelope(raw)),
      err: Err.new,
    );
  }

  Future<Result<RequestForCustomer>> publishRequest(
    String id, {
    required String idempotencyKey,
  }) =>
      requests.publish(id, idempotencyKey: idempotencyKey);

  Future<Result<RequestForCustomer>> cancelRequest(
    String id, {
    String? reason,
  }) =>
      requests.cancel(id, reason: reason);

  Future<Result<RequestForCustomer>> duplicateRequest(String id) =>
      requests.duplicate(id);

  // --- offers (CUS-S11..S14) — domain-mapped (CM-S08) ---
  /// Customer Offers on a Request. Vendor My-Offers uses [offers.listMyOffers].
  Future<Result<PagedResult<OfferForCustomer>>> offersForRequest(
    String requestId, {
    String? sort,
    String? minRating,
    String? priceMin,
    String? priceMax,
    int? limit,
    String? cursor,
    int? excludeExpiringWithinHours,
  }) =>
      offers.listForRequest(
        requestId,
        sort: sort,
        minRating: minRating,
        priceMin: priceMin,
        priceMax: priceMax,
        limit: limit ?? 20,
        cursor: cursor,
        excludeExpiringWithinHours: excludeExpiringWithinHours,
      );

  /// Customer Offer detail (`GET /v1/offers/{id}` as Customer).
  /// Vendor detail remains [offers.getOffer] → [OfferForVendor].
  Future<Result<OfferForCustomer>> getCustomerOffer(String id) =>
      offers.get(id);

  Future<Result<VendorRatingDetail>> offerVendorRating(String id) =>
      offers.vendorRating(id);

  Future<Result<void>> markOfferViewed(String id) async {
    final r = await _client.send('POST', '/v1/offers/$id/viewed');
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }

  /// Accept body is always `{confirmation:"REVEAL_AND_CONNECT"}` (inventory).
  Future<Result<AcceptOfferResult>> acceptOffer(
    String id, {
    required String idempotencyKey,
  }) =>
      offers.accept(id, idempotencyKey: idempotencyKey);

  Future<Result<OfferForCustomer>> declineOffer(
    String id, {
    String? reason,
    String? note,
  }) =>
      offers.decline(id, reason: reason, note: note);

  // --- connections (CUS-S15, S16) ---
  Future<Result<PagedResult<ConnectionForCustomer>>> listMyConnections({
    String? state,
    int limit = 20,
    String? cursor,
  }) =>
      connections.listMineForCustomer(
        state: state,
        limit: limit,
        cursor: cursor,
      );

  Future<Result<ConnectionForCustomer>> getConnection(String id) =>
      connections.getById(id);

  Future<Result<ConnectionForCustomer>> closeConnection(
    String id, {
    String? reason,
  }) =>
      connections.closeForCustomer(id, reason: reason);

  Future<Result<void>> recordContactEvent(
    String connectionId, {
    required String channel, // WHATSAPP | PHONE
  }) =>
      connections.recordContactEvent(
        connectionId: connectionId,
        channel: channel,
      );

  // --- reviews (CUS-S18) ---
  Future<Result<Review>> createReview(
    String connectionId, {
    required int rating,
    String? comment,
  }) =>
      reviews.create(
        connectionId: connectionId,
        rating: rating,
        comment: comment,
      );

  Future<Result<PagedResult<Review>>> listMyReviews({
    String? role, // AUTHOR | SUBJECT
    int limit = 20,
    String? cursor,
  }) =>
      reviews.list(
        role: role,
        limit: limit,
        cursor: cursor,
      );

  Future<Result<Review>> updateReview(
    String id, {
    int? rating,
    String? comment,
  }) =>
      reviews.patch(
        id,
        rating: rating,
        comment: comment,
      );

  Future<Result<Review>> withdrawReview(String id) => reviews.withdraw(id);

  Future<Result<Review>> respondToReview(String id, String response) =>
      reviews.respond(id, response: response);

  Future<Result<void>> flagReview(String id) => reviews.flag(id);

  // --- notifications (CUS-S19) ---
  Future<Result<PagedResult<AppNotification>>> listNotifications({
    bool? unread,
    int limit = 20,
    String? cursor,
  }) =>
      notifications.list(
        unread: unread,
        limit: limit,
        cursor: cursor,
      );

  Future<Result<int>> unreadNotificationCount() => notifications.unreadCount();

  Future<Result<AppNotification>> markNotificationRead(String id) =>
      notifications.markRead(id);

  Future<Result<void>> markAllNotificationsRead() =>
      notifications.markAllRead();

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
  Future<Result<AbuseReport>> reportAbuse({
    required dynamic entityType, // AbuseEntityType or String
    required String entityId,
    required String category,
    required String description,
  }) {
    final AbuseEntityType type = entityType is AbuseEntityType
        ? entityType
        : AbuseEntityType.parse(entityType.toString());
    return abuse.submit(
      entityType: type,
      entityId: entityId,
      category: category,
      description: description,
    );
  }
}
