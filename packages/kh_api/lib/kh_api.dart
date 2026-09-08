library kh_api;

import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import 'src/dtos.dart';

export 'src/dtos.dart';

/// Typed facade over [KhApiClient]. DTOs are mapped to `kh_domain` types here so
/// generated shapes never reach controllers/presentation (Architecture-Frontend §9.1).
class KhApi {
  KhApi(this._client);
  final KhApiClient _client;

  KhApiClient get client => _client;

  // --- auth ---
  Future<Result<OtpChallenge>> otpRequest({
    required String mobileNumber,
    required String purpose,
  }) async {
    final r = await _client.send('POST', '/v1/auth/otp/request', body: {
      'mobileNumber': mobileNumber,
      'purpose': purpose,
    });
    return r.when(
      ok: (d) => Ok(OtpChallenge.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<OtpVerifyResult>> otpVerify({
    required String challengeId,
    required String code,
  }) async {
    final r = await _client.send('POST', '/v1/auth/otp/verify', body: {
      'challengeId': challengeId,
      'code': code,
    });
    return r.when(
      ok: (d) => Ok(OtpVerifyResult.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<SessionBundle>> registerVendor(Map<String, dynamic> body) async {
    final r = await _client.send('POST', '/v1/auth/register/vendor', body: body);
    return r.when(
      ok: (d) => Ok(SessionBundle.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<SessionBundle>> loginPassword({
    required String email,
    required String password,
  }) async {
    final r = await _client.send('POST', '/v1/auth/login/password',
        body: {'email': email, 'password': password});
    return r.when(
      ok: (d) => Ok(SessionBundle.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

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
  ) async {
    final r = await client.send('POST', '/v1/auth/refresh',
        body: {'refreshToken': refreshToken});
    return r.when(
      ok: (d) => SessionBundle.fromJson(d as Map<String, dynamic>).tokens,
      err: (_) => null,
    );
  }

  Future<void> logout(String? refreshToken) =>
      _client.send('POST', '/v1/auth/logout', body: {'refreshToken': refreshToken});

  // --- me ---
  Future<Result<MeUser>> me() async {
    final r = await _client.send('GET', '/v1/me');
    return r.when(
      ok: (d) => Ok(MeUser.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  // --- taxonomy ---
  Future<Result<List<TaxonomyNode>>> categories() => _taxonomy('/v1/categories');
  Future<Result<List<TaxonomyNode>>> regions() => _taxonomy('/v1/regions');

  Future<Result<List<TaxonomyNode>>> _taxonomy(String path) async {
    final r = await _client.send('GET', path);
    return r.when(
      ok: (d) => Ok(((d as List?) ?? const [])
          .map((e) => TaxonomyNode.fromJson(e as Map<String, dynamic>))
          .toList(growable: false)),
      err: Err.new,
    );
  }

  // --- vendor onboarding ---
  Future<Result<VendorMe>> vendorMe() => _vendorMe('GET', '/v1/me/vendor');

  Future<Result<List<VendorDocument>>> documents() async {
    final r = await _client.send('GET', '/v1/me/vendor/documents');
    return r.when(
      ok: (d) => Ok(((d as List?) ?? const [])
          .map((e) => VendorDocument.fromJson(e as Map<String, dynamic>))
          .toList(growable: false)),
      err: Err.new,
    );
  }

  Future<Result<List<VendorDocument>>> attachDocument({
    required String documentType,
    required String mediaKey,
    String? expiryDate,
  }) async {
    final r = await _client.send('POST', '/v1/me/vendor/documents', body: {
      'documentType': documentType,
      'mediaKey': mediaKey,
      if (expiryDate != null) 'expiryDate': expiryDate,
    });
    return r.when(
      ok: (d) => Ok(((d as List?) ?? const [])
          .map((e) => VendorDocument.fromJson(e as Map<String, dynamic>))
          .toList(growable: false)),
      err: Err.new,
    );
  }

  Future<Result<VendorMe>> setCategories(List<String> ids) =>
      _vendorMe('PUT', '/v1/me/vendor/categories', body: {'categoryIds': ids});

  Future<Result<VendorMe>> setRegions(List<String> ids) =>
      _vendorMe('PUT', '/v1/me/vendor/regions', body: {'regionIds': ids});

  Future<Result<VendorMe>> setAvailability({bool? awayMode, Object? businessHours}) =>
      _vendorMe('PATCH', '/v1/me/vendor/availability', body: {
        if (awayMode != null) 'awayMode': awayMode,
        if (businessHours != null) 'businessHours': businessHours,
      });

  Future<Result<VendorMe>> resubmit() =>
      _vendorMe('POST', '/v1/me/vendor/resubmit');

  Future<Result<VendorMe>> _vendorMe(
    String method,
    String path, {
    Object? body,
  }) async {
    final r = await _client.send(method, path, body: body);
    return r.when(
      ok: (d) => Ok(VendorMe.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<VendorDashboard>> dashboard() async {
    final r = await _client.send('GET', '/v1/me/dashboard');
    return r.when(
      ok: (d) => Ok(VendorDashboard.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  // --- media ---
  Future<Result<UploadIntent>> uploadIntent({
    required String purpose,
    required String contentType,
    required int byteSize,
  }) async {
    final r = await _client.send('POST', '/v1/media/upload-intent', body: {
      'purpose': purpose,
      'contentType': contentType,
      'byteSize': byteSize,
    });
    return r.when(
      ok: (d) => Ok(UploadIntent.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<String>> completeUpload(String key) async {
    final r = await _client.send('POST', '/v1/media/$key/complete');
    return r.when(
      ok: (d) => Ok((d as Map<String, dynamic>)['state'] as String? ?? 'READY'),
      err: Err.new,
    );
  }

  Future<Result<void>> deleteMedia(String key) async {
    final r = await _client.send('DELETE', '/v1/media/$key');
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }

  // ===========================================================================
  // Customer surface (Screen-API-Map §3). Hand-written to the same Result /
  // envelope conventions as the auth/vendor methods above; masked fields are
  // absent from the DTOs by shape, not nulled (BR-006, NFR-013, AD-FE-07).
  // ===========================================================================

  T _obj<T>(dynamic d, T Function(Map<String, dynamic>) f) =>
      f(d as Map<String, dynamic>);

  // --- identity ---
  Future<Result<SessionBundle>> registerCustomer({
    String? challengeId,
    String? firebaseToken,
    required String displayName,
    String? email,
    String? preferredLanguage,
    String? defaultRegionId,
    required String termsVersion,
    required String privacyVersion,
  }) async {
    final r = await _client.send('POST', '/v1/auth/register/customer', body: {
      if (challengeId != null) 'challengeId': challengeId,
      if (firebaseToken != null) 'firebaseToken': firebaseToken,
      'displayName': displayName,
      if (email != null) 'email': email,
      if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
      if (defaultRegionId != null) 'defaultRegionId': defaultRegionId,
      'termsVersion': termsVersion,
      'privacyVersion': privacyVersion,
    });
    return r.when(
      ok: (d) => Ok(SessionBundle.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<MeUser>> patchMe({
    String? preferredLanguage,
    String? displayName,
    String? defaultRegionId,
    bool clearDefaultRegion = false,
  }) async {
    final r = await _client.send('PATCH', '/v1/me', body: {
      if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
      if (displayName != null) 'displayName': displayName,
      if (clearDefaultRegion)
        'defaultRegionId': null
      else if (defaultRegionId != null)
        'defaultRegionId': defaultRegionId,
    });
    return r.when(
      ok: (d) => Ok(MeUser.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<MeUser>> changeMobile(String challengeId) async {
    final r = await _client.send('POST', '/v1/me/mobile/change',
        body: {'challengeId': challengeId});
    return r.when(
      ok: (d) => Ok(MeUser.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<void>> deactivateMe() async {
    final r = await _client.send('POST', '/v1/me/deactivate');
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }

  Future<Result<Map<String, dynamic>>> createDeletionRequest() async {
    final r = await _client.send('POST', '/v1/me/deletion-requests');
    return r.when(
      ok: (d) => Ok((d as Map).cast<String, dynamic>()),
      err: Err.new,
    );
  }

  Future<Result<Map<String, dynamic>>> confirmDeletionRequest(
    String id,
    String challengeId,
  ) async {
    final r = await _client.send(
        'POST', '/v1/me/deletion-requests/$id/confirm',
        body: {'challengeId': challengeId});
    return r.when(
      ok: (d) => Ok((d as Map).cast<String, dynamic>()),
      err: Err.new,
    );
  }

  // --- platform config / gold rates ---
  Future<Result<PlatformConfigDto>> platformConfig() async {
    final r = await _client.send('GET', '/v1/platform-config');
    return r.when(
      ok: (d) => Ok(_obj(d, PlatformConfigDto.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<GoldRateSnapshotDto>> goldRates() async {
    final r = await _client.send('GET', '/v1/gold-rates');
    return r.when(
      ok: (d) => Ok(_obj(d, GoldRateSnapshotDto.fromJson)),
      err: Err.new,
    );
  }

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

  Future<Result<UserSettingsDto>> patchSettings(UserSettingsPatch patch) async {
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
