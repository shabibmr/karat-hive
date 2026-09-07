import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class OffersClient {
  const OffersClient(this._client);
  final KhApiClient _client;

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
      ok: (raw) {
        if (raw is! Map<String, dynamic>) {
          if (raw is List) {
            final items = raw
                .map((e) => OfferForVendor.fromJson(e as Map<String, dynamic>))
                .toList(growable: false);
            return Ok(PagedResult(items: items));
          }
          return const Ok(PagedResult.empty());
        }

        final dataList = (raw['data'] as List?) ?? const [];
        final meta = (raw['meta'] as Map<String, dynamic>?) ?? const {};
        final items = dataList
            .map((e) => OfferForVendor.fromJson(e as Map<String, dynamic>))
            .toList(growable: false);
        return Ok(PagedResult(
          items: items,
          nextCursor: meta['nextCursor'] as String?,
          hasMore: meta['hasMore'] as bool?,
        ));
      },
      err: Err.new,
    );
  }
}
