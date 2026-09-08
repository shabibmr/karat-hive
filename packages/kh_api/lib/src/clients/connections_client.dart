import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../paged.dart';

class ConnectionsClient {
  const ConnectionsClient(this._client);
  final KhApiClient _client;

  // --- Vendor methods (CP-4) ---

  Future<Result<PagedResult<ConnectionForVendor>>> listMine({
    String? state,
    String? cursor,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{
      'limit': limit.toString(),
      if (state != null) 'state': state,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    };

    final r = await _client.send(
      'GET',
      '/v1/me/connections',
      query: query,
      unwrapData: false,
    );

    return r.when(
      ok: (raw) {
        if (raw is! Map<String, dynamic>) {
          if (raw is List) {
            final items = raw
                .map(
                  (e) => ConnectionForVendor.fromJson(e as Map<String, dynamic>),
                )
                .toList(growable: false);
            return Ok(PagedResult(items: items));
          }
          return const Ok(PagedResult.empty());
        }

        final dataList = (raw['data'] as List?) ?? const [];
        final meta = (raw['meta'] as Map<String, dynamic>?) ?? const {};
        final items = dataList
            .map((e) => ConnectionForVendor.fromJson(e as Map<String, dynamic>))
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

  Future<Result<ConnectionForVendor>> get(String connectionId) async {
    final r = await _client.send('GET', '/v1/connections/$connectionId');
    return r.when(
      ok: (d) => Ok(ConnectionForVendor.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<ConnectionForVendor>> close(
    String connectionId, {
    String? reason,
  }) async {
    final r = await _client.send(
      'POST',
      '/v1/connections/$connectionId/close',
      body: {
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
    return r.when(
      ok: (d) => Ok(ConnectionForVendor.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  /// Channel is `WHATSAPP` or `PHONE`. No conversation content is sent (NFR-017).
  Future<Result<void>> recordContactEvent({
    required String connectionId,
    required String channel,
  }) async {
    final r = await _client.send(
      'POST',
      '/v1/connections/$connectionId/contact-events',
      body: {'channel': channel},
    );
    return r.when(
      ok: (_) => const Ok(null),
      err: Err.new,
    );
  }

  // --- Customer methods ---

  Future<Result<PagedResult<ConnectionForCustomer>>> listMineForCustomer({
    String? state,
    String? cursor,
    int limit = 20,
  }) async {
    final r = await _client.send(
      'GET',
      '/v1/me/connections',
      query: {
        if (state != null) 'state': state,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit.toString(),
      },
      unwrapData: false,
    );
    return r.when(
      ok: (raw) => Ok(parsePagedEnvelope(raw, ConnectionForCustomer.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<ConnectionForCustomer>> getById(String id) async {
    final r = await _client.send('GET', '/v1/connections/$id');
    return r.when(
      ok: (d) => Ok(ConnectionForCustomer.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<ConnectionForCustomer>> closeForCustomer(
    String id, {
    String? reason,
  }) async {
    final r = await _client.send(
      'POST',
      '/v1/connections/$id/close',
      body: {if (reason != null) 'reason': reason},
    );
    return r.when(
      ok: (d) => Ok(ConnectionForCustomer.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }
}
