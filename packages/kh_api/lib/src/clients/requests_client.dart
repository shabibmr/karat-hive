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

class RequestsClient {
  const RequestsClient(this._client);
  final KhApiClient _client;

  Future<Result<VendorRequestItem>> getRequest(String id) async {
    final r = await _client.send('GET', '/v1/requests/$id');
    return r.when(
      ok: (d) => Ok(VendorRequestItem.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  /// Owner presenter — `GET /v1/requests/{id}` as Customer.
  Future<Result<RequestForCustomer>> getMine(String id) async {
    final r = await _client.send('GET', '/v1/requests/$id');
    return r.when(
      ok: (d) => Ok(RequestForCustomer.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<PagedResult<RequestForCustomer>>> listMine({
    String? cursor,
    int limit = 20,
    List<String>? state,
    String? requestType,
    String? direction,
    String? q,
    String? from,
    String? to,
  }) async {
    final query = <String, dynamic>{
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      'limit': limit.toString(),
      if (state != null && state.isNotEmpty) 'state': state.join(','),
      if (requestType != null) 'requestType': requestType,
      if (direction != null) 'direction': direction,
      if (q != null && q.isNotEmpty) 'q': q,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    };
    final r = await _client.send(
      'GET',
      '/v1/me/requests',
      query: query,
      unwrapData: false,
    );
    return r.when(
      ok: (raw) => Ok(_paged(raw, RequestForCustomer.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<RequestForCustomer>> patchMine(
    String id, {
    String? notes,
    String? budgetMin,
    String? budgetMax,
    bool? budgetIsFlexible,
    List<String>? mediaKeys,
  }) async {
    final r = await _client.send('PATCH', '/v1/requests/$id', body: {
      if (notes != null) 'notes': notes,
      if (budgetMin != null) 'budgetMin': budgetMin,
      if (budgetMax != null) 'budgetMax': budgetMax,
      if (budgetIsFlexible != null) 'budgetIsFlexible': budgetIsFlexible,
      if (mediaKeys != null) 'mediaKeys': mediaKeys,
    });
    return r.when(
      ok: (d) => Ok(RequestForCustomer.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<RequestForCustomer>> cancel(String id, {String? reason}) async {
    final r = await _client.send(
      'POST',
      '/v1/requests/$id/cancel',
      body: {if (reason != null) 'reason': reason},
    );
    return r.when(
      ok: (d) => Ok(RequestForCustomer.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }
}
