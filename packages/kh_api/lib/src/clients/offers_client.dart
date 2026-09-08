import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../paged.dart';

class OffersClient {
  const OffersClient(this._client);
  final KhApiClient _client;

  // --- Vendor methods (CP-3) ---

  Future<Result<OfferForVendor>> submitOffer({
    required String requestId,
    required OfferTermsInput terms,
  }) async {
    final r = await _client.send(
      'POST',
      '/v1/requests/$requestId/offers',
      body: terms.toJson(),
    );
    return r.when(
      ok: (d) => Ok(OfferForVendor.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<OfferForVendor>> reviseOffer({
    required String offerId,
    required OfferTermsInput terms,
  }) async {
    final r = await _client.send(
      'POST',
      '/v1/offers/$offerId/revise',
      body: terms.toJson(includeMediaKeys: false),
    );
    return r.when(
      ok: (d) => Ok(OfferForVendor.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<OfferForVendor>> withdrawOffer(String offerId) async {
    final r = await _client.send('POST', '/v1/offers/$offerId/withdraw');
    return r.when(
      ok: (d) => Ok(OfferForVendor.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<OfferForVendor>> getOffer(String offerId) async {
    final r = await _client.send('GET', '/v1/offers/$offerId');
    return r.when(
      ok: (d) => Ok(OfferForVendor.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<PagedResult<OfferForVendor>>> listMyOffers({
    String? tab,
    String? requestType,
    DateTime? from,
    DateTime? to,
    String? q,
    String? cursor,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{
      'limit': limit.toString(),
      if (tab != null) 'tab': tab,
      if (requestType != null) 'requestType': requestType,
      if (from != null) 'from': from.toUtc().toIso8601String(),
      if (to != null) 'to': to.toUtc().toIso8601String(),
      if (q != null && q.isNotEmpty) 'q': q,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    };

    final r = await _client.send(
      'GET',
      '/v1/me/offers',
      query: query,
      unwrapData: false,
    );

    return r.when(
      ok: (raw) => Ok(parsePagedEnvelope(raw, OfferForVendor.fromJson)),
      err: Err.new,
    );
  }

  // --- Customer methods (CM-Track O) ---

  Future<Result<PagedResult<OfferForCustomer>>> listForRequest(
    String requestId, {
    String? cursor,
    int limit = 20,
    String? sort,
    String? minRating,
    String? priceMin,
    String? priceMax,
    int? excludeExpiringWithinHours,
  }) async {
    final query = <String, dynamic>{
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      'limit': limit.toString(),
      if (sort != null) 'sort': sort,
      if (minRating != null) 'minRating': minRating,
      if (priceMin != null) 'priceMin': priceMin,
      if (priceMax != null) 'priceMax': priceMax,
      if (excludeExpiringWithinHours != null)
        'excludeExpiringWithinHours': excludeExpiringWithinHours.toString(),
    };
    final r = await _client.send(
      'GET',
      '/v1/requests/$requestId/offers',
      query: query,
      unwrapData: false,
    );
    return r.when(
      ok: (raw) => Ok(parsePagedEnvelope(raw, OfferForCustomer.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<OfferForCustomer>> get(String id) async {
    final r = await _client.send('GET', '/v1/offers/$id');
    return r.when(
      ok: (d) => Ok(OfferForCustomer.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<VendorRatingDetail>> vendorRating(String offerId) async {
    final r = await _client.send('GET', '/v1/offers/$offerId/vendor-rating');
    return r.when(
      ok: (d) => Ok(VendorRatingDetail.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<AcceptOfferResult>> accept(String id) async {
    final r = await _client.send(
      'POST',
      '/v1/offers/$id/accept',
      body: const {'confirmation': 'REVEAL_AND_CONNECT'},
    );
    return r.when(
      ok: (d) => Ok(AcceptOfferResult.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<OfferForCustomer>> decline(
    String id, {
    String? reason,
    String? note,
  }) async {
    final r = await _client.send(
      'POST',
      '/v1/offers/$id/decline',
      body: {
        if (reason != null) 'reason': reason,
        if (note != null) 'note': note,
      },
    );
    return r.when(
      ok: (d) => Ok(OfferForCustomer.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }
}
