import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

PagedResult<T> _paged<T>(
  dynamic raw,
  T Function(Map<String, dynamic>) parse,
) {
  if (raw is List) {
    return PagedResult(
      items: raw
          .map((e) => parse(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false),
    );
  }
  if (raw is! Map) return const PagedResult.empty();
  final map = Map<String, dynamic>.from(raw);
  final dataList = (map['data'] as List?) ?? const [];
  final meta = (map['meta'] as Map?) ?? const {};
  final metaMap = Map<String, dynamic>.from(meta);
  return PagedResult(
    items: dataList
        .map((e) => parse(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false),
    nextCursor: metaMap['nextCursor'] as String?,
    hasMore: metaMap['hasMore'] as bool?,
  );
}

class OffersClient {
  const OffersClient(this._client);
  final KhApiClient _client;

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
      ok: (raw) => Ok(_paged(raw, OfferForCustomer.fromJson)),
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
