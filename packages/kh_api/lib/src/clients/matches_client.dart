import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class MatchesClient {
  const MatchesClient(this._client);
  final KhApiClient _client;

  Future<Result<PagedResult<VendorRequestItem>>> getMatches({
    String? cursor,
    int limit = 20,
    String? sort,
    String? requestType,
    String? categoryId,
    String? regionId,
    double? minBudget,
    double? maxBudget,
    String? purityKarat,
    bool? includeResponded,
    String? presetId,
  }) async {
    final query = <String, dynamic>{
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      'limit': limit.toString(),
      if (sort != null) 'sort': sort,
      if (requestType != null) 'requestType': requestType,
      if (categoryId != null) 'categoryId': categoryId,
      if (regionId != null) 'regionId': regionId,
      if (minBudget != null) 'minBudget': minBudget.toString(),
      if (maxBudget != null) 'maxBudget': maxBudget.toString(),
      if (purityKarat != null) 'purityKarat': purityKarat,
      if (includeResponded != null) 'includeResponded': includeResponded.toString(),
      if (presetId != null) 'presetId': presetId,
    };

    final r = await _client.send(
      'GET',
      '/v1/matches',
      query: query,
      unwrapData: false,
    );

    return r.when(
      ok: (raw) {
        if (raw is! Map<String, dynamic>) {
          if (raw is List) {
            final items = raw
                .map((e) => VendorRequestItem.fromJson(e as Map<String, dynamic>))
                .toList(growable: false);
            return Ok(PagedResult(items: items));
          }
          return const Ok(PagedResult.empty());
        }

        final dataList = (raw['data'] as List?) ?? const [];
        final meta = (raw['meta'] as Map<String, dynamic>?) ?? const {};
        final items = dataList
            .map((e) => VendorRequestItem.fromJson(e as Map<String, dynamic>))
            .toList(growable: false);
        final nextCursor = meta['nextCursor'] as String?;
        final hasMore = meta['hasMore'] as bool?;

        return Ok(PagedResult(
          items: items,
          nextCursor: nextCursor,
          hasMore: hasMore,
        ));
      },
      err: Err.new,
    );
  }

  Future<Result<void>> markViewed(String requestId) async {
    final r = await _client.send('POST', '/v1/matches/$requestId/viewed');
    return r.when(
      ok: (_) => const Ok(null),
      err: Err.new,
    );
  }
}
